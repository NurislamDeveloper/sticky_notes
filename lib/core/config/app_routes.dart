import 'package:flutter/material.dart';

import '../presentation/pages/auth_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/habit_tracking_page.dart';
import '../presentation/pages/profile_page.dart';
import 'app_config.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConfig.authRoute:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );
      
      case AppConfig.homeRoute:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      
      case AppConfig.habitTrackingRoute:
        return MaterialPageRoute(
          builder: (_) => const HabitTrackingPage(),
          settings: settings,
        );
      
      case AppConfig.profileRoute:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );
    }
  }
  
  static Map<String, WidgetBuilder> get routes => {
    AppConfig.authRoute: (context) => const AuthPage(),
    AppConfig.homeRoute: (context) => const HomePage(),
    AppConfig.habitTrackingRoute: (context) => const HabitTrackingPage(),
    AppConfig.profileRoute: (context) => const ProfilePage(),
  };
}
