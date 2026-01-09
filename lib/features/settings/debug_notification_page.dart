import 'package:flutter/material.dart';
import '../../core/notification_service.dart';
import '../../core/logger.dart';
import '../../core/calendar_service.dart';
import '../../features/reminder/service/reminder_scheduler.dart';
import '../../features/documents/repository/document_repository.dart';
import '../../features/family/repository/family_repository.dart';
import '../../features/reminder/repository/reminder_state_repository.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

/// 通知デバッグページ
/// 通知が動作しない原因を調査し、テスト通知を送信
class DebugNotificationPage extends StatefulWidget {
  const DebugNotificationPage({super.key});

  @override
  State<DebugNotificationPage> createState() => _DebugNotificationPageState();
}

class _DebugNotificationPageState extends State<DebugNotificationPage> {
  final List<String> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  void _log(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
    AppLogger.log('[DebugNotification] $message');
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _log('🔍 通知診断開始...');

      // 1. 通知サービスの状態確認
      _log('1️⃣ 通知サービスの確認...');
      await NotificationService.instance.initialize();
      _log('   ✅ 通知サービス初期化済み');

      // 2. 予定通知の確認
      _log('2️⃣ 予定通知の確認...');
      final pending = await NotificationService.instance.getPendingNotifications();
      _log('   📋 予定通知数: ${pending.length}件');
      for (var notification in pending) {
        _log('      - ID: ${notification.id}, Title: ${notification.title}');
      }

      // 3. データベースの証件数確認
      _log('3️⃣ データベースの確認...');
      final documents = await DocumentRepository.getAll();
      _log('   📄 証件数: ${documents.length}件');
      
      if (documents.isEmpty) {
        _log('   ⚠️ 証件が登録されていません');
      } else {
        for (var doc in documents) {
          _log('      - ID: ${doc.id}, Type: ${doc.documentType}, Expiry: ${doc.expiryDate}');
          
          // リマインダー状態を確認
          final state = await ReminderStateRepository.getByDocumentId(doc.id!);
          if (state != null) {
            _log('        Status: ${state.status}, Last Notified: ${state.lastNotificationDate}');
          } else {
            _log('        ⚠️ リマインダー状態が未作成');
          }
        }
      }

      // 4. 家族メンバー確認
      _log('4️⃣ 家族メンバーの確認...');
      final members = await FamilyRepository.getAll();
      _log('   👥 メンバー数: ${members.length}人');

      // 5. リマインダースケジュール実行
      _log('5️⃣ リマインダースケジュール実行...');
      final scheduler = ReminderScheduler();
      await scheduler.scheduleAll();
      _log('   ✅ スケジュール完了');

      // 6. スケジュール後の予定通知再確認
      _log('6️⃣ スケジュール後の予定通知確認...');
      final pendingAfter = await NotificationService.instance.getPendingNotifications();
      _log('   📋 予定通知数: ${pendingAfter.length}件');
      
      if (pendingAfter.isEmpty) {
        _log('   ⚠️ 予定通知が作成されませんでした');
        _log('   💡 考えられる原因:');
        _log('      1. 証件の有効期限が遠すぎる（通知期間外）');
        _log('      2. 証件が既に期限切れ');
        _log('      3. 更新ポリシーが設定されていない');
      }

      _log('✅ 診断完了！');
    } catch (e) {
      _log('❌ エラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      _log('📤 テスト通知を送信...');
      await NotificationService.instance.showNotification(
        id: 99999,
        title: 'テスト通知',
        body: 'これはテスト通知です。表示されれば通知機能は正常です。',
      );
      _log('✅ テスト通知送信完了');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('テスト通知を送信しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _log('❌ テスト通知エラー: $e');
    }
  }

  Future<void> _scheduleTestNotification() async {
    try {
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
      _log('⏰ 10秒後にテスト通知をスケジュール...');
      _log('   予定時刻: $scheduledTime');
      
      await NotificationService.instance.scheduleNotification(
        id: 99998,
        title: 'スケジュールテスト通知',
        body: '10秒後に表示されるテスト通知です',
        scheduledDate: scheduledTime,
      );
      
      _log('✅ テスト通知スケジュール完了');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('10秒後にテスト通知が表示されます'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      _log('❌ スケジュールエラー: $e');
    }
  }

  Future<void> _addToCalendar() async {
    try {
      _log('📅 カレンダーテスト...');
      
      final Event event = Event(
        title: 'カレンダーテスト',
        description: 'これはadd_2_calendarパッケージのテストです',
        location: '',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 1)),
        allDay: false,
      );
      
      final added = await CalendarService.addEvent(event);

      _log(added ? '✅ カレンダーに追加' : '❌ カレンダー追加失敗');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(added ? 'カレンダーに追加しました' : 'カレンダー追加に失敗しました'),
            backgroundColor: added ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      _log('❌ カレンダーエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知デバッグ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runDiagnostics,
            tooltip: '再診断',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _sendTestNotification,
                        icon: const Icon(Icons.send),
                        label: const Text('即時通知テスト'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _scheduleTestNotification,
                        icon: const Icon(Icons.schedule),
                        label: const Text('10秒後通知'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addToCalendar,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('カレンダー追加テスト'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: log.contains('❌') || log.contains('⚠️')
                                ? Colors.red
                                : log.contains('✅')
                                    ? Colors.green
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
