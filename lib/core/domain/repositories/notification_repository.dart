import 'package:dartz/dartz.dart';
import 'package:noteflow/core/domain/errors/notification_errors.dart';
abstract class INotificationRepository {
  Future<Either<NotificationError, void>> scheduleDailyReminder({
    required int hour,
    required int minute,
  });
  Future<Either<NotificationError, void>> cancelAllReminders();
  Future<Either<NotificationError, void>> showTestNotification();
  Future<Either<NotificationError, List<dynamic>>> getPendingNotifications();
  Future<Either<NotificationError, void>> initialize();
}
