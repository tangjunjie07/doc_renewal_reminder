import '../model/renewal_policy.dart';
import '../data/default_policies.dart';
import '../repository/renewal_policy_repository.dart';
import '../../documents/model/document.dart';

/// ポリシー管理サービス
/// 
/// 証件の更新ポリシーを管理し、リマインダー期間の計算を行います。
/// デフォルトポリシーとカスタムポリシーの両方をサポートします。
class PolicyService {
  /// 証件に適用されるポリシーを取得
  /// 
  /// 1. カスタムポリシーが設定されていればそれを使用
  /// 2. なければデフォルトポリシーを使用
  /// 
  /// [document] 対象の証件
  /// 戻り値: 適用されるポリシー
  static Future<RenewalPolicy> getPolicyForDocument(Document document) async {
    // カスタムポリシーがあるか確認
    if (document.policyId != null) {
      final customPolicy = await RenewalPolicyRepository.getById(document.policyId!);
      if (customPolicy != null) {
        return customPolicy;
      }
    }

    // なければデフォルトポリシーを返す
    return DefaultPolicies.getByDocumentType(document.documentType);
  }

  /// リマインダー開始日を計算
  /// 
  /// カスタムリマインダー日数が設定されていればそれを使用、
  /// なければポリシーで指定された日数を使用します。
  /// 
  /// [document] 対象の証件
  /// 戻り値: リマインダー開始日
  static Future<DateTime> calculateReminderStartDate(Document document) async {
    // カスタムリマインダー日数が設定されていればそれを使用
    if (document.customReminderDays != null) {
      return document.expiryDate.subtract(Duration(days: document.customReminderDays!));
    }
    
    // なければポリシーから取得
    final policy = await getPolicyForDocument(document);
    return document.expiryDate.subtract(Duration(days: policy.daysBeforeExpiry));
  }

  /// 現在リマインダー期間内かどうかを判定
  /// 
  /// [document] 対象の証件
  /// [currentDate] 現在日時（テスト用、省略時は現在時刻）
  /// 戻り値: リマインダー期間内ならtrue
  static Future<bool> isInReminderPeriod(
    Document document, {
    DateTime? currentDate,
  }) async {
    final now = currentDate ?? DateTime.now();
    final reminderStartDate = await calculateReminderStartDate(document);
    
    // リマインダー開始日 ≤ 現在日 ≤ 有効期限
    return !now.isBefore(reminderStartDate) && !now.isAfter(document.expiryDate);
  }

  /// 有効期限が切れているかどうかを判定
  /// 
  /// [document] 対象の証件
  /// [currentDate] 現在日時（テスト用、省略時は現在時刻）
  /// 戻り値: 有効期限切れならtrue
  static bool isExpired(Document document, {DateTime? currentDate}) {
    final now = currentDate ?? DateTime.now();
    return now.isAfter(document.expiryDate);
  }

  /// 有効期限までの日数を計算
  /// 
  /// [document] 対象の証件
  /// [currentDate] 現在日時（テスト用、省略時は現在時刻）
  /// 戻り値: 有効期限までの日数（過去の場合は負の値）
  static int daysUntilExpiry(Document document, {DateTime? currentDate}) {
    final now = currentDate ?? DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(
      document.expiryDate.year,
      document.expiryDate.month,
      document.expiryDate.day,
    );
    return expiryDate.difference(nowDate).inDays;
  }

  /// カスタムポリシーを作成
  /// 
  /// デフォルトポリシーをベースに、ユーザーがカスタマイズしたポリシーを作成します。
  /// 
  /// [documentType] 証件タイプ
  /// [daysBeforeExpiry] 有効期限の何日前からリマインダーを開始するか
  /// [reminderFrequency] リマインダーの頻度（daily/weekly/biweekly/monthly）
  /// [autoRenewable] 自動更新されるかどうか
  /// [notes] 備考
  /// 戻り値: 作成されたポリシーのID
  static Future<int> createCustomPolicy({
    required String documentType,
    required int daysBeforeExpiry,
    required String reminderFrequency,
    required bool autoRenewable,
    String? notes,
  }) async {
    final policy = RenewalPolicy(
      documentType: documentType,
      daysBeforeExpiry: daysBeforeExpiry,
      reminderFrequency: reminderFrequency,
      autoRenewable: autoRenewable,
      notes: notes,
    );

    return await RenewalPolicyRepository.insert(policy);
  }

  /// カスタムポリシーを更新
  /// 
  /// [policy] 更新するポリシー
  static Future<void> updateCustomPolicy(RenewalPolicy policy) async {
    await RenewalPolicyRepository.update(policy);
  }

  /// カスタムポリシーを削除
  /// 
  /// [policyId] 削除するポリシーのID
  static Future<void> deleteCustomPolicy(int policyId) async {
    await RenewalPolicyRepository.delete(policyId);
  }

  /// すべてのカスタムポリシーを取得
  /// 
  /// 戻り値: カスタムポリシーのリスト
  static Future<List<RenewalPolicy>> getAllCustomPolicies() async {
    return await RenewalPolicyRepository.getAll();
  }

  /// 次のリマインダー通知日を計算
  /// 
  /// リマインダー頻度に基づいて、次回の通知日を計算します。
  /// 
  /// [document] 対象の証件
  /// [lastNotificationDate] 最後に通知した日（省略時は現在日時）
  /// 戻り値: 次回の通知日
  static Future<DateTime> calculateNextNotificationDate(
    Document document, {
    DateTime? lastNotificationDate,
  }) async {
    final policy = await getPolicyForDocument(document);
    final baseDate = lastNotificationDate ?? DateTime.now();

    switch (policy.reminderFrequency) {
      case 'daily':
        return baseDate.add(const Duration(days: 1));
      case 'weekly':
        return baseDate.add(const Duration(days: 7));
      case 'biweekly':
        return baseDate.add(const Duration(days: 14));
      case 'monthly':
        return baseDate.add(const Duration(days: 30));
      default:
        return baseDate.add(const Duration(days: 7)); // デフォルトは週1回
    }
  }

  /// ポリシーの妥当性を検証
  /// 
  /// [daysBeforeExpiry] 有効期限の何日前か
  /// 戻り値: エラーメッセージのARBキー（問題なければnull）
  static String? validatePolicy({
    required int daysBeforeExpiry,
  }) {
    if (daysBeforeExpiry < 1) {
      return 'policyValidationMinDays';
    }
    if (daysBeforeExpiry > 365) {
      return 'policyValidationMaxDays';
    }
    return null;
  }
}
