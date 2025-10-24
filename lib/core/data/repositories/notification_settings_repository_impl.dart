import 'package:dartz/dartz.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
import 'package:noteflow/core/domain/repositories/notification_settings_repository.dart';
import 'package:noteflow/core/data/datasources/notification_settings_local_datasource.dart';
import 'package:noteflow/core/data/models/notification_settings_model.dart';
class NotificationSettingsRepositoryImpl implements NotificationSettingsRepository {
  final NotificationSettingsLocalDataSource _localDataSource;
  NotificationSettingsRepositoryImpl({required NotificationSettingsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;
  @override
  Future<Either<String, NotificationSettings>> getNotificationSettings(int userId) async {
    try {
      final settings = await _localDataSource.getNotificationSettings(userId);
      return Right(settings.toEntity());
    } catch (e) {
      return Left('Failed to get notification settings: $e');
    }
  }
  @override
  Future<Either<String, NotificationSettings>> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final updatedSettings = await _localDataSource.updateNotificationSettings(
        NotificationSettingsModel.fromEntity(settings),
      );
      return Right(updatedSettings.toEntity());
    } catch (e) {
      return Left('Failed to update notification settings: $e');
    }
  }
}
