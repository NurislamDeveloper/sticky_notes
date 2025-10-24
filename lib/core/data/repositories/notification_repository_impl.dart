import 'package:dartz/dartz.dart';
import 'package:noteflow/core/domain/repositories/notification_repository.dart';
import 'package:noteflow/core/domain/interfaces/notification_interface.dart';
import 'package:noteflow/core/domain/errors/notification_errors.dart';
class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationService _notificationService;
  NotificationRepositoryImpl({required INotificationService notificationService})
      : _notificationService = notificationService;
  @override
  Future<Either<NotificationError, void>> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      await _notificationService.scheduleDailyReminder(hour: hour, minute: minute);
      return const Right(null);
    } on NotificationSchedulingError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NotificationSchedulingError('Unexpected error: $e'));
    }
  }
  @override
  Future<Either<NotificationError, void>> cancelAllReminders() async {
    try {
      await _notificationService.cancelAllReminders();
      return const Right(null);
    } on NotificationCancellationError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NotificationCancellationError('Unexpected error: $e'));
    }
  }
  @override
  Future<Either<NotificationError, void>> showTestNotification() async {
    try {
      await _notificationService.showTestNotification();
      return const Right(null);
    } on NotificationDisplayError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NotificationDisplayError('Unexpected error: $e'));
    }
  }
  @override
  Future<Either<NotificationError, List<dynamic>>> getPendingNotifications() async {
    try {
      final notifications = await _notificationService.getPendingNotifications();
      return Right(notifications);
    } catch (e) {
      return Left(NotificationSchedulingError('Failed to get pending notifications: $e'));
    }
  }
  @override
  Future<Either<NotificationError, void>> initialize() async {
    try {
      await _notificationService.initialize();
      return const Right(null);
    } on NotificationInitializationError catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NotificationInitializationError('Unexpected error: $e'));
    }
  }
}
