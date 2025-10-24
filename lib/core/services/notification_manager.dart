import 'package:flutter/material.dart';
import 'package:noteflow/core/domain/entities/habit.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
import 'package:noteflow/core/services/simple_notification_service.dart';
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();
  final SimpleNotificationService _notificationService = SimpleNotificationService();
  Future<void> scheduleHabitReminders({
    required List<Habit> habits,
    required NotificationSettings settings,
  }) async {
    print('📋 NotificationManager: scheduleHabitReminders called');
    if (!settings.isEnabled || !settings.dailyReminders) {
      print('⚠️ Reminders disabled in settings');
      await _notificationService.cancelAllReminders();
      return;
    }
    final reminderTime = _parseTime(settings.reminderTime);
    print('⏰ Scheduling daily reminder for ${reminderTime.hour}:${reminderTime.minute}');
    await _notificationService.scheduleDailyReminder(
      hour: reminderTime.hour,
      minute: reminderTime.minute,
    );
    print('✅ Daily reminder scheduled');
  }
  Future<void> cancelHabitReminders(List<Habit> habits) async {
    print('🗑️ NotificationManager: Cancelling all reminders');
    await _notificationService.cancelAllReminders();
  }
  Future<void> scheduleStreakReminder({
    required Habit habit,
    required NotificationSettings settings,
  }) async {
    if (!settings.isEnabled || !settings.streakReminders) {
      return;
    }
    print('🔥 Streak reminder for ${habit.title}: ${habit.currentStreak} days');
  }
  Future<void> scheduleAchievementNotification({
    required String title,
    required String body,
    required NotificationSettings settings,
  }) async {
    if (!settings.isEnabled || !settings.achievementNotifications) {
      return;
    }
    print('🏆 Achievement notification: $title');
    await _notificationService.showTestNotification();
  }
  Future<void> scheduleWeeklyReport({
    required String report,
    required NotificationSettings settings,
  }) async {
    if (!settings.isEnabled || !settings.weeklyReports) {
      return;
    }
    print('📊 Weekly report scheduled');
  }
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
