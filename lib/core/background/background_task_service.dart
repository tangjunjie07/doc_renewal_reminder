import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../database/db_provider.dart';
import '../../features/reminder/service/reminder_engine.dart';
import '../../features/reminder/service/reminder_scheduler.dart';
import '../../features/documents/model/document.dart';
import '../../features/documents/repository/document_repository.dart';

/// バックグラウンドタスクサービス
/// アプリが完全に終了している場合でもリマインダーをチェック
class BackgroundTaskService {
  static const String _taskName = 'documentReminderCheck';
  static const String _uniqueTaskName = 'com.docreminder.dailyCheck';

  /// バックグラウンドタスクのコールバック関数
  /// 注意: この関数はアプリのmain isolateとは別のisolateで実行される
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        debugPrint('[BackgroundTask] 🔄 バックグラウンドタスク開始: $task');
        
        switch (task) {
          case _taskName:
            await _performReminderCheck();
            break;
          default:
            debugPrint('[BackgroundTask] ⚠️ 不明なタスク: $task');
        }
        
        debugPrint('[BackgroundTask] ✅ バックグラウンドタスク完了');
        return Future.value(true);
      } catch (e) {
        debugPrint('[BackgroundTask] ❌ バックグラウンドタスクエラー: $e');
        return Future.value(false);
      }
    });
  }

  /// リマインダーチェック実行
  static Future<void> _performReminderCheck() async {
    try {
      // データベース初期化
      await DBProvider.database;
      
      // 全証件を取得
      final documents = await DocumentRepository.getAll();
      
      // リマインダーエンジンでチェック
      final reminderEngine = ReminderEngine();
      await reminderEngine.checkAllDocuments(documents);
      
      // リマインダースケジューラーで通知をスケジュール
      final reminderScheduler = ReminderScheduler();
      await reminderScheduler.scheduleAll();
      
      debugPrint('[BackgroundTask] 📋 リマインダーチェック完了');
    } catch (e) {
      debugPrint('[BackgroundTask] ❌ リマインダーチェックエラー: $e');
      rethrow;
    }
  }

  /// バックグラウンドタスクサービスの初期化
  static Future<void> initialize() async {
    try {
      debugPrint('[BackgroundTask] 🚀 バックグラウンドタスクサービス初期化開始');
      
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode, // デバッグモードでログを出力
      );
      
      debugPrint('[BackgroundTask] ✅ バックグラウンドタスクサービス初期化完了');
    } catch (e) {
      debugPrint('[BackgroundTask] ❌ 初期化エラー: $e');
      rethrow;
    }
  }

  /// 定期タスクの登録
  /// Android: 毎日1回実行（最小間隔15分、推奨24時間）
  /// iOS: システムが決定（不定期、通常1日数回）
  static Future<void> registerPeriodicTask() async {
    try {
      debugPrint('[BackgroundTask] 📅 定期タスク登録開始');
      
      await Workmanager().registerPeriodicTask(
        _uniqueTaskName,
        _taskName,
        frequency: const Duration(hours: 24), // 24時間ごと
        initialDelay: const Duration(minutes: 15), // 初回実行まで15分待機
        existingWorkPolicy: ExistingWorkPolicy.replace, // 既存のタスクを置き換え
        constraints: Constraints(
          networkType: NetworkType.not_required, // ネットワーク不要
          requiresBatteryNotLow: false, // バッテリー低下時も実行
          requiresCharging: false, // 充電中でなくても実行
          requiresDeviceIdle: false, // デバイスアイドル不要
          requiresStorageNotLow: false, // ストレージ不足時も実行
        ),
        tag: 'reminder_check', // タグ付け
      );
      
      debugPrint('[BackgroundTask] ✅ 定期タスク登録完了');
    } catch (e) {
      debugPrint('[BackgroundTask] ❌ 定期タスク登録エラー: $e');
      rethrow;
    }
  }

  /// 一回限りのタスクを登録（テスト用）
  static Future<void> registerOneOffTask() async {
    try {
      debugPrint('[BackgroundTask] 🧪 一回限りタスク登録開始');
      
      await Workmanager().registerOneOffTask(
        'oneoff-${DateTime.now().millisecondsSinceEpoch}',
        _taskName,
        initialDelay: const Duration(seconds: 10), // 10秒後に実行
        constraints: Constraints(
          networkType: NetworkType.not_required,
        ),
      );
      
      debugPrint('[BackgroundTask] ✅ 一回限りタスク登録完了');
    } catch (e) {
      debugPrint('[BackgroundTask] ❌ 一回限りタスク登録エラー: $e');
      rethrow;
    }
  }

  /// すべてのタスクをキャンセル
  static Future<void> cancelAllTasks() async {
    try {
      debugPrint('[BackgroundTask] 🗑️ 全タスクキャンセル開始');
      await Workmanager().cancelAll();
      debugPrint('[BackgroundTask] ✅ 全タスクキャンセル完了');
    } catch (e) {
      debugPrint('[BackgroundTask] ❌ タスクキャンセルエラー: $e');
      rethrow;
    }
  }

  /// 特定のタスクをキャンセル
  static Future<void> cancelTask() async {
    try {
      debugPrint('[BackgroundTask] 🗑️ タスクキャンセル開始: $_uniqueTaskName');
      await Workmanager().cancelByUniqueName(_uniqueTaskName);
      debugPrint('[BackgroundTask] ✅ タスクキャンセル完了');
    } catch (e) {
      debugPrint('[BackgroundTask] ❌ タスクキャンセルエラー: $e');
      rethrow;
    }
  }
}
