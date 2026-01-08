import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知用のローカリゼーション
/// 
/// バックグラウンドで実行される通知では BuildContext が使えないため、
/// 保存された言語設定を使用してローカライズされた文字列を取得する
class NotificationLocalizations {
  static const String _languageCodeKey = 'app_language_code';
  
  /// 現在の言語コードを保存
  static Future<void> saveLanguageCode(String languageCode) async {
    if (kIsWeb) return; // Web版では通知未対応
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }
  
  /// 保存された言語コードを取得（デフォルト: ja）
  static Future<String> getLanguageCode() async {
    if (kIsWeb) return 'ja'; // Web版では通知未対応
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey) ?? 'ja';
  }
  
  /// 証件タイプの表示名を取得
  static String getDocumentTypeName(String documentType, String languageCode) {
    final translations = {
      'residence_card': {
        'en': 'Residence Card',
        'ja': '在留カード',
        'zh': '在留卡',
      },
      'passport': {
        'en': 'Passport',
        'ja': 'パスポート',
        'zh': '护照',
      },
      'drivers_license': {
        'en': "Driver's License",
        'ja': '運転免許証',
        'zh': '驾驶执照',
      },
      'health_insurance': {
        'en': 'Health Insurance Card',
        'ja': '健康保険証',
        'zh': '健康保险卡',
      },
      'my_number': {
        'en': 'My Number Card',
        'ja': 'マイナンバーカード',
        'zh': '个人编号卡',
      },
      'other': {
        'en': 'Other Document',
        'ja': 'その他の証件',
        'zh': '其他证件',
      },
    };
    
    return translations[documentType]?[languageCode] ?? documentType;
  }
  
  /// 通知タイトルを取得
  static String getNotificationTitle(String documentType, String languageCode) {
    final documentTypeName = getDocumentTypeName(documentType, languageCode);
    
    switch (languageCode) {
      case 'en':
        return 'Document Renewal Needed';
      case 'zh':
        return '$documentTypeName需要更新';
      case 'ja':
      default:
        return '${documentTypeName}の更新が必要です';
    }
  }
  
  /// 通知本文を取得
  static String getNotificationBody({
    required String memberName,
    required String documentType,
    required int daysUntilExpiry,
    required String languageCode,
  }) {
    final documentTypeName = getDocumentTypeName(documentType, languageCode);
    
    switch (languageCode) {
      case 'en':
        return "$memberName's $documentTypeName will expire in $daysUntilExpiry days";
      case 'zh':
        return '$memberName的$documentTypeName还有$daysUntilExpiry天就要过期了';
      case 'ja':
      default:
        return '${memberName}さんの${documentTypeName}はあと${daysUntilExpiry}日で有効期限が切れます';
    }
  }
  
  /// 通知本文（フォールバック用）
  static String getNotificationBodyGeneric(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Your document is approaching its expiration date. Please check.';
      case 'zh':
        return '您的证件有效期即将到期,请及时查看。';
      case 'ja':
      default:
        return '証件の有効期限が近づいています。確認してください。';
    }
  }

  /// 期限切れ通知の本文を取得（第三防衛線用）
  static String getExpiredBody(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Expired! Please renew immediately.';
      case 'zh':
        return '已过期！请立即更新。';
      case 'ja':
      default:
        return '期限切れ！至急更新してください';
    }
  }

  /// 通知タイトル（フォールバック用）
  static String getNotificationTitleGeneric(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'Document Renewal Required';
      case 'zh':
        return '证件需要更新';
      case 'ja':
      default:
        return '証件の更新が必要です';
    }
  }
}
