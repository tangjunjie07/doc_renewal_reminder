// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/notification_localizations.dart';
import '../../core/logger.dart';
// Biometric authentication removed
import 'service/data_export_service.dart';
import 'db_debug_page.dart';
import 'notification_list_page.dart';
import 'debug_notification_page.dart';
import 'language_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _savedLanguageCode;
  // biometric auth removed

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
    _loadNotificationPermissionStatus();
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

  // biometric settings removed

  bool? _notificationGranted = true;

  Future<void> _loadNotificationPermissionStatus() async {
    try {
      final status = await Permission.notification.status;
      if (mounted) {
        setState(() {
          _notificationGranted = status.isGranted;
        });
      }
    } catch (e) {
      AppLogger.error('[SettingsPage] Error loading notification permission: $e');
    }
  }

  Future<void> _handleNotificationPermissionTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        // 許可済みでもユーザーが設定画面を開きたい可能性があるため
        // スナックバーではなくダイアログで「設定を開く」選択を出す
        final open = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.notificationAlreadyGranted),
            content: Text(l10n.notificationPermissionGranted),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.openSettings)),
            ],
          ),
        );

        if (open == true) {
          await openAppSettings();
        }

        await _loadNotificationPermissionStatus();
        return;
      }

      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.notificationPermissionDialogTitle),
          content: Text(l10n.notificationPermissionDialogContent),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.notificationPermissionLater)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.notificationPermissionAllow)),
          ],
        ),
      );

      if (ok == true) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          final open = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.notificationPermissionDisabledTitle),
              content: Text(l10n.notificationPermissionDisabledContent),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.openSettings)),
              ],
            ),
          );

          if (open == true) {
            await openAppSettings();
          }
        }

        await _loadNotificationPermissionStatus();
      }
    } catch (e) {
      AppLogger.error('[SettingsPage] Error requesting notification permission: $e');
    }
  }

  // biometric toggle removed

  void _changeLanguage(BuildContext context, Locale locale) async {
    MyApp.setLocale(context, locale);
    // 通知用の言語設定も保存
    await NotificationLocalizations.saveLanguageCode(locale.languageCode);
    if (!mounted) return;
    setState(() {
      _savedLanguageCode = locale.languageCode;
    });
    // 言語切り替え後はpopせずにそのまま設定画面に残る
  }

  // Removed unused _isCurrentLocale helper (was unused and caused analyzer warning)

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
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // エクスポート実行
      final file = await DataExportService.createAndGetExportFile();
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        // ボタン位置を取得
        final box = context.findRenderObject() is RenderBox
            ? context.findRenderObject() as RenderBox
            : null;
        Rect rect;
        if (box != null) {
          final offset = box.localToGlobal(Offset.zero);
          rect = offset & box.size;
        } else {
          // fallback: 画面中央
          final size = MediaQuery.of(context).size;
          rect = Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 200,
            height: 200,
          );
        }
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Document Renewal Reminder Backup',
          text: l10n.shareBackupFile,
          sharePositionOrigin: rect,
        );
      } else {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Document Renewal Reminder Backup',
          text: l10n.shareBackupFile,
        );
      }

      // ローディング閉じる
      if (!mounted) return;
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
    } catch (e) {
      // ローディング閉じる
      if (!mounted) return;
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

      // iOSの場合、Documentsフォルダを初期ディレクトリに設定
      String? initialDirectory;
      if (!kIsWeb && Platform.isIOS) {
        try {
          final documentsDir = await getApplicationDocumentsDirectory();
          initialDirectory = documentsDir.path;
          AppLogger.log('[Import] 📂 初期ディレクトリ: $initialDirectory');
        } catch (e) {
          AppLogger.error('[Import] ⚠️ 初期ディレクトリ取得エラー: $e');
        }
      }

      // ファイル選択
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        initialDirectory: initialDirectory,
      );

      if (result == null) return;

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('ファイルパスが取得できません');
      }

      // ローディング表示
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // インポート実行
      final file = File(filePath);
      await DataExportService.importFromFile(file);
      
      // 再度インポート結果を取得
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final importResult = await DataExportService.importFromJson(data);

      // ローディング閉じる
      if (!mounted) return;
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
    } catch (e) {
      // ローディング閉じる（エラー時）
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Language selector (single product-level component)
          LanguageSelector(
            savedLanguageCode: _savedLanguageCode,
            onSelected: (code) {
              final locale = Locale(code);
              _changeLanguage(context, locale);
            },
          ),
          const Divider(thickness: 2),
          // データエクスポート/インポート
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.blue),
            title: Text(l10n.dataBackup),
            subtitle: Text(l10n.dataBackupDescription),
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
          // 通知許可はiOSで非表示（システム設定との不整合回避）
          if (!Platform.isIOS) ...[
            // 通知許可（説明→要求）
            ListTile(
              leading: Icon(
                Icons.notifications,
                color: _notificationGranted == null
                    ? Colors.orange
                    : (_notificationGranted == true ? Colors.green : Colors.grey),
              ),
              title: Text(l10n.notificationPermissionTitle),
              subtitle: Text(_notificationGranted == null
                  ? l10n.notificationPermissionStatusChecking
                  : (_notificationGranted == true
                      ? l10n.notificationPermissionGranted
                      : l10n.notificationPermissionDenied)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_notificationGranted == true) ...[
                    const Icon(Icons.check_circle, color: Colors.green),
                  ] else if (_notificationGranted == false) ...[
                    const Icon(Icons.cancel, color: Colors.grey),
                  ] else ...[
                    const SizedBox.shrink(),
                  ],
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _handleNotificationPermissionTap(context),
            ),
          ],

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
          // サポート・フィードバック
          ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.teal),
            title: Text(l10n.supportTitle),
            subtitle: Text(l10n.supportDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.support_agent, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(l10n.supportTitle),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.supportDialogContent),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            const githubUrl = 'https://github.com/tangjunjie07/doc_renewal_reminder/issues';
                            try {
                              final uri = Uri.parse(githubUrl);
                              final canLaunch = await canLaunchUrl(uri);
                              if (canLaunch) {
                                await launchUrl(uri);
                              }
                              // 失敗時は何も表示しない
                            } catch (e) {
                              // 例外時も何も表示しない
                            }
                          },
                          child: Text(l10n.githubButton),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final subject = Uri.encodeComponent(l10n.supportMailSubject);
                            final body = Uri.encodeComponent(l10n.supportMailBody);
                            final mailUrl = 'mailto:yuanlusky@gmail.com?subject=$subject&body=$body';
                            try {
                              final uri = Uri.parse(mailUrl);
                              final canLaunch = await canLaunchUrl(uri);
                              if (canLaunch) {
                                await launchUrl(uri);
                              }
                              // 失敗時は何も表示しない
                            } catch (e) {
                              // 例外時も何も表示しない
                            }
                          },
                          child: Text(l10n.mailButton),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ),
                    ],
                  ),
                  actions: [], // actionsは空に
                ),
              );
            },
          ),
          // デバッグ機能 - デバッグモードでのみ表示
          if (kDebugMode) ...[
            const Divider(thickness: 2),
            const ListTile(
              leading: Icon(Icons.developer_mode, color: Colors.purple),
              title: Text('開発者ツール'),
              subtitle: Text('デバッグ・テスト機能'),
            ),
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
        ],
      ),
    );
  }
}
