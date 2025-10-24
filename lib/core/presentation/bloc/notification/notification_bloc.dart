import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteflow/core/domain/usecases/get_notification_settings_usecase.dart';
import 'package:noteflow/core/domain/usecases/update_notification_settings_usecase.dart';
import 'package:noteflow/core/services/simple_notification_service.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
import 'package:noteflow/core/presentation/bloc/notification/notification_event.dart';
import 'package:noteflow/core/presentation/bloc/notification/notification_state.dart';
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationSettingsUseCase _getNotificationSettingsUseCase;
  final UpdateNotificationSettingsUseCase _updateNotificationSettingsUseCase;
  final SimpleNotificationService _notificationService;
  NotificationBloc({
    required GetNotificationSettingsUseCase getNotificationSettingsUseCase,
    required UpdateNotificationSettingsUseCase updateNotificationSettingsUseCase,
    required SimpleNotificationService notificationService,
  })  : _getNotificationSettingsUseCase = getNotificationSettingsUseCase,
        _updateNotificationSettingsUseCase = updateNotificationSettingsUseCase,
        _notificationService = notificationService,
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
    final result = await _getNotificationSettingsUseCase(event.userId);
    result.fold(
      (error) => emit(NotificationFailure(error)),
      (settings) async {
        emit(NotificationSuccess(settings));
        await _scheduleNotificationsIfEnabled(settings);
      },
    );
  }
  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _updateNotificationSettingsUseCase(event.settings);
    result.fold(
      (error) => emit(NotificationFailure(error)),
      (settings) async {
        emit(NotificationUpdated(settings));
        await _scheduleNotificationsIfEnabled(settings);
      },
    );
  }
  Future<void> _onToggleNotificationEnabled(
    ToggleNotificationEnabled event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationSuccess) {
      final updatedSettings = currentState.settings.copyWith(isEnabled: event.isEnabled);
      add(UpdateNotificationSettings(updatedSettings));
      await _scheduleNotificationsIfEnabled(updatedSettings);
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
      await _scheduleNotificationsIfEnabled(updatedSettings);
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
      await _scheduleNotificationsIfEnabled(updatedSettings);
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
  Future<void> _scheduleNotificationsIfEnabled(NotificationSettings settings) async {
    if (settings.isEnabled && settings.dailyReminders) {
      try {
        final parts = settings.reminderTime.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        await _notificationService.scheduleDailyReminder(
          hour: hour,
          minute: minute,
        );
      } catch (e) {
      }
    } else {
      try {
        await _notificationService.cancelAllReminders();
      } catch (e) {
      }
    }
  }
}
