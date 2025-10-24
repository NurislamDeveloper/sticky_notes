import 'package:equatable/equatable.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}
class LoadNotificationSettings extends NotificationEvent {
  final int userId;
  const LoadNotificationSettings(this.userId);
  @override
  List<Object?> get props => [userId];
}
class UpdateNotificationSettings extends NotificationEvent {
  final NotificationSettings settings;
  const UpdateNotificationSettings(this.settings);
  @override
  List<Object?> get props => [settings];
}
class ToggleNotificationEnabled extends NotificationEvent {
  final bool isEnabled;
  const ToggleNotificationEnabled(this.isEnabled);
  @override
  List<Object?> get props => [isEnabled];
}
class UpdateReminderTime extends NotificationEvent {
  final String reminderTime;
  const UpdateReminderTime(this.reminderTime);
  @override
  List<Object?> get props => [reminderTime];
}
class ToggleDailyReminders extends NotificationEvent {
  final bool enabled;
  const ToggleDailyReminders(this.enabled);
  @override
  List<Object?> get props => [enabled];
}
class ToggleWeeklyReports extends NotificationEvent {
  final bool enabled;
  const ToggleWeeklyReports(this.enabled);
  @override
  List<Object?> get props => [enabled];
}
class ToggleStreakReminders extends NotificationEvent {
  final bool enabled;
  const ToggleStreakReminders(this.enabled);
  @override
  List<Object?> get props => [enabled];
}
class ToggleAchievementNotifications extends NotificationEvent {
  final bool enabled;
  const ToggleAchievementNotifications(this.enabled);
  @override
  List<Object?> get props => [enabled];
}
