import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteflow/core/domain/usecases/solid_notification_usecases.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
import 'package:noteflow/core/presentation/bloc/notification/notification_event.dart';
import 'package:noteflow/core/presentation/bloc/notification/notification_state.dart';
class SolidNotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ScheduleDailyReminderUseCase _scheduleDailyReminderUseCase;
  final CancelAllRemindersUseCase _cancelAllRemindersUseCase;
  final InitializeNotificationServiceUseCase _initializeNotificationServiceUseCase;
  SolidNotificationBloc({
    required ScheduleDailyReminderUseCase scheduleDailyReminderUseCase,
    required CancelAllRemindersUseCase cancelAllRemindersUseCase,
    required InitializeNotificationServiceUseCase initializeNotificationServiceUseCase,
  })  : _scheduleDailyReminderUseCase = scheduleDailyReminderUseCase,
        _cancelAllRemindersUseCase = cancelAllRemindersUseCase,
        _initializeNotificationServiceUseCase = initializeNotificationServiceUseCase,
        super(NotificationInitial()) {
    on<LoadNotificationSettings>(_onLoadNotificationSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<ToggleNotificationEnabled>(_onToggleNotificationEnabled);
    on<UpdateReminderTime>(_onUpdateReminderTime);
    on<ToggleDailyReminders>(_onToggleDailyReminders);
    on<ToggleWeeklyReports>(_onToggleWeeklyReports);
    on<ToggleStreakReminders>(_onToggleStreakReminders);
    on<ToggleAchievementNotifications>(_onToggleAchievementNotifications);
  }
  Future<void> _onLoadNotificationSettings(
    LoadNotificationSettings event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      await _initializeNotificationServiceUseCase();
      final defaultSettings = NotificationSettings(
        id: 1,
        userId: event.userId,
        isEnabled: true,
        dailyReminders: true,
        reminderTime: '09:00',
        weeklyReports: false,
        streakReminders: true,
        achievementNotifications: true,
      );
      emit(NotificationSuccess(defaultSettings));
    } catch (e) {
      emit(NotificationFailure('Failed to load notification settings: $e'));
    }
  }
  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationUpdated(event.settings));
      await _scheduleNotificationsIfEnabled(event.settings);
    } catch (e) {
      emit(NotificationFailure('Failed to update notification settings: $e'));
    }
  }
  Future<void> _onToggleNotificationEnabled(
    ToggleNotificationEnabled event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSuccess) {
      final updatedSettings = currentState.settings.copyWith(isEnabled: event.isEnabled);
      add(UpdateNotificationSettings(updatedSettings));
    }
  }
  Future<void> _onUpdateReminderTime(
    UpdateReminderTime event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSuccess) {
      final updatedSettings = currentState.settings.copyWith(reminderTime: event.reminderTime);
      add(UpdateNotificationSettings(updatedSettings));
    }
  }
  Future<void> _onToggleDailyReminders(
    ToggleDailyReminders event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSuccess) {
      final updatedSettings = currentState.settings.copyWith(dailyReminders: event.enabled);
      add(UpdateNotificationSettings(updatedSettings));
    }
  }
  Future<void> _onToggleWeeklyReports(
    ToggleWeeklyReports event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSuccess) {
      final updatedSettings = currentState.settings.copyWith(weeklyReports: event.enabled);
      add(UpdateNotificationSettings(updatedSettings));
    }
  }
  Future<void> _onToggleStreakReminders(
    ToggleStreakReminders event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSuccess) {
      final updatedSettings = currentState.settings.copyWith(streakReminders: event.enabled);
      add(UpdateNotificationSettings(updatedSettings));
    }
  }
  Future<void> _onToggleAchievementNotifications(
    ToggleAchievementNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSuccess) {
      final updatedSettings = currentState.settings.copyWith(achievementNotifications: event.enabled);
      add(UpdateNotificationSettings(updatedSettings));
    }
  }
  Future<void> _scheduleNotificationsIfEnabled(dynamic settings) async {
    if (settings.isEnabled && settings.dailyReminders) {
      try {
        final parts = settings.reminderTime.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final result = await _scheduleDailyReminderUseCase(hour: hour, minute: minute);
        result.fold(
          (error) => print('❌ Failed to schedule notifications: $error'),
          (_) => print('✅ Notification scheduled successfully!'),
        );
      } catch (e) {
        print('❌ Failed to schedule notifications: $e');
      }
    } else {
      try {
        final result = await _cancelAllRemindersUseCase();
        result.fold(
          (error) => print('❌ Failed to cancel notifications: $error'),
          (_) => print('✅ Notifications cancelled'),
        );
      } catch (e) {
        print('❌ Failed to cancel notifications: $e');
      }
    }
  }
}
