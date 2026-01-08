import 'package:flutter/material.dart';
import 'biometric_auth_service.dart';
import 'localization/app_localizations.dart';

/// 生体認証ゲート画面
/// 
/// アプリ起動時に生体認証が必要な場合に表示される画面
/// 認証成功後に実際のアプリコンテンツを表示
class BiometricGate extends StatefulWidget {
  final Widget child;

  const BiometricGate({
    super.key,
    required this.child,
  });

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  bool _isCheckingAuth = true; // 認証チェック中フラグ（初期: true）
  DateTime? _lastPausedTime;
  bool _reauthRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Widgetツリーの構築完了を待ってから認証チェック
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthenticationRequired();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused) {
      // アプリがバックグラウンドに移行
      _lastPausedTime = DateTime.now();
      // バックグラウンド移行時には認証セッションを中断しておく
      try {
        BiometricAuthService.instance.stopAuthentication();
      } catch (e) {
        debugPrint('[BiometricGate] stopAuthentication error: $e');
      }
    } else if (state == AppLifecycleState.resumed) {
      // アプリがフォアグラウンドに復帰
      // 復帰時も念のため既存の認証を中断してから再確認
      try {
        BiometricAuthService.instance.stopAuthentication();
      } catch (e) {
        debugPrint('[BiometricGate] stopAuthentication error on resume: $e');
      }
      _checkReauthenticationRequired();
    }
  }

  /// 起動時に認証が必要かチェック
  Future<void> _checkAuthenticationRequired() async {
    if (!mounted) return;
    
    try {
      final authService = BiometricAuthService.instance;
      final shouldAuth = await authService.shouldAuthenticateOnStartup();

      if (!shouldAuth) {
        // 認証不要の場合はそのまま通過
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isCheckingAuth = false;
          });
        }
        return;
      }

      // 生体認証が利用可能かチェック
      final canAuth = await authService.canCheckBiometrics();
      if (!canAuth) {
        // 生体認証が利用できない場合は設定を無効化してアプリを開く
        debugPrint('[BiometricGate] Biometrics not available, disabling auth');
        await authService.setBiometricAuthEnabled(false);
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isCheckingAuth = false;
          });
        }
        return;
      }

      // チェック完了、認証画面を表示
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }

      // 認証実行（1回のみ、失敗しても繰り返さない）
      await _authenticate();
    } catch (e) {
      debugPrint('[BiometricGate] Error in _checkAuthenticationRequired: $e');
      // エラーが発生した場合は認証をスキップしてアプリを開く
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isCheckingAuth = false;
        });
      }
    }
  }

  /// バックグラウンド復帰時の再認証チェック
  Future<void> _checkReauthenticationRequired() async {
    try {
      // 既に認証中の場合は何もしない（無限ループ防止）
      if (_isAuthenticating) {
        debugPrint('[BiometricGate] _checkReauthenticationRequired: already authenticating, skip');
        return;
      }

      // 再認証要求が既に出ていればスキップ
      if (_reauthRequested) {
        debugPrint('[BiometricGate] _checkReauthenticationRequired: reauth already requested, skip');
        return;
      }

      if (_isAuthenticated && _lastPausedTime != null) {
        final now = DateTime.now();
        final duration = now.difference(_lastPausedTime!);
        debugPrint('[BiometricGate] _checkReauthenticationRequired: duration=${duration.inMinutes}min');

        // 5分以上経過していたら再認証
        if (duration.inMinutes >= 5) {
          // 再認証フラグを立てて二重トリガーを防止
          _reauthRequested = true;
          if (mounted) {
            setState(() {
              _isAuthenticated = false;
            });
          }

          // lastPausedTimeをクリアして同じ復帰で何度も走らないようにする
          _lastPausedTime = null;

          await _authenticate();

          // 再認証完了後にフラグをリセット
          _reauthRequested = false;
        }
      }
    } catch (e) {
      debugPrint('[BiometricGate] Error in _checkReauthenticationRequired: $e');
    }
  }

  /// 生体認証を実行
  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    if (!mounted) return;

    if (mounted) {
      setState(() {
        _isAuthenticating = true;
      });
    }

    try {
      final authService = BiometricAuthService.instance;
      
      // AppLocalizationsの取得を安全に行う（初期化タイミングを考慮）
      String reason = 'アプリのロックを解除';
      try {
        // Widgetツリーが完全に構築されるまで少し待つ
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          if (l10n != null) {
            reason = l10n.unlockApp;
          }
        }
      } catch (e) {
        debugPrint('[BiometricGate] Failed to get localization: $e');
        // デフォルトの文字列を使用
      }
      
      // タイムアウト付きで認証実行（30秒）
      final authenticated = await authService.authenticate(
        reason: reason,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('[BiometricGate] Authentication timeout');
          return false;
        },
      );

      if (mounted) {
        setState(() {
          _isAuthenticated = authenticated;
          _isAuthenticating = false;
        });
        
        // 認証失敗時の処理
        if (!authenticated) {
          debugPrint('[BiometricGate] Authentication failed or cancelled');
          // 認証失敗時は再度プロンプトを表示しない
          // ユーザーが明示的にボタンを押すまで待つ
        } else {
          debugPrint('[BiometricGate] ✅ Authentication successful');
        }
      }
    } catch (e) {
      debugPrint('[BiometricGate] Authentication error: $e');
      // クラッシュ防止：エラー時は認証中状態を解除し、アプリはロックされたままにする
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      // 認証成功 → 通常のアプリ画面を表示
      return widget.child;
    }

    // 認証チェック中はシンプルなスプラッシュ画面を表示
    // （ローカライゼーションが初期化されるまで待つ）
    if (_isCheckingAuth) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    // AppLocalizationsが初期化されていない可能性があるため、安全に取得
    final l10n = AppLocalizations.of(context);
    
    // l10nがnullの場合はデフォルト文字列を使用（起動時のタイミング問題対策）
    final biometricRequired = l10n?.biometricRequired ?? '生体認証が必要です';
    final biometricRequiredDescription = l10n?.biometricRequiredDescription ?? 'アプリにアクセスするには生体認証が必要です';
    final authenticate = l10n?.authenticate ?? '認証する';

    // 認証待ち画面
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 80,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 32),
              Text(
                biometricRequired,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                biometricRequiredDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: 48),
              if (_isAuthenticating)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              else
                FilledButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(authenticate),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
