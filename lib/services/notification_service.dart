import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize timezones
    tz_data.initializeTimeZones();
    
    // Set local timezone
    final String timeZoneName = 'Asia/Jakarta'; // Sesuaikan dengan lokasi Anda
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Initialize with callback handler
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    final notificationStatus = await Permission.notification.request();
    debugPrint('[NotificationService] Notification permission: $notificationStatus');

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      debugPrint('[NotificationService] Exact alarm permission: $alarmStatus');
    }

    // For Android, also check system settings
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final bool? result = await androidPlugin.requestNotificationsPermission();
      debugPrint('[NotificationService] Android notification permission result: $result');
      
      final bool? exactAlarmResult = await androidPlugin.requestExactAlarmsPermission();
      debugPrint('[NotificationService] Android exact alarm permission result: $exactAlarmResult');
    }
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel',
      'Task Notifications',
      description: 'Pengingat tugas dan deadline',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      debugPrint('[NotificationService] Notification channel created');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Notification tapped: ${response.payload}');
    // Handle notification tap here
    // You can navigate to specific screen or perform actions
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        debugPrint('[NotificationService] Scheduled time is in the past, notification skipped.');
        return;
      }

      // Check if notifications are enabled
      final bool? areNotificationsEnabled = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      
      if (areNotificationsEnabled == false) {
        debugPrint('[NotificationService] Notifications are disabled');
        return;
      }

      final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);
      
      debugPrint('[NotificationService] Scheduling notification:');
      debugPrint('  ID: $id');
      debugPrint('  Title: $title');
      debugPrint('  Body: $body');
      debugPrint('  Scheduled Time: $scheduledTime');
      debugPrint('  TZ Time: $scheduledTZTime');

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Notifications',
            channelDescription: 'Pengingat tugas dan deadline',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      debugPrint('[NotificationService] Notification scheduled successfully');
      
      // Verify notification was scheduled
      final List<PendingNotificationRequest> pendingNotifications = 
          await _notifications.pendingNotificationRequests();
      debugPrint('[NotificationService] Total pending notifications: ${pendingNotifications.length}');
      
    } catch (e) {
      debugPrint('[NotificationService] Failed to schedule notification: $e');
      rethrow;
    }
  }

  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _notifications.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Notifications',
            channelDescription: 'Pengingat tugas dan deadline',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
      debugPrint('[NotificationService] Immediate notification shown: $title');
    } catch (e) {
      debugPrint('[NotificationService] Failed to show immediate notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('[NotificationService] Notification cancelled: $id');
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('[NotificationService] All notifications cancelled');
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Test function to verify notification system
  static Future<void> testNotification() async {
    await showImmediateNotification(
      id: 999,
      title: 'Test Notification',
      body: 'Sistem notifikasi berfungsi dengan baik!',
    );
  }
}