import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../family/model/family_member.dart';
import '../../family/repository/family_repository.dart';
import '../../documents/model/document.dart';
import '../../documents/repository/document_repository.dart';
import '../../reminder/model/reminder_state.dart';
import '../../reminder/repository/reminder_state_repository.dart';

/// データエクスポート/インポートサービス
/// 家族メンバー、証件、リマインダー状態をJSON形式でバックアップ・リストア
class DataExportService {
  /// データをJSONにエクスポート
  static Future<Map<String, dynamic>> exportToJson() async {
    try {
      debugPrint('[DataExport] 📤 エクスポート開始');

      // 全データを取得
      final members = await FamilyRepository.getAll();
      final documents = await DocumentRepository.getAll();
      final reminderStates = await ReminderStateRepository.getAll();

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'members': members.map((m) => m.toMap()).toList(),
        'documents': documents.map((d) => d.toMap()).toList(),
        'reminderStates': reminderStates.map((r) => r.toMap()).toList(),
      };

      debugPrint('[DataExport] ✅ エクスポート完了: ${members.length}人, ${documents.length}件');
      return exportData;
    } catch (e) {
      debugPrint('[DataExport] ❌ エクスポートエラー: $e');
      rethrow;
    }
  }

  /// JSONファイルを作成してパスを返す
  /// iOSではDocumentsフォルダにも保存（インポート時に見つけやすくする）
  static Future<File> createExportFile() async {
    try {
      final exportData = await exportToJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'doc_reminder_backup_$timestamp.json';

      // iOSの場合、Documentsフォルダにも保存（Files appからアクセス可能）
      if (!kIsWeb && Platform.isIOS) {
        try {
          final documentsDir = await getApplicationDocumentsDirectory();
          final documentsFile = File('${documentsDir.path}/$fileName');
          await documentsFile.writeAsString(jsonString);
          debugPrint('[DataExport] 📄 Documentsフォルダに保存: ${documentsFile.path}');
        } catch (e) {
          debugPrint('[DataExport] ⚠️ Documents保存エラー（継続）: $e');
        }
      }

      // 共有用に一時ファイルも作成
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);
      debugPrint('[DataExport] 📄 一時ファイル作成: ${file.path}');

      return file;
    } catch (e) {
      debugPrint('[DataExport] ❌ ファイル作成エラー: $e');
      rethrow;
    }
  }

  /// ファイル共有（iOS/Android）
  static Future<void> shareFile({String? shareText}) async {
    try {
      debugPrint('[DataExport] 📲 ファイル共有開始');

      final file = await createExportFile();
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Document Renewal Reminder Backup',
        text: shareText,
      );

      if (result.status == ShareResultStatus.success) {
        debugPrint('[DataExport] ✅ 共有成功');
      } else {
        debugPrint('[DataExport] ⚠️ 共有キャンセル: ${result.status}');
      }
    } catch (e) {
      debugPrint('[DataExport] ❌ 共有エラー: $e');
      rethrow;
    }
  }

  /// JSONファイルからインポート
  static Future<void> importFromFile(File file) async {
    try {
      debugPrint('[DataImport] 📥 インポート開始: ${file.path}');

      // ファイル読み込み
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // バージョンチェック
      final version = data['version'] as String?;
      if (version != '1.0') {
        throw Exception('サポートされていないバックアップバージョン: $version');
      }

      await importFromJson(data);
    } catch (e) {
      debugPrint('[DataImport] ❌ インポートエラー: $e');
      rethrow;
    }
  }

  /// JSON文字列からインポート
  static Future<void> importFromJsonString(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      await importFromJson(data);
    } catch (e) {
      debugPrint('[DataImport] ❌ JSON文字列インポートエラー: $e');
      rethrow;
    }
  }

  /// JSONデータをインポート（リストア）
  static Future<ImportResult> importFromJson(Map<String, dynamic> data) async {
    int memberCount = 0;
    int documentCount = 0;
    int reminderStateCount = 0;

    try {
      debugPrint('[DataImport] 📥 データインポート開始');

      // ⚠️ 既存データを全削除（上書きモード）
      await clearAllData();
      debugPrint('[DataImport] 🗑️ 既存データを削除しました');

      // トランザクション風に全データをインポート
      // 1. 家族メンバーをインポート
      final membersList = data['members'] as List<dynamic>? ?? [];
      final Map<int, int> memberIdMap = {}; // 旧ID → 新ID のマッピング

      for (final memberData in membersList) {
        try {
          final member = FamilyMember.fromMap(memberData as Map<String, dynamic>);
          final oldId = member.id;
          
          // IDをnullにして新規挿入
          final newMember = FamilyMember(
            name: member.name,
            relationship: member.relationship,
            dateOfBirth: member.dateOfBirth,
            createdAt: member.createdAt,
            updatedAt: DateTime.now(),
          );
          
          final newId = await FamilyRepository.insert(newMember);
          if (oldId != null) {
            memberIdMap[oldId] = newId;
          }
          memberCount++;
        } catch (e) {
          debugPrint('[DataImport] ⚠️ メンバーインポートエラー: $e');
        }
      }

      // 2. 証件をインポート
      final documentsList = data['documents'] as List<dynamic>? ?? [];
      final Map<int, int> documentIdMap = {}; // 旧ID → 新ID のマッピング

      for (final docData in documentsList) {
        try {
          final doc = Document.fromMap(docData as Map<String, dynamic>);
          final oldId = doc.id;
          final oldMemberId = doc.memberId;
          
          // メンバーIDをマッピング
          final newMemberId = memberIdMap[oldMemberId];
          if (newMemberId == null) {
            debugPrint('[DataImport] ⚠️ 証件のメンバーが見つかりません: memberId=$oldMemberId');
            continue;
          }

          // IDをnullにして新規挿入
          final newDoc = Document(
            memberId: newMemberId,
            documentType: doc.documentType,
            documentNumber: doc.documentNumber,
            expiryDate: doc.expiryDate,
            customReminderDays: doc.customReminderDays,
            customReminderFrequency: doc.customReminderFrequency,
            notes: doc.notes,
            syncToCalendar: doc.syncToCalendar,
            createdAt: doc.createdAt,
            updatedAt: DateTime.now(),
          );

          final newId = await DocumentRepository.insert(newDoc);
          if (oldId != null) {
            documentIdMap[oldId] = newId;
          }
          documentCount++;
        } catch (e) {
          debugPrint('[DataImport] ⚠️ 証件インポートエラー: $e');
        }
      }

      // 3. リマインダー状態をインポート
      final reminderStatesList = data['reminderStates'] as List<dynamic>? ?? [];

      for (final stateData in reminderStatesList) {
        try {
          final state = ReminderState.fromMap(stateData as Map<String, dynamic>);
          final oldDocumentId = state.documentId;
          
          // 証件IDをマッピング
          final newDocumentId = documentIdMap[oldDocumentId];
          if (newDocumentId == null) {
            debugPrint('[DataImport] ⚠️ リマインダー状態の証件が見つかりません: documentId=$oldDocumentId');
            continue;
          }

          // IDをnullにして新規挿入
          final newState = ReminderState(
            documentId: newDocumentId,
            status: state.status,
            reminderStartDate: state.reminderStartDate,
            expectedFinishDate: state.expectedFinishDate,
            lastNotificationDate: state.lastNotificationDate,
            createdAt: state.createdAt,
            updatedAt: DateTime.now(),
          );

          await ReminderStateRepository.insert(newState);
          reminderStateCount++;
        } catch (e) {
          debugPrint('[DataImport] ⚠️ リマインダー状態インポートエラー: $e');
        }
      }

      debugPrint('[DataImport] ✅ インポート完了: $memberCount人, $documentCount件, $reminderStateCount状態');
      
      return ImportResult(
        success: true,
        memberCount: memberCount,
        documentCount: documentCount,
        reminderStateCount: reminderStateCount,
      );
    } catch (e) {
      debugPrint('[DataImport] ❌ インポートエラー: $e');
      return ImportResult(
        success: false,
        memberCount: memberCount,
        documentCount: documentCount,
        reminderStateCount: reminderStateCount,
        error: e.toString(),
      );
    }
  }

  /// 全データを削除（リストア前のクリーンアップ用）
  static Future<void> clearAllData() async {
    try {
      debugPrint('[DataExport] 🗑️ 全データ削除開始');

      // リマインダー状態を削除
      final states = await ReminderStateRepository.getAll();
      for (final state in states) {
        if (state.id != null) {
          await ReminderStateRepository.delete(state.id!);
        }
      }

      // 証件を削除
      final documents = await DocumentRepository.getAll();
      for (final doc in documents) {
        if (doc.id != null) {
          await DocumentRepository.delete(doc.id!);
        }
      }

      // メンバーを削除
      final members = await FamilyRepository.getAll();
      for (final member in members) {
        if (member.id != null) {
          await FamilyRepository.delete(member.id!);
        }
      }

      debugPrint('[DataExport] ✅ 全データ削除完了');
    } catch (e) {
      debugPrint('[DataExport] ❌ データ削除エラー: $e');
      rethrow;
    }
  }
}

/// インポート結果
class ImportResult {
  final bool success;
  final int memberCount;
  final int documentCount;
  final int reminderStateCount;
  final String? error;

  ImportResult({
    required this.success,
    required this.memberCount,
    required this.documentCount,
    required this.reminderStateCount,
    this.error,
  });

  @override
  String toString() {
    if (success) {
      return 'Import successful: $memberCount members, $documentCount documents, $reminderStateCount states';
    } else {
      return 'Import failed: $error';
    }
  }
}
