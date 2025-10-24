import 'package:dartz/dartz.dart';
import 'package:noteflow/core/domain/repositories/notification_repository.dart';
import 'package:noteflow/core/domain/errors/notification_errors.dart';
class ScheduleDailyReminderUseCase {
  final INotificationRepository _repository;
  ScheduleDailyReminderUseCase({required INotificationRepository repository})
      : _repository = repository;
  Future<Either<NotificationError, void>> call({
    required int hour,
    required int minute,
  }) async {
    return await _repository.scheduleDailyReminder(hour: hour, minute: minute);
  }
}
class CancelAllRemindersUseCase {
  final INotificationRepository _repository;
  CancelAllRemindersUseCase({required INotificationRepository repository})
      : _repository = repository;
  Future<Either<NotificationError, void>> call() async {
    return await _repository.cancelAllReminders();
  }
}
class InitializeNotificationServiceUseCase {
  final INotificationRepository _repository;
  InitializeNotificationServiceUseCase({required INotificationRepository repository})
      : _repository = repository;
  Future<Either<NotificationError, void>> call() async {
    return await _repository.initialize();
  }
}
