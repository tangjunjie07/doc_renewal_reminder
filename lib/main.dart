import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'features/renewal_policy/repository/renewal_policy_repository.dart';
import 'core/database/db_provider.dart';
import 'core/database/hive_provider.dart';
import 'core/notification_service.dart';
import 'core/localization/notification_localizations.dart';
import 'core/widgets/startup_debug_page.dart';
import 'core/background/background_task_service.dart';
import 'features/reminder/service/reminder_scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    // Initialize timezone data for notifications
    if (!kIsWeb) {
      tz.initializeTimeZones();
    }

    // Initialize database
    if (kIsWeb) {
      await HiveProvider.initialize();
    } else {
      await _initializeDatabase();
      // Initialize notification service for mobile/desktop
      await NotificationService.instance.initialize();
      // Initialize default language for notifications
      try {
        await NotificationLocalizations.getLanguageCode();
      } catch (e) {
        await NotificationLocalizations.saveLanguageCode('ja');
      }
      
      // ✅ Schedule all reminders on app startup (既存処理 - 削除しない)
      final scheduler = ReminderScheduler();
      await scheduler.scheduleAll();
      print('[Main] ✅ All reminders scheduled on app startup');
      
      // 🆕 Initialize background task service (追加処理)
      // Note: workmanager only supports Android/iOS
      if (defaultTargetPlatform == TargetPlatform.android || 
          defaultTargetPlatform == TargetPlatform.iOS) {
        await BackgroundTaskService.initialize();
        await BackgroundTaskService.registerPeriodicTask();
        print('[Main] ✅ Background task service initialized and registered');
      } else {
        print('[Main] ℹ️ Background tasks not supported on this platform');
      }
    }

    // Note: Default policies are now handled by PolicyService
    // and don't need initialization
    
    runApp(const MyApp());
  } catch (e) {
    initError = e.toString();
    
    // Show error page
    runApp(
      StartupDebugPage(
        error: initError,
        onRetry: () {
          // Restart app
          main();
        },
      ),
    );
  }
}

Future<void> _initializeDatabase() async {
  await DBProvider.database;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
