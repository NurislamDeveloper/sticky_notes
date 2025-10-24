import 'package:get_it/get_it.dart';
import 'package:noteflow/core/domain/interfaces/notification_interface.dart';
import 'package:noteflow/core/domain/repositories/notification_repository.dart';
import 'package:noteflow/core/data/repositories/notification_repository_impl.dart';
import 'package:noteflow/core/domain/usecases/solid_notification_usecases.dart';
import 'package:noteflow/core/services/solid_notification_service.dart';
final GetIt serviceLocator = GetIt.instance;
void setupDependencies() {
  serviceLocator.registerLazySingleton<INotificationInitializer>(
    () => NotificationInitializer(),
  );
  serviceLocator.registerLazySingleton<INotificationPermissionManager>(
    () => NotificationPermissionManager(),
  );
  serviceLocator.registerLazySingleton<INotificationScheduler>(
    () => NotificationScheduler(),
  );
  serviceLocator.registerLazySingleton<INotificationService>(
    () => NotificationService(
      initializer: serviceLocator<INotificationInitializer>(),
      permissionManager: serviceLocator<INotificationPermissionManager>(),
      scheduler: serviceLocator<INotificationScheduler>(),
    ),
  );
  serviceLocator.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationService: serviceLocator<INotificationService>(),
    ),
  );
  serviceLocator.registerLazySingleton<ScheduleDailyReminderUseCase>(
    () => ScheduleDailyReminderUseCase(
      repository: serviceLocator<INotificationRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<CancelAllRemindersUseCase>(
    () => CancelAllRemindersUseCase(
      repository: serviceLocator<INotificationRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<InitializeNotificationServiceUseCase>(
    () => InitializeNotificationServiceUseCase(
      repository: serviceLocator<INotificationRepository>(),
    ),
  );
}
