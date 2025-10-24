import 'package:get_it/get_it.dart';
import '../data/datasources/local_database.dart';
import '../data/datasources/user_local_datasource.dart';
import '../data/datasources/habit_local_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/habit_repository_impl.dart';
import '../data/services/password_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/habit_repository.dart';
import '../domain/usecases/sign_up_usecase.dart';
import '../domain/usecases/sign_in_usecase.dart';
import '../domain/usecases/create_habit_usecase.dart';
import '../domain/usecases/get_user_habits_usecase.dart';
import '../domain/usecases/complete_habit_usecase.dart';
import '../domain/usecases/delete_habit_usecase.dart';
import '../domain/usecases/update_avatar_usecase.dart';
import '../domain/usecases/get_notification_settings_usecase.dart';
import '../domain/usecases/update_notification_settings_usecase.dart';
import '../data/datasources/notification_settings_local_datasource.dart';
import '../data/repositories/notification_settings_repository_impl.dart';
import '../domain/repositories/notification_settings_repository.dart';
import '../services/simple_notification_service.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/habit/habit_bloc.dart';
import '../presentation/bloc/notification/notification_bloc.dart';
final sl = GetIt.instance;
Future<void> init() async {
  sl.registerLazySingleton(
    () => AuthBloc(
      signUpUseCase: sl(),
      signInUseCase: sl(),
      updateAvatarUseCase: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => HabitBloc(
      createHabitUseCase: sl(),
      getUserHabitsUseCase: sl(),
      completeHabitUseCase: sl(),
      deleteHabitUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => NotificationBloc(
      getNotificationSettingsUseCase: sl(),
      updateNotificationSettingsUseCase: sl(),
      notificationService: sl(),
    ),
  );
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => CreateHabitUseCase(sl()));
  sl.registerLazySingleton(() => GetUserHabitsUseCase(sl()));
  sl.registerLazySingleton(() => CompleteHabitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHabitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNotificationSettingsUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl(),
      sl(),
    ),
  );
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotificationSettingsRepository>(
    () => NotificationSettingsRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<HabitLocalDataSource>(() => HabitLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<NotificationSettingsLocalDataSource>(() => NotificationSettingsLocalDataSourceImpl(localDatabase: sl()));
  sl.registerLazySingleton<PasswordService>(() => SecurePasswordService());
  sl.registerLazySingleton<SimpleNotificationService>(() => SimpleNotificationService());
  sl.registerLazySingleton(() => LocalDatabase());
}
