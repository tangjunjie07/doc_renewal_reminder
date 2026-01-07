import '../model/renewal_policy.dart';

/// 証件タイプ別デフォルト更新ポリシー定義
/// 
/// 各証件タイプには適切なリマインダー期間が設定されています：
/// - 在留カード: 3ヶ月前（入管での更新申請期間）
/// - パスポート: 6ヶ月前（申請〜受取に時間がかかる）
/// - 運転免許証: 1ヶ月前（誕生日の前後1ヶ月）
/// - 保険証: 自動更新のため通知不要
/// - マイナンバーカード: 3ヶ月前
/// - その他: 1ヶ月前
class DefaultPolicies {
  /// 在留カード用デフォルトポリシー
  /// 
  /// 入管での更新申請は期限の3ヶ月前から可能
  static RenewalPolicy get residenceCard => RenewalPolicy(
        documentType: 'residence_card',
        daysBeforeExpiry: 90, // 3ヶ月前
        reminderFrequency: 'weekly',
        autoRenewable: false,
        notes: 'policyNotesResidenceCard',
      );

  /// パスポート用デフォルトポリシー
  /// 
  /// 申請から受取まで時間がかかるため、6ヶ月前から準備
  static RenewalPolicy get passport => RenewalPolicy(
        documentType: 'passport',
        daysBeforeExpiry: 180, // 6ヶ月前
        reminderFrequency: 'biweekly',
        autoRenewable: false,
        notes: 'policyNotesPassport',
      );

  /// 運転免許証用デフォルトポリシー
  /// 
  /// 誕生日の前後1ヶ月が更新期間
  static RenewalPolicy get driversLicense => RenewalPolicy(
        documentType: 'drivers_license',
        daysBeforeExpiry: 30, // 1ヶ月前
        reminderFrequency: 'weekly',
        autoRenewable: false,
        notes: 'policyNotesDriversLicense',
      );

  /// 健康保険証用デフォルトポリシー
  /// 
  /// 通常は自動更新のため、リマインダー不要
  static RenewalPolicy get insuranceCard => RenewalPolicy(
        documentType: 'insurance_card',
        daysBeforeExpiry: 30, // 1ヶ月前（念のため）
        reminderFrequency: 'monthly',
        autoRenewable: true,
        notes: 'policyNotesInsuranceCard',
      );

  /// マイナンバーカード用デフォルトポリシー
  /// 
  /// 有効期限の3ヶ月前から更新手続き可能
  static RenewalPolicy get mynumberCard => RenewalPolicy(
        documentType: 'mynumber_card',
        daysBeforeExpiry: 90, // 3ヶ月前
        reminderFrequency: 'biweekly',
        autoRenewable: false,
        notes: 'policyNotesMynumberCard',
      );

  /// その他の証件用デフォルトポリシー
  /// 
  /// 汎用的な設定（1ヶ月前）
  static RenewalPolicy get other => RenewalPolicy(
        documentType: 'other',
        daysBeforeExpiry: 30, // 1ヶ月前
        reminderFrequency: 'weekly',
        autoRenewable: false,
        notes: 'policyNotesOther',
      );

  /// 証件タイプに対応するデフォルトポリシーを取得
  /// 
  /// [documentType] 証件タイプ
  /// 戻り値: 対応するデフォルトポリシー
  static RenewalPolicy getByDocumentType(String documentType) {
    switch (documentType) {
      case 'residence_card':
        return residenceCard;
      case 'passport':
        return passport;
      case 'drivers_license':
        return driversLicense;
      case 'insurance_card':
        return insuranceCard;
      case 'mynumber_card':
        return mynumberCard;
      case 'other':
      default:
        return other;
    }
  }

  /// すべてのデフォルトポリシーをリストで取得
  static List<RenewalPolicy> get all => [
        residenceCard,
        passport,
        driversLicense,
        insuranceCard,
        mynumberCard,
        other,
      ];

  /// 証件タイプの表示名キーを取得（AppLocalizationsで変換が必要）
  static String getDocumentTypeLabelKey(String documentType) {
    switch (documentType) {
      case 'residence_card':
        return 'documentTypeResidenceCard';
      case 'passport':
        return 'documentTypePassport';
      case 'drivers_license':
        return 'documentTypeDriversLicense';
      case 'insurance_card':
        return 'documentTypeHealthInsurance';
      case 'mynumber_card':
        return 'documentTypeMyNumber';
      case 'other':
        return 'documentTypeOther';
      default:
        return 'documentTypeOther';
    }
  }

  /// リマインダー頻度の表示名キーを取得（AppLocalizationsで変換が必要）
  static String getReminderFrequencyLabelKey(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'reminderFrequencyDaily';
      case 'weekly':
        return 'reminderFrequencyWeekly';
      case 'biweekly':
        return 'reminderFrequencyBiweekly';
      case 'monthly':
        return 'reminderFrequencyMonthly';
      default:
        return 'reminderFrequencyWeekly';
    }
  }

  /// 証件タイプのデフォルト通知頻度を取得
  /// 
  /// [documentType] 証件タイプ
  /// 戻り値: デフォルトの通知頻度 ('daily' / 'weekly' / 'biweekly' / 'monthly')
  static String getDefaultReminderFrequency(String documentType) {
    final policy = getByDocumentType(documentType);
    return policy.reminderFrequency;
  }
}
