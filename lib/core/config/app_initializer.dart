import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../injection/injection_container.dart' as di;
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/pages/auth_page.dart';
import '../presentation/pages/home_page.dart';
import 'app_theme.dart';
import 'app_routes.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();
  }
  
  static Widget createApp() {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
      child: MaterialApp(
        title: 'Sticky Notes',
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
