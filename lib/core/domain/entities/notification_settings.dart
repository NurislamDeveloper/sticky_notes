import 'package:equatable/equatable.dart';
class NotificationSettings extends Equatable {
  final int id;
  final int userId;
  final bool isEnabled;
  final String reminderTime;
  final bool dailyReminders;
  final bool weeklyReports;
  final bool streakReminders;
  final bool achievementNotifications;
  const NotificationSettings({
    required this.id,
    required this.userId,
    required this.isEnabled,
    required this.reminderTime,
    required this.dailyReminders,
    required this.weeklyReports,
    required this.streakReminders,
    required this.achievementNotifications,
  });
  NotificationSettings copyWith({
    int? id,
    int? userId,
    bool? isEnabled,
    String? reminderTime,
    bool? dailyReminders,
    bool? weeklyReports,
    bool? streakReminders,
    bool? achievementNotifications,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      streakReminders: streakReminders ?? this.streakReminders,
      achievementNotifications: achievementNotifications ?? this.achievementNotifications,
    );
  }
  @override
  List<Object?> get props => [
        id,
        userId,
        isEnabled,
        reminderTime,
        dailyReminders,
        weeklyReports,
        streakReminders,
        achievementNotifications,
      ];
}
