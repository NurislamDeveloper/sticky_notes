import 'package:dartz/dartz.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
abstract class NotificationSettingsRepository {
  Future<Either<String, NotificationSettings>> getNotificationSettings(int userId);
  Future<Either<String, NotificationSettings>> updateNotificationSettings(NotificationSettings settings);
}
