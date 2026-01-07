import '../../../features/documents/model/document.dart';
import '../../../features/renewal_policy/service/policy_service.dart';
import '../model/reminder_state.dart';
import '../repository/reminder_state_repository.dart';

/// リマインダーエンジン
/// 
/// リマインダーの開始日計算、状態遷移、一時停止期間管理を担当
class ReminderEngine {
  /// リマインダーチェック（全証件をスキャン）
  /// 
  /// - リマインダー期間に入った証件 → REMINDING状態に遷移
  /// - 一時停止期間が過ぎた証件 → REMINDING状態に復帰
  /// - 有効期限を更新した証件 → NORMAL状態にリセット
  Future<void> checkAllDocuments(List<Document> documents) async {
    try {
      for (final document in documents) {
        try {
          await checkDocument(document);
        } catch (e) {
          // 個別証件のエラーは記録して続行
          print('Error checking document ${document.id}: $e');
        }
      }

      // PAUSED状態で予定完了日を過ぎたものを自動再開
      await _resumeExpiredPausedStates();
    } catch (e) {
      print('Error in checkAllDocuments: $e');
      rethrow;
    }
  }

  /// 単一証件のリマインダーチェック
  Future<void> checkDocument(Document document) async {
    try {
      final existingState = await ReminderStateRepository.getByDocumentId(document.id!);
      final reminderStartDate = await PolicyService.calculateReminderStartDate(document);
      final now = DateTime.now();

      if (existingState == null) {
        // 状態が存在しない → 新規作成
        if (now.isAfter(reminderStartDate) || now.isAtSameMomentAs(reminderStartDate)) {
          // リマインダー期間に入っている → REMINDING状態で作成
          final newState = ReminderState.createNormal(document.id!)
              .startReminding(reminderStartDate);
          await ReminderStateRepository.insert(newState);
        } else {
          // まだリマインダー期間前 → NORMAL状態で作成
          final newState = ReminderState.createNormal(document.id!);
          await ReminderStateRepository.insert(newState);
        }
      } else {
        // 状態が存在する → 状態に応じた処理
        switch (existingState.status) {
          case ReminderStatus.normal:
            // リマインダー期間に入ったか確認
            if (now.isAfter(reminderStartDate) || now.isAtSameMomentAs(reminderStartDate)) {
              final updatedState = existingState.startReminding(reminderStartDate);
              await ReminderStateRepository.update(updatedState);
            }
            break;

          case ReminderStatus.reminding:
            // リマインダー開始日が変更された場合は更新
            if (existingState.reminderStartDate != reminderStartDate) {
              final updatedState = existingState.copyWith(
                reminderStartDate: reminderStartDate,
                updatedAt: DateTime.now(),
              );
              await ReminderStateRepository.update(updatedState);
            }
            break;

          case ReminderStatus.paused:
            // 一時停止中は何もしない（_resumeExpiredPausedStatesで処理）
            break;
        }
      }
    } catch (e) {
      print('Error checking document ${document.id}: $e');
      rethrow;
    }
  }

  /// ユーザーが「更新開始」を確認（REMINDING → PAUSED）
  Future<void> confirmRenewalStarted({
    required int documentId,
    required DateTime expectedFinishDate,
  }) async {
    try {
      final state = await ReminderStateRepository.getByDocumentId(documentId);
      if (state == null) {
        throw StateError('ReminderState not found for document $documentId');
      }

      if (state.status != ReminderStatus.reminding) {
        throw StateError('Can only pause from REMINDING state');
      }

      final pausedState = state.pause(expectedFinishDate);
      await ReminderStateRepository.update(pausedState);
    } catch (e) {
      print('Error confirming renewal started for document $documentId: $e');
      rethrow;
    }
  }

  /// ユーザーが証件を更新完了（任意状態 → NORMAL）
  Future<void> confirmRenewalCompleted(int documentId) async {
    try {
      final state = await ReminderStateRepository.getByDocumentId(documentId);
      if (state == null) {
        throw StateError('ReminderState not found for document $documentId');
      }

      final completedState = state.complete();
      await ReminderStateRepository.update(completedState);
    } catch (e) {
      print('Error confirming renewal completed for document $documentId: $e');
      rethrow;
    }
  }

  /// 一時停止期間が過ぎた証件を自動再開（PAUSED → REMINDING）
  Future<void> _resumeExpiredPausedStates() async {
    try {
      final expiredStates = await ReminderStateRepository.getExpiredPausedStates();
      for (final state in expiredStates) {
        try {
          final resumedState = state.resume();
          await ReminderStateRepository.update(resumedState);
        } catch (e) {
          print('Error resuming state for document ${state.documentId}: $e');
        }
      }
    } catch (e) {
      print('Error in _resumeExpiredPausedStates: $e');
      rethrow;
    }
  }

  /// リマインダー期間内かチェック
  Future<bool> isInReminderPeriod(Document document) async {
    return PolicyService.isInReminderPeriod(document);
  }

  /// 有効期限までの日数
  int daysUntilExpiry(Document document) {
    return PolicyService.daysUntilExpiry(document);
  }

  /// リマインダー開始日取得
  Future<DateTime> getReminderStartDate(Document document) async {
    return PolicyService.calculateReminderStartDate(document);
  }

  /// 通知送信記録（last_notification_date更新）
  Future<void> recordNotification(int documentId) async {
    final state = await ReminderStateRepository.getByDocumentId(documentId);
    if (state == null) {
      throw StateError('ReminderState not found for document $documentId');
    }

    final updatedState = state.recordNotification();
    await ReminderStateRepository.update(updatedState);
  }

  /// 次回通知日を計算
  /// 
  /// ポリシーのreminderFrequencyに基づいて計算
  /// - daily: 毎日
  /// - weekly: 週1回
  /// - biweekly: 2週間に1回
  /// - monthly: 月1回
  Future<DateTime?> getNextNotificationDate(int documentId) async {
    final state = await ReminderStateRepository.getByDocumentId(documentId);
    if (state == null || state.status != ReminderStatus.reminding) {
      return null;
    }

    // 証件を取得してポリシーを確認
    // （ここではDocumentRepositoryを直接呼ぶのを避けるため、呼び出し側で処理）
    // 実際の実装では、DocumentとPolicyを受け取る方が良い
    
    final lastNotification = state.lastNotificationDate;
    if (lastNotification == null) {
      // 初回通知はすぐに送る
      return DateTime.now();
    }

    // ここではdailyとして扱う（実際はポリシーから取得）
    return lastNotification.add(const Duration(days: 1));
  }
}
