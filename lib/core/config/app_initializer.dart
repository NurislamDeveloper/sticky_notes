import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../injection/injection_container.dart' as di;
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/habit/habit_bloc.dart';
import '../presentation/bloc/notification/notification_bloc.dart';
import '../presentation/pages/auth_page.dart';
import '../presentation/pages/home_page.dart';
import '../services/simple_notification_service.dart';
import 'app_theme.dart';
import 'app_routes.dart';
import 'app_config.dart';
class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();
    await SimpleNotificationService().initialize();
  }
  static Widget createApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => di.sl<HabitBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<NotificationBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const HomePage();
            }
            return const AuthPage();
          },
        ),
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
