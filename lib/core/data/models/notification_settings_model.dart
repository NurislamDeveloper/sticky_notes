import 'package:noteflow/core/domain/entities/notification_settings.dart';
class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    required super.id,
    required super.userId,
    required super.isEnabled,
    required super.reminderTime,
    required super.dailyReminders,
    required super.weeklyReports,
    required super.streakReminders,
    required super.achievementNotifications,
  });
  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      isEnabled: (map['is_enabled'] as int) == 1,
      reminderTime: map['reminder_time'] as String,
      dailyReminders: (map['daily_reminders'] as int) == 1,
      weeklyReports: (map['weekly_reports'] as int) == 1,
      streakReminders: (map['streak_reminders'] as int) == 1,
      achievementNotifications: (map['achievement_notifications'] as int) == 1,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'is_enabled': isEnabled ? 1 : 0,
      'reminder_time': reminderTime,
      'daily_reminders': dailyReminders ? 1 : 0,
      'weekly_reports': weeklyReports ? 1 : 0,
      'streak_reminders': streakReminders ? 1 : 0,
      'achievement_notifications': achievementNotifications ? 1 : 0,
    };
  }
  factory NotificationSettingsModel.fromEntity(NotificationSettings settings) {
    return NotificationSettingsModel(
      id: settings.id,
      userId: settings.userId,
      isEnabled: settings.isEnabled,
      reminderTime: settings.reminderTime,
      dailyReminders: settings.dailyReminders,
      weeklyReports: settings.weeklyReports,
      streakReminders: settings.streakReminders,
      achievementNotifications: settings.achievementNotifications,
    );
  }
  NotificationSettings toEntity() {
    return NotificationSettings(
      id: id,
      userId: userId,
      isEnabled: isEnabled,
      reminderTime: reminderTime,
      dailyReminders: dailyReminders,
      weeklyReports: weeklyReports,
      streakReminders: streakReminders,
      achievementNotifications: achievementNotifications,
    );
  }
}
