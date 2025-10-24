import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:noteflow/core/domain/interfaces/notification_interface.dart';
import 'package:noteflow/core/domain/errors/notification_errors.dart';
class NotificationPermissionManager implements INotificationPermissionManager {
  @override
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      try {
        await Permission.scheduleExactAlarm.request();
      } catch (e) {
        throw NotificationPermissionError('Exact alarm permission failed: $e');
      }
      try {
        await Permission.ignoreBatteryOptimizations.request();
      } catch (e) {
        throw NotificationPermissionError('Battery optimization permission failed: $e');
      }
    } else if (Platform.isIOS) {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }
  @override
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      final notificationStatus = await Permission.notification.status;
      return notificationStatus.isGranted;
    }
    return true;
  }
}
class NotificationScheduler implements INotificationScheduler {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    try {
      await _notifications.cancelAll();
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
    } catch (e) {
      throw NotificationSchedulingError('Failed to schedule daily reminder: $e');
    }
  }
  @override
  Future<void> scheduleTest({required Duration delay}) async {
    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
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
        'This notification was scheduled for testing!',
        scheduledTime,
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      throw NotificationSchedulingError('Failed to schedule test notification: $e');
    }
  }
  @override
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      throw NotificationCancellationError('Failed to cancel notifications: $e');
    }
  }
}
class NotificationInitializer implements INotificationInitializer {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  @override
  bool get isInitialized => _isInitialized;
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      tz.initializeTimeZones();
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
      _isInitialized = true;
    } catch (e) {
      throw NotificationInitializationError('Failed to initialize notifications: $e');
    }
  }
}
class NotificationService implements INotificationService {
  final INotificationInitializer _initializer;
  final INotificationPermissionManager _permissionManager;
  final INotificationScheduler _scheduler;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  NotificationService({
    required INotificationInitializer initializer,
    required INotificationPermissionManager permissionManager,
    required INotificationScheduler scheduler,
  }) : _initializer = initializer,
       _permissionManager = permissionManager,
       _scheduler = scheduler;
  @override
  Future<void> initialize() async {
    await _initializer.initialize();
    await _permissionManager.requestPermissions();
  }
  @override
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await _scheduler.scheduleDaily(hour: hour, minute: minute);
  }
  @override
  Future<void> cancelAllReminders() async {
    await _scheduler.cancelAll();
  }
  @override
  Future<void> showTestNotification() async {
    try {
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
    } catch (e) {
      throw NotificationDisplayError('Failed to show test notification: $e');
    }
  }
  @override
  Future<void> scheduleTestNotification() async {
    await _scheduler.scheduleTest(delay: const Duration(seconds: 10));
  }
  @override
  Future<void> scheduleOneMinuteTest() async {
    await _scheduler.scheduleTest(delay: const Duration(minutes: 1));
  }
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  @override
  Future<void> checkNotificationStatus() async {
  }
}
