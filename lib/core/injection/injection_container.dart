import 'package:get_it/get_it.dart';
import '../data/datasources/local_database.dart';
import '../data/datasources/user_local_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/services/password_service.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/sign_up_usecase.dart';
import '../domain/usecases/sign_in_usecase.dart';
import '../presentation/bloc/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(
    () => AuthBloc(
      signUpUseCase: sl(),
      signInUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl(),
      sl(),
    ),
  );

  sl.registerLazySingleton<UserLocalDataSource>(() => UserLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<PasswordService>(() => SecurePasswordService());
  sl.registerLazySingleton(() => LocalDatabase());
}
