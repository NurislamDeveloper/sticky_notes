import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ NotificationService already initialized');
      return;
    }
    try {
      print('\n🔔 === INITIALIZING NOTIFICATIONS ===');
      tz.initializeTimeZones();
      print('✅ Timezone initialized');
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _notifications.initialize(settings);
      print('✅ Flutter local notifications initialized');
      await _requestPermissions();
      _isInitialized = true;
      print('🎉 NotificationService fully initialized!');
      print('=== END INITIALIZATION ===\n');
    } catch (e) {
      print('❌ Notification initialization error: $e');
    }
  }
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      print('📱 Requesting Android permissions...');
      final notificationStatus = await Permission.notification.request();
      print('Notification: ${notificationStatus.isGranted ? "✅" : "❌"}');
      try {
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        print('Exact Alarm: ${alarmStatus.isGranted ? "✅" : "❌"}');
      } catch (e) {
        print('⚠️ Exact alarm permission: $e');
      }
      try {
        final batteryStatus = await Permission.ignoreBatteryOptimizations.request();
        print('Battery Opt: ${batteryStatus.isGranted ? "✅" : "❌"}');
      } catch (e) {
        print('⚠️ Battery optimization: $e');
      }
    } else if (Platform.isIOS) {
      print('🍎 Requesting iOS permissions...');
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      print('\n🔔 === SCHEDULING DAILY REMINDER ===');
      print('⏰ Time: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      print('🕐 Current time: ${DateTime.now()}');
      await _notifications.cancelAll();
      print('✅ Cancelled existing notifications');
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      print('📅 Scheduled for: $scheduledDate');
      print('⏳ Time until notification: ${scheduledDate.difference(now).inHours}h ${scheduledDate.difference(now).inMinutes % 60}m');
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_habit_reminder',
        'Daily Habit Reminders',
        channelDescription: 'Daily reminders to check your habits',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _notifications.zonedSchedule(
        0,
        'Daily Habit Check 🎯',
        'Time to check your habits for today!',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('✅ Daily reminder scheduled successfully!');
      final pending = await _notifications.pendingNotificationRequests();
      print('📋 Pending notifications after scheduling: ${pending.length}');
      for (final notification in pending) {
        print('  - ID: ${notification.id}, Title: ${notification.title}');
      }
      if (pending.isEmpty) {
        print('⚠️ WARNING: No pending notifications found after scheduling!');
        print('⚠️ This means the notification was not scheduled properly.');
        print('⚠️ Check Android permissions and battery optimization settings.');
      }
      print('=== END SCHEDULING ===\n');
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
      rethrow;
    }
  }
  Future<void> cancelAllReminders() async {
    try {
      print('🗑️ Cancelling all reminders...');
      await _notifications.cancelAll();
      print('✅ All reminders cancelled');
    } catch (e) {
      print('❌ Error cancelling reminders: $e');
    }
  }
  Future<void> showTestNotification() async {
    try {
      print('🧪 Showing test notification...');
      print('📱 Current time: ${DateTime.now()}');
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        channelShowBadge: true,
        autoCancel: true,
        ongoing: false,
        ticker: 'Test notification',
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _notifications.show(
        999,
        'Test Notification 🎉',
        'If you see this, notifications are working! Time: ${DateTime.now().hour}:${DateTime.now().minute}',
        details,
      );
      print('✅ Test notification shown with ID: 999');
      final activeNotifications = await _notifications.getActiveNotifications();
      print('📊 Active notifications: ${activeNotifications.length}');
    } catch (e) {
      print('❌ Error showing test notification: $e');
      print('Error details: ${e.toString()}');
      rethrow;
    }
  }
  Future<void> scheduleTestNotification() async {
    try {
      print('🧪 Scheduling test notification for 10 seconds...');
      final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _notifications.zonedSchedule(
        999,
        'Test Notification 🎉',
        'This notification was scheduled for 10 seconds!',
        scheduledTime,
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('✅ Test notification scheduled for 10 seconds');
    } catch (e) {
      print('❌ Error scheduling test notification: $e');
      rethrow;
    }
  }
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  Future<void> scheduleOneMinuteTest() async {
    try {
      print('\n🧪 === SCHEDULING 1-MINUTE TEST ===');
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = now.add(const Duration(minutes: 1));
      print('🕐 Current time: $now');
      print('⏰ Scheduled for: $scheduledTime');
      print('⏳ In 1 minute!');
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );
      await _notifications.zonedSchedule(
        888,
        '1-Minute Test 🎯',
        'This notification was scheduled for 1 minute! If you see this, scheduling works!',
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('✅ 1-minute test notification scheduled!');
      print('=== END 1-MINUTE TEST ===\n');
    } catch (e) {
      print('❌ Error scheduling 1-minute test: $e');
      rethrow;
    }
  }
  Future<void> checkNotificationStatus() async {
    try {
      print('\n🔍 === NOTIFICATION STATUS CHECK ===');
      final pending = await _notifications.pendingNotificationRequests();
      print('⏰ Pending notifications: ${pending.length}');
      for (final notification in pending) {
        print('  - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
      }
      final active = await _notifications.getActiveNotifications();
      print('📊 Active notifications: ${active.length}');
      print('🕐 Current time: ${DateTime.now()}');
      print('🌍 Timezone: ${tz.local}');
      print('=== END STATUS CHECK ===\n');
    } catch (e) {
      print('❌ Error checking status: $e');
    }
  }
}
