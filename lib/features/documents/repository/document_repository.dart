import 'package:flutter/foundation.dart';
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../model/document.dart';
import '../../family/model/family_member.dart';
import '../../family/repository/family_repository.dart';
import '../../reminder/repository/reminder_state_repository.dart';

/// 証件とメンバー情報を含むクラス
class DocumentWithMember {
  final Document document;
  final FamilyMember member;

  DocumentWithMember({
    required this.document,
    required this.member,
  });
}

class DocumentRepository {
  static const table = 'document';

  /// Insert a document
  static Future<int> insert(Document document) async {
    try {
      if (kIsWeb) {
        final box = await HiveProvider.getBox(HiveProvider.documentBox);
        final id = box.length + 1;
        final docWithId = Document(
          id: id,
          memberId: document.memberId,
          documentType: document.documentType,
          documentNumber: document.documentNumber,
          expiryDate: document.expiryDate,
          policyId: document.policyId,
          notes: document.notes,
          createdAt: document.createdAt,
        );
        await box.put(id, docWithId.toMap());
        return id;
      } else {
        final db = await DBProvider.database;
        return await db.insert(table, document.toMap());
      }
    } catch (e) {
      print('[DocumentRepository] Error inserting document: $e');
      rethrow; // UI層でエラーを表示できるように再スロー
    }
  }

  /// Get all documents
  static Future<List<Document>> getAll() async {
    try {
      if (kIsWeb) {
        final box = await HiveProvider.getBox(HiveProvider.documentBox);
        return box.values
            .map((e) => Document.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        final db = await DBProvider.database;
        final res = await db.query(table);
        return res.map((e) => Document.fromMap(e)).toList();
      }
    } catch (e) {
      print('[DocumentRepository] Error getting all documents: $e');
      return []; // 空リストを返して画面を表示可能にする
    }
  }

  /// Get documents by member ID
  static Future<List<Document>> getByMemberId(int memberId) async {
    try {
      if (kIsWeb) {
        final box = await HiveProvider.getBox(HiveProvider.documentBox);
        return box.values
            .map((e) => Document.fromMap(Map<String, dynamic>.from(e)))
            .where((d) => d.memberId == memberId)
            .toList();
      } else {
        final db = await DBProvider.database;
        final res = await db.query(
          table,
          where: 'member_id = ?',
          whereArgs: [memberId],
        );
        return res.map((e) => Document.fromMap(e)).toList();
      }
    } catch (e) {
      print('[DocumentRepository] Error getting documents by memberId $memberId: $e');
      return []; // 空リストを返して画面を表示可能にする
    }
  }

  /// Get document by ID
  static Future<Document?> getById(int id) async {
    try {
      if (kIsWeb) {
        final box = await HiveProvider.getBox(HiveProvider.documentBox);
        final data = box.get(id);
        if (data != null) {
          return Document.fromMap(Map<String, dynamic>.from(data));
        }
        return null;
      } else {
        final db = await DBProvider.database;
        final res = await db.query(
          table,
          where: 'id = ?',
          whereArgs: [id],
        );
        if (res.isNotEmpty) {
          return Document.fromMap(res.first);
        }
        return null;
      }
    } catch (e) {
      print('[DocumentRepository] Error getting document by id $id: $e');
      return null; // nullを返して処理を継続可能にする
    }
  }

  /// Update document
  static Future<int> update(Document document) async {
    try {
      if (kIsWeb) {
        final box = await HiveProvider.getBox(HiveProvider.documentBox);
        await box.put(document.id, document.toMap());
        return 1;
      } else {
        final db = await DBProvider.database;
        return await db.update(
          table,
          document.toMap(),
          where: 'id = ?',
          whereArgs: [document.id],
        );
      }
    } catch (e) {
      print('[DocumentRepository] Error updating document ${document.id}: $e');
      rethrow; // UI層でエラーを表示できるように再スロー
    }
  }

  /// Delete document
  /// データ整合性のため、関連するReminderStateも削除します
  static Future<int> delete(int id) async {
    try {
      // まずReminderStateを削除（カスケード削除）
      try {
        await ReminderStateRepository.deleteByDocumentId(id);
      } catch (e) {
        print('[DocumentRepository] Warning: Failed to delete reminder state for document $id: $e');
        // ReminderStateの削除失敗は警告のみ（証件削除は続行）
      }
      
      // 証件本体を削除
      if (kIsWeb) {
        final box = await HiveProvider.getBox(HiveProvider.documentBox);
        await box.delete(id);
        return 1;
      } else {
        final db = await DBProvider.database;
        return await db.delete(
          table,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      print('[DocumentRepository] Error deleting document $id: $e');
      rethrow; // UI層でエラーを表示できるように再スロー
    }
  }

  /// Get all documents with member information (for DocumentAllListPage)
  static Future<List<DocumentWithMember>> getAllWithMemberInfo() async {
    try {
      final documents = await getAll();
      final members = await FamilyRepository.getAll();
      
      final List<DocumentWithMember> result = [];
      
      for (final doc in documents) {
        final member = members.firstWhere(
          (m) => m.id == doc.memberId,
          orElse: () => FamilyMember(
            id: doc.memberId,
            name: '不明',
            relationship: 'other',
          ),
        );
        result.add(DocumentWithMember(
          document: doc,
          member: member,
        ));
      }
      
      return result;
    } catch (e) {
      print('[DocumentRepository] Error getting all documents with member info: $e');
      return []; // 空リストを返して画面を表示可能にする
    }
  }
}