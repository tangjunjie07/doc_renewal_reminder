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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// リマインダースケジューラー（3段階防御システム）
/// 
/// 通知ID体系:
/// - documentId * 1000 + 0: 第一防衛線（遠期唤醒：単発通知）
/// - documentId * 1000 + 1: 第二防衛線（近期催办：毎日ループ）
/// - documentId * 1000 + 2: 第三防衛線（過期轰炸：最終警告）
/// 
/// 特徴:
/// - RepeatInterval.daily で永久ループ（アプリ起動不要）
/// - 20証件 × 3配額 = 60配額（iOS 64制限以下）
/// - ユーザーがキャンセルするまで継続
class ReminderScheduler {
  final NotificationService _notificationService;
  final ReminderEngine _reminderEngine;

  // 高危期の開始時期（有効期限の何日前から第二防衛線を開始するか）
  static const int highRiskDaysBefore = 30;

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
          print('[ReminderScheduler] Error scheduling notification for document ${state.documentId}: $e');
        }
      }
      
      print('[ReminderScheduler] ✅ Scheduled notifications for ${remindingStates.length} documents');
    } catch (e) {
      print('[ReminderScheduler] ❌ Error in scheduleAll: $e');
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
      print('[ReminderScheduler] Error scheduling for document $documentId: $e');
      rethrow;
    }
  }

  /// 証件の通知をキャンセル（すべての防衛線）
  Future<void> cancelForDocument(int documentId) async {
    try {
      await _notificationService.cancel(documentId * 1000 + 0); // 第一防衛線
      await _notificationService.cancel(documentId * 1000 + 1); // 第二防衛線
      await _notificationService.cancel(documentId * 1000 + 2); // 第三防衛線
      // 有効期限日用の特別通知もキャンセル（ID: documentId*1000 + 999）
      await _notificationService.cancel(documentId * 1000 + 999);
      print('[ReminderScheduler] ✅ Cancelled all notifications for document $documentId');
    } catch (e) {
      print('[ReminderScheduler] Error canceling notification for document $documentId: $e');
      rethrow;
    }
  }

  /// ReminderStateから通知をスケジュール（3段階防御）
  Future<void> _scheduleForDocument(ReminderState state) async {
    try {
      // 証件情報を取得
      final document = await DocumentRepository.getById(state.documentId);
      if (document == null) {
        print('[ReminderScheduler] Document not found: ${state.documentId}');
        return;
      }

      // メンバー情報を取得
      final member = await FamilyRepository.getById(document.memberId);
      if (member == null) {
        print('[ReminderScheduler] Member not found: ${document.memberId}');
        return;
      }

      // ポリシーを取得
      final policy = await PolicyService.getPolicyForDocument(document);

      // 通知内容を生成
      final title = await _generateNotificationTitle(document, member);
      final body = await _generateNotificationBody(document, member, policy);
      final payload = 'document:${document.id}';

      // リマインダー開始日と高危期開始日を計算
      final reminderStartDate = document.expiryDate.subtract(
        Duration(days: document.customReminderDays ?? policy.daysBeforeExpiry),
      );
      final highRiskDate = document.expiryDate.subtract(
        Duration(days: highRiskDaysBefore),
      );
      final now = DateTime.now();

      print('[ReminderScheduler] Document ${document.id}: reminderStart=$reminderStartDate, highRisk=$highRiskDate, expiry=${document.expiryDate}');

      // 第一防衛線: 遠期唤醒（リマインダー開始日の単発通知）
      final reminderStartDateOnly = DateTime(reminderStartDate.year, reminderStartDate.month, reminderStartDate.day);
      final todayOnly = DateTime(now.year, now.month, now.day);
      
      if (reminderStartDateOnly.isAfter(todayOnly)) {
        // 未来の日付 → スケジュール
        await _notificationService.scheduleNotification(
          id: document.id! * 1000 + 0,
          title: title,
          body: body,
          scheduledDate: DateTime(
            reminderStartDate.year,
            reminderStartDate.month,
            reminderStartDate.day,
            9, // 09:00
            0,
          ),
          payload: payload,
        );
        print('[ReminderScheduler]   第一防衛線: ${reminderStartDate.toIso8601String()}');
      } else if (reminderStartDateOnly.isAtSameMomentAs(todayOnly) || reminderStartDateOnly.isBefore(todayOnly)) {
        // 今日または過去 → 10秒後に通知（バックグラウンドで確実に表示）
        final scheduledTime = now.add(const Duration(seconds: 10));
        await _notificationService.scheduleNotification(
          id: document.id! * 1000 + 0,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
          payload: payload,
        );
        print('[ReminderScheduler]   第一防衛線: 10秒後に送信（${reminderStartDateOnly.isBefore(todayOnly) ? '過去日付' : '今日が開始日'}）');
      }

      // 第二防衛線: 近期催办（高危期から毎日ループ）★核心★
      if (highRiskDate.isAfter(now)) {
        await _notificationService.scheduleRepeatingNotification(
          id: document.id! * 1000 + 1,
          title: title,
          body: '⚠️ ${body}', // 強調表示
          startDate: DateTime(
            highRiskDate.year,
            highRiskDate.month,
            highRiskDate.day,
            9, // 09:00
            0,
          ),
          interval: RepeatInterval.daily,
          payload: payload,
        );
        print('[ReminderScheduler]   第二防衛線: ${highRiskDate.toIso8601String()} から毎日ループ');
      } else if (document.expiryDate.isAfter(now)) {
        // 既に高危期に入っている → 今日から毎日ループ
        await _notificationService.scheduleRepeatingNotification(
          id: document.id! * 1000 + 1,
          title: title,
          body: '⚠️ ${body}',
          startDate: DateTime(now.year, now.month, now.day, 9, 0),
          interval: RepeatInterval.daily,
          payload: payload,
        );
        print('[ReminderScheduler]   第二防衛線: 今日から毎日ループ（高危期進行中）');
      }

      // 第三防衛線: 過期轰炸（有効期限日から毎日ループ）
      final expiryDate = document.expiryDate;
      if (expiryDate.isAfter(now)) {
        final languageCode = await NotificationLocalizations.getLanguageCode();
        final expiredBody = NotificationLocalizations.getExpiredBody(languageCode);
        
        await _notificationService.scheduleRepeatingNotification(
          id: document.id! * 1000 + 2,
          title: '🚨 ${title}',
          body: expiredBody,
          startDate: DateTime(
            expiryDate.year,
            expiryDate.month,
            expiryDate.day,
            9, // 09:00
            0,
          ),
          interval: RepeatInterval.daily,
          payload: payload,
        );
        print('[ReminderScheduler]   第三防衛線: ${expiryDate.toIso8601String()} から毎日ループ');
      } else {
        // 既に有効期限切れ → 今日から毎日ループ
        final languageCode = await NotificationLocalizations.getLanguageCode();
        final expiredBody = NotificationLocalizations.getExpiredBody(languageCode);
        
        await _notificationService.scheduleRepeatingNotification(
          id: document.id! * 1000 + 2,
          title: '🚨 ${title}',
          body: expiredBody,
          startDate: DateTime(now.year, now.month, now.day, 9, 0),
          interval: RepeatInterval.daily,
          payload: payload,
        );
        print('[ReminderScheduler]   第三防衛線: 今日から毎日ループ（期限切れ）');
      }
    } catch (e) {
      print('[ReminderScheduler] ❌ Error scheduling notification: $e');
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
      final languageCode = await NotificationLocalizations.getLanguageCode();
      return NotificationLocalizations.getNotificationTitleGeneric(languageCode);
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
}
