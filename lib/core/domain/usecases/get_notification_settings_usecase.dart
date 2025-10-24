import 'package:dartz/dartz.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
import 'package:noteflow/core/domain/repositories/notification_settings_repository.dart';
class GetNotificationSettingsUseCase {
  final NotificationSettingsRepository _repository;
  GetNotificationSettingsUseCase(this._repository);
  Future<Either<String, NotificationSettings>> call(int userId) async {
    return await _repository.getNotificationSettings(userId);
  }
}
