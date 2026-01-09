import '../../../core/logger.dart';

/// Biometric feature removed: provide a harmless stub for compatibility.
class BiometricAuthService {
  static final BiometricAuthService instance = BiometricAuthService._();
  BiometricAuthService._();

  Future<bool> canCheckBiometrics() async => false;
  Future<List<dynamic>> getAvailableBiometrics() async => [];
  Future<bool> authenticate({required String reason}) async => false;
  Future<bool> isBiometricAuthEnabled() async => false;
  Future<void> setBiometricAuthEnabled(bool enabled) async {}
  Future<bool> shouldAuthenticateOnStartup() async => false;
  Future<void> printBiometricInfo() async {
    AppLogger.log('Biometric feature removed');
  }
  Future<void> stopAuthentication() async {}
}
