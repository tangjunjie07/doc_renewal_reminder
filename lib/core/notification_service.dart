import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../app.dart'; // グローバルNavigatorKey用
import 'logger.dart';
import '../features/documents/ui/document_edit_page.dart';
import '../features/documents/repository/document_repository.dart';

/// 通知サービス
/// 
/// flutter_local_notificationsを使用したローカル通知管理
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // iOSのフォアグラウンド通知プレゼンテーションオプションを設定
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Android向け: チャネル作成とランタイム通知権限要求（Android 13+）
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'doc_renewal_reminder',
        'Document Renewal Reminder',
        description: 'Notifications for document expiration reminders',
        importance: Importance.max,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      try {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final result = await Permission.notification.request();
          AppLogger.log('[NotificationService] Notification permission: $result');
        }
      } catch (e) {
        AppLogger.error('[NotificationService] Permission request error: $e');
      }
    }

    _initialized = true;
  }

  /// 通知タップ時のコールバック
  void _onNotificationTapped(NotificationResponse response) async {
    AppLogger.log('Notification tapped: ${response.payload}');
    
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      // payload形式: "document:123"
      if (payload.startsWith('document:')) {
        final documentIdStr = payload.split(':')[1];
        final documentId = int.tryParse(documentIdStr);
        
        if (documentId != null) {
          // 証件を取得
          final document = await DocumentRepository.getById(documentId);
          
          if (document != null) {
            // 証件編集画面へ遷移（詳細表示モード）
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => DocumentEditPage(
                  document: document,
                  memberId: document.memberId,
                ),
              ),
            );
            } else {
            AppLogger.log('[NotificationService] Document not found: $documentId');
          }
        }
      }
    } catch (e) {
      AppLogger.error('[NotificationService] Error handling notification tap: $e');
    }
  }

  /// 即時通知を送信
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    AppLogger.log('[NotificationService] showNotification id=$id title="$title" payload=$payload');

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doc_renewal_reminder',
      'Document Renewal Reminder',
      channelDescription: 'Notifications for document expiration reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);

    AppLogger.log('[NotificationService] showNotification completed id=$id');
  }

  /// スケジュール通知を設定
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await initialize();

    AppLogger.log('[NotificationService] scheduleNotification id=$id title="$title" scheduledDate=${scheduledDate.toIso8601String()} payload=$payload');

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doc_renewal_reminder',
      'Document Renewal Reminder',
      channelDescription: 'Notifications for document expiration reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    AppLogger.log('[NotificationService] scheduleNotification scheduled id=$id');
  }

  /// 繰り返し通知を設定（周期的リマインダー）
  /// 
  /// [startDate] から指定した [interval] で繰り返し通知
  /// RepeatInterval.daily = 毎日同じ時刻に通知（永久ループ）
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime startDate,
    required RepeatInterval interval,
    String? payload,
  }) async {
    await initialize();

    AppLogger.log('[NotificationService] scheduleRepeatingNotification id=$id title="$title" startDate=${startDate.toIso8601String()} interval=$interval payload=$payload');

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'doc_renewal_reminder',
      'Document Renewal Reminder',
      channelDescription: 'Notifications for document expiration reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    // startDateの時刻を使用して繰り返し通知を設定
    final scheduledTime = tz.TZDateTime.from(startDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _getMatchComponents(interval),
    );

    AppLogger.log('[NotificationService] scheduleRepeatingNotification scheduled id=$id');
  }

  /// RepeatIntervalに応じたDateTimeComponentsを取得
  DateTimeComponents _getMatchComponents(RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.daily:
        return DateTimeComponents.time; // 毎日同じ時刻
      case RepeatInterval.weekly:
        return DateTimeComponents.dayOfWeekAndTime; // 毎週同じ曜日・時刻
      default:
        return DateTimeComponents.time;
    }
  }

  /// 通知をキャンセル（単発・繰り返し両方に対応）
  Future<void> cancel(int id) async {
    AppLogger.log('[NotificationService] cancel id=$id');
    await _notifications.cancel(id);
    AppLogger.log('[NotificationService] cancel completed id=$id');
  }

  /// 定期通知を設定（daily）
  /// 
  /// 🔴 非推奨: scheduleRepeatingNotification() を使用してください
  @Deprecated('Use scheduleRepeatingNotification() instead')
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await scheduleRepeatingNotification(
      id: id,
      title: title,
      body: body,
      startDate: scheduledTime,
      interval: RepeatInterval.daily,
      payload: payload,
    );
  }

  /// 通知をキャンセル（単発・繰り返し両方に対応）
  /// 
  /// 🔴 非推奨: cancel() を使用してください
  @Deprecated('Use cancel() instead')
  Future<void> cancelNotification(int id) async {
    await cancel(id);
  }

  /// 全通知をキャンセル
  Future<void> cancelAllNotifications() async {
    AppLogger.log('[NotificationService] cancelAllNotifications');
    await _notifications.cancelAll();
    AppLogger.log('[NotificationService] cancelAllNotifications completed');
  }

  /// 予定された通知一覧を取得
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// 通知権限をリクエスト（iOS/macOS用）
  Future<bool?> requestPermissions() async {
    await initialize();
    if (Platform.isAndroid) {
      try {
        final result = await Permission.notification.request();
        return result.isGranted;
      } catch (e) {
        AppLogger.error('[NotificationService] requestPermissions error: $e');
        return null;
      }
    }

    return await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}