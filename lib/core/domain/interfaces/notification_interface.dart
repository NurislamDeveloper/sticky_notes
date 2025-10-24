import 'package:flutter_local_notifications/flutter_local_notifications.dart';
abstract class INotificationService {
  Future<void> initialize();
  Future<void> scheduleDailyReminder({required int hour, required int minute});
  Future<void> cancelAllReminders();
  Future<void> showTestNotification();
  Future<void> scheduleTestNotification();
  Future<void> scheduleOneMinuteTest();
  Future<List<PendingNotificationRequest>> getPendingNotifications();
  Future<void> checkNotificationStatus();
}
abstract class INotificationScheduler {
  Future<void> scheduleDaily({required int hour, required int minute});
  Future<void> scheduleTest({required Duration delay});
  Future<void> cancelAll();
}
abstract class INotificationPermissionManager {
  Future<void> requestPermissions();
  Future<bool> hasPermissions();
}
abstract class INotificationInitializer {
  Future<void> initialize();
  bool get isInitialized;
}
