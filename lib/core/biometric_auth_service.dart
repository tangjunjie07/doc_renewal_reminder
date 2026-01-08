import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 生体認証サービス
/// Face ID / Touch ID / 指紋認証によるアプリロック機能を提供
class BiometricAuthService {
  static const String _biometricEnabledKey = 'biometric_auth_enabled';
  
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Singleton instance
  static final BiometricAuthService instance = BiometricAuthService._();
  
  BiometricAuthService._();

  /// 生体認証が利用可能かチェック
  /// 
  /// デバイスが生体認証をサポートし、かつ生体情報が登録されているかを確認
  /// 
  /// 戻り値: 
  /// - true: 生体認証が利用可能
  /// - false: 生体認証が利用不可（デバイス未対応または生体情報未登録）
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('[BiometricAuth] Error checking biometrics: $e');
      return false;
    }
  }

  /// 利用可能な生体認証タイプを取得
  /// 
  /// 戻り値: BiometricType のリスト
  /// - face: Face ID
  /// - fingerprint: Touch ID / 指紋認証
  /// - iris: 虹彩認証
  /// - strong: 強力な生体認証
  /// - weak: 弱い生体認証
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('[BiometricAuth] Error getting available biometrics: $e');
      return [];
    }
  }

  /// 生体認証を実行
  /// 
  /// パラメータ:
  /// - reason: 認証理由（ユーザーに表示される）
  /// 
  /// 戻り値:
  /// - true: 認証成功
  /// - false: 認証失敗またはキャンセル
  Future<bool> authenticate({required String reason}) async {
    try {
      // 生体認証が利用可能かチェック
      final canAuthenticate = await canCheckBiometrics();
      if (!canAuthenticate) {
        debugPrint('[BiometricAuth] Biometrics not available');
        return false;
      }

      // 認証実行
      bool didAuthenticate = false;
      try {
        didAuthenticate = await _localAuth.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(
            stickyAuth: false, // stickyAuthを無効化してライフサイクル問題を回避
            biometricOnly: true, // 生体認証のみ（PIN/パスワードフォールバック無効）
          ),
        );

        if (didAuthenticate) {
          debugPrint('[BiometricAuth] ✅ Authentication successful');
        } else {
          debugPrint('[BiometricAuth] ❌ Authentication failed');
        }

        return didAuthenticate;
      } finally {
        // 認証セッションが残っている可能性があるため、明示的に停止を試みる
        try {
          await _localAuth.stopAuthentication();
        } catch (e) {
          // 無視: プラットフォームによっては例外を投げることがある
          debugPrint('[BiometricAuth] stopAuthentication error: $e');
        }
      }
    } on PlatformException catch (e) {
      debugPrint('[BiometricAuth] ❌ Authentication error: $e');
      return false;
    }
  }

  /// 生体認証設定が有効かチェック
  /// 
  /// 戻り値:
  /// - true: ユーザーが生体認証を有効に設定
  /// - false: ユーザーが生体認証を無効に設定（デフォルト）
  Future<bool> isBiometricAuthEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false; // デフォルト: 無効
    } catch (e) {
      debugPrint('[BiometricAuth] Error reading biometric setting: $e');
      return false;
    }
  }

  /// 生体認証設定を保存
  /// 
  /// パラメータ:
  /// - enabled: true（有効）または false（無効）
  Future<void> setBiometricAuthEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      debugPrint('[BiometricAuth] Biometric auth ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('[BiometricAuth] Error saving biometric setting: $e');
      rethrow;
    }
  }

  /// 生体認証をアプリ起動時にチェックする必要があるか判定
  /// 
  /// 条件:
  /// 1. ユーザーが生体認証を有効に設定
  /// 2. デバイスが生体認証をサポート
  /// 
  /// 戻り値:
  /// - true: 認証が必要
  /// - false: 認証不要
  Future<bool> shouldAuthenticateOnStartup() async {
    final isEnabled = await isBiometricAuthEnabled();
    if (!isEnabled) {
      return false;
    }

    final canAuth = await canCheckBiometrics();
    return canAuth;
  }

  /// デバッグ用: 生体認証情報を出力
  Future<void> printBiometricInfo() async {
    final canAuth = await canCheckBiometrics();
    final biometrics = await getAvailableBiometrics();
    final isEnabled = await isBiometricAuthEnabled();

    debugPrint('[BiometricAuth] === Debug Info ===');
    debugPrint('[BiometricAuth] Can check biometrics: $canAuth');
    debugPrint('[BiometricAuth] Available biometrics: ${biometrics.map((b) => b.name).join(', ')}');
    debugPrint('[BiometricAuth] User enabled: $isEnabled');
    debugPrint('[BiometricAuth] Should authenticate: ${await shouldAuthenticateOnStartup()}');
  }

  /// 認証セッションを明示的に停止する（ライフサイクル復帰時の安全対策）
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
      debugPrint('[BiometricAuth] stopAuthentication called');
    } catch (e) {
      debugPrint('[BiometricAuth] stopAuthentication error: $e');
    }
  }
}
