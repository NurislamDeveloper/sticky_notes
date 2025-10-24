import 'package:dartz/dartz.dart';
import 'package:noteflow/core/domain/entities/notification_settings.dart';
import 'package:noteflow/core/domain/repositories/notification_settings_repository.dart';
class UpdateNotificationSettingsUseCase {
  final NotificationSettingsRepository _repository;
  UpdateNotificationSettingsUseCase(this._repository);
  Future<Either<String, NotificationSettings>> call(NotificationSettings settings) async {
    return await _repository.updateNotificationSettings(settings);
  }
}
