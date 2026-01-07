import '../../../core/notification_service.dart';
import '../../../core/localization/notification_localizations.dart';
import '../../../features/documents/model/document.dart';
import '../../../features/documents/repository/document_repository.dart';
import '../../../features/family/model/family_member.dart';
import '../../../features/family/repository/family_repository.dart';
import '../../../features/renewal_policy/model/renewal_policy.dart';
import '../../../features/renewal_policy/service/policy_service.dart';
import '../model/reminder_state.dart';
import '../repository/reminder_state_repository.dart';
import 'reminder_engine.dart';

/// リマインダースケジューラー
/// 
/// 通知のスケジューリングとバックグラウンド実行を担当
class ReminderScheduler {
  final NotificationService _notificationService;
  final ReminderEngine _reminderEngine;

  ReminderScheduler({
    NotificationService? notificationService,
    ReminderEngine? reminderEngine,
  })  : _notificationService = notificationService ?? NotificationService.instance,
        _reminderEngine = reminderEngine ?? ReminderEngine();

  /// 全証件のリマインダーをスケジュール
  /// 
  /// アプリ起動時、証件追加/更新時に呼ぶ
  Future<void> scheduleAll() async {
    try {
      // 既存の通知をすべてキャンセル
      await _notificationService.cancelAllNotifications();

      // 全証件を取得
      final documents = await DocumentRepository.getAll();

      // 各証件のリマインダー状態をチェック
      await _reminderEngine.checkAllDocuments(documents);

      // REMINDING状態の証件に対して通知をスケジュール
      final remindingStates = await ReminderStateRepository.getRemindingStates();
      for (final state in remindingStates) {
        try {
          await _scheduleForDocument(state);
        } catch (e) {
          print('Error scheduling notification for document ${state.documentId}: $e');
        }
      }
    } catch (e) {
      print('Error in scheduleAll: $e');
      rethrow;
    }
  }

  /// 単一証件のリマインダーをスケジュール
  Future<void> scheduleForDocument(int documentId) async {
    try {
      final state = await ReminderStateRepository.getByDocumentId(documentId);
      if (state == null || state.status != ReminderStatus.reminding) {
        // REMINDING状態でない場合は何もしない
        return;
      }

      await _scheduleForDocument(state);
    } catch (e) {
      print('Error scheduling for document $documentId: $e');
      rethrow;
    }
  }

  /// 証件の通知をキャンセル
  Future<void> cancelForDocument(int documentId) async {
    try {
      final notificationId = _getNotificationId(documentId);
      await _notificationService.cancelNotification(notificationId);
    } catch (e) {
      print('Error canceling notification for document $documentId: $e');
      rethrow;
    }
  }

  /// ReminderStateから通知をスケジュール
  Future<void> _scheduleForDocument(ReminderState state) async {
    try {
      // 証件情報を取得
      final document = await DocumentRepository.getById(state.documentId);
      if (document == null) return;

      // メンバー情報を取得
      final member = await FamilyRepository.getById(document.memberId);
      if (member == null) return;

      // ポリシーを取得
      final policy = await PolicyService.getPolicyForDocument(document);

      // 次回通知日を計算
      final nextNotificationDate = _calculateNextNotificationDate(state, policy);
      if (nextNotificationDate == null) return;

      // 通知内容を生成（多言語対応）
      final title = await _generateNotificationTitle(document, member);
      final body = await _generateNotificationBody(document, member, policy);
      final notificationId = _getNotificationId(document.id!);

      // 通知をスケジュール
      if (nextNotificationDate.isBefore(DateTime.now())) {
        // 過去の日時 → 即座に送信
        await _notificationService.showNotification(
          id: notificationId,
          title: title,
          body: body,
          payload: 'document:${document.id}',
        );
        // 通知送信記録
        await _reminderEngine.recordNotification(document.id!);
      } else {
        // 未来の日時 → スケジュール
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: nextNotificationDate,
          payload: 'document:${document.id}',
        );
      }
    } catch (e) {
      print('[ReminderScheduler] Error scheduling notification: $e');
    }
  }

  /// 次回通知日を計算
  DateTime? _calculateNextNotificationDate(
    ReminderState state,
    RenewalPolicy policy,
  ) {
    try {
      final lastNotification = state.lastNotificationDate;
      final now = DateTime.now();

      if (lastNotification == null) {
        // 初回通知 → すぐに送る
        return now;
      }

      // ポリシーのreminderFrequencyに基づいて計算
      switch (policy.reminderFrequency) {
        case 'daily':
          final nextDate = lastNotification.add(const Duration(days: 1));
          return nextDate.isAfter(now) ? nextDate : now;
        case 'weekly':
          final nextDate = lastNotification.add(const Duration(days: 7));
          return nextDate.isAfter(now) ? nextDate : now;
        case 'biweekly':
          final nextDate = lastNotification.add(const Duration(days: 14));
          return nextDate.isAfter(now) ? nextDate : now;
        case 'monthly':
          final nextDate = DateTime(
            lastNotification.year,
            lastNotification.month + 1,
            lastNotification.day,
            lastNotification.hour,
            lastNotification.minute,
          );
          return nextDate.isAfter(now) ? nextDate : now;
        default:
          // デフォルトは毎日
          final nextDate = lastNotification.add(const Duration(days: 1));
          return nextDate.isAfter(now) ? nextDate : now;
      }
    } catch (e) {
      print('[ReminderScheduler] Error calculating next notification date: $e');
      return null;
    }
  }

  /// 通知タイトルを生成
  Future<String> _generateNotificationTitle(Document document, FamilyMember member) async {
    try {
      final languageCode = await NotificationLocalizations.getLanguageCode();
      return NotificationLocalizations.getNotificationTitle(
        document.documentType,
        languageCode,
      );
    } catch (e) {
      print('[ReminderScheduler] Error generating notification title: $e');
      return '証件の更新が必要です'; // フォールバック
    }
  }

  /// 通知本文を生成
  Future<String> _generateNotificationBody(
    Document document,
    FamilyMember member,
    RenewalPolicy policy,
  ) async {
    try {
      final languageCode = await NotificationLocalizations.getLanguageCode();
      final daysUntilExpiry = PolicyService.daysUntilExpiry(document);
      
      return NotificationLocalizations.getNotificationBody(
        memberName: member.name,
        documentType: document.documentType,
        daysUntilExpiry: daysUntilExpiry,
        languageCode: languageCode,
      );
    } catch (e) {
      print('[ReminderScheduler] Error generating notification body: $e');
      final languageCode = await NotificationLocalizations.getLanguageCode();
      return NotificationLocalizations.getNotificationBodyGeneric(languageCode);
    }
  }

  /// 証件IDから通知IDを生成
  /// 
  /// 通知IDは各証件で一意である必要がある
  /// documentIdをそのまま使用（1〜10000の範囲を想定）
  int _getNotificationId(int documentId) {
    return documentId;
  }

  /// バックグラウンドタスク用（定期実行）
  /// 
  /// OS側のバックグラウンドタスクスケジューラーから呼ばれる
  /// 1日1回程度の実行を想定
  static Future<void> backgroundTask() async {
    try {
      final scheduler = ReminderScheduler();
      await scheduler.scheduleAll();
    } catch (e) {
      print('[ReminderScheduler] Error in background task: $e');
      // バックグラウンドタスクのエラーは記録のみ（クラッシュさせない）
    }
  }
}
