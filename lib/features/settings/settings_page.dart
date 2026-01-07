import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../app.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/notification_localizations.dart';
import '../../core/background/background_task_service.dart';
import 'service/data_export_service.dart';
import 'db_debug_page.dart';
import 'notification_list_page.dart';
import 'debug_notification_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _savedLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code');
    if (mounted) {
      setState(() {
        _savedLanguageCode = savedCode;
      });
    }
  }

  void _changeLanguage(BuildContext context, Locale locale) async {
    MyApp.setLocale(context, locale);
    // 通知用の言語設定も保存
    await NotificationLocalizations.saveLanguageCode(locale.languageCode);
    if (context.mounted) {
      setState(() {
        _savedLanguageCode = locale.languageCode;
      });
      // 言語切り替え後はpopせずにそのまま設定画面に残る
    }
  }

  bool _isCurrentLocale(BuildContext context, String languageCode) {
    // 保存された言語がある場合はそれを使用、なければLocalizationsから取得
    if (_savedLanguageCode != null) {
      return _savedLanguageCode == languageCode;
    }
    final currentLocale = Localizations.localeOf(context);
    return currentLocale.languageCode == languageCode;
  }

  // データエクスポート
  Future<void> _exportData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // 確認ダイアログ
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.upload_file, color: Colors.green),
              const SizedBox(width: 12),
              Text(l10n.exportData),
            ],
          ),
          content: Text(l10n.exportDataConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(l10n.export),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // ローディング表示
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // エクスポート実行
      await DataExportService.shareFile();

      // ローディング閉じる
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(l10n.exportSuccess),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // ローディング閉じる
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.exportFailed}: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // データインポート
  Future<void> _importData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // 警告ダイアログ
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 12),
              Text(l10n.importData),
            ],
          ),
          content: Text(l10n.importDataWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text(l10n.import),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // ファイル選択
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('ファイルパスが取得できません');
      }

      // ローディング表示
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // インポート実行
      final file = File(filePath);
      await DataExportService.importFromFile(file);
      
      // 再度インポート結果を取得
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final importResult = await DataExportService.importFromJson(data);

      // ローディング閉じる
      if (context.mounted) {
        Navigator.pop(context);

        if (importResult.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.importSuccess(
                        importResult.memberCount,
                        importResult.documentCount,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.importFailed}: ${importResult.error}')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // ローディング閉じる（エラー時）
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${l10n.importFailed}: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(l10n.changeAppLanguage),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              _isCurrentLocale(context, 'en') ? Icons.check_circle : Icons.circle_outlined,
              color: _isCurrentLocale(context, 'en') ? Colors.green : null,
            ),
            title: const Text('English'),
            trailing: _isCurrentLocale(context, 'en') 
                ? const Icon(Icons.check, color: Colors.green) 
                : null,
            onTap: () => _changeLanguage(context, const Locale('en')),
          ),
          ListTile(
            leading: Icon(
              _isCurrentLocale(context, 'zh') ? Icons.check_circle : Icons.circle_outlined,
              color: _isCurrentLocale(context, 'zh') ? Colors.green : null,
            ),
            title: const Text('中文 (Chinese)'),
            trailing: _isCurrentLocale(context, 'zh') 
                ? const Icon(Icons.check, color: Colors.green) 
                : null,
            onTap: () => _changeLanguage(context, const Locale('zh')),
          ),
          ListTile(
            leading: Icon(
              _isCurrentLocale(context, 'ja') ? Icons.check_circle : Icons.circle_outlined,
              color: _isCurrentLocale(context, 'ja') ? Colors.green : null,
            ),
            title: const Text('日本語 (Japanese)'),
            trailing: _isCurrentLocale(context, 'ja') 
                ? const Icon(Icons.check, color: Colors.green) 
                : null,
            onTap: () => _changeLanguage(context, const Locale('ja')),
          ),
          const Divider(thickness: 2),
          // データエクスポート/インポート
          const ListTile(
            leading: Icon(Icons.backup, color: Colors.blue),
            title: Text('データバックアップ'),
            subtitle: Text('データのエクスポート・インポート'),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Colors.green),
            title: Text(l10n.exportData),
            subtitle: Text(l10n.exportDataDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.orange),
            title: Text(l10n.importData),
            subtitle: Text(l10n.importDataDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _importData(context),
          ),
          const Divider(thickness: 2),
          // 通知情報一覧
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: Colors.orange),
            title: Text(l10n.notificationList),
            subtitle: Text(l10n.viewScheduledNotifications),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationListPage(),
                ),
              );
            },
          ),
          // 通知デバッグ
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.red),
            title: const Text('通知デバッグ'),
            subtitle: const Text('通知のテストと調査'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DebugNotificationPage(),
                ),
              );
            },
          ),
          // バックグラウンドタスク設定（デバッグモードでのみ表示）
          if (kDebugMode && !kIsWeb) ...[
            const Divider(thickness: 2),
            const ListTile(
              leading: Icon(Icons.work, color: Colors.purple),
              title: Text('バックグラウンドタスク'),
              subtitle: Text('アプリ終了時もリマインダーチェック'),
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('テストタスクを実行'),
              subtitle: const Text('10秒後に一回限りのタスクを実行'),
              onTap: () async {
                try {
                  await BackgroundTaskService.registerOneOffTask();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ テストタスクを登録しました（10秒後に実行）'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ エラー: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('定期タスクを再登録'),
              subtitle: const Text('24時間ごとのタスクを再設定'),
              onTap: () async {
                try {
                  await BackgroundTaskService.registerPeriodicTask();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ 定期タスクを再登録しました'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ エラー: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('全タスクをキャンセル'),
              subtitle: const Text('すべてのバックグラウンドタスクを停止'),
              onTap: () async {
                try {
                  await BackgroundTaskService.cancelAllTasks();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ 全タスクをキャンセルしました'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ エラー: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
          // Database Debug - デバッグモードでのみ表示
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.storage, color: Colors.blue),
              title: Text(l10n.databaseDebug),
              subtitle: Text(l10n.viewDatabaseStatus),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DbDebugPage(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
