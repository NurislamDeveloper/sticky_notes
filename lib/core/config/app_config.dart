import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'Sticky Notes';
  static const String appVersion = '1.0.0';
  
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF3B82F6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String habitTrackingRoute = '/habits';
  static const String profileRoute = '/profile';
  
  static const String databaseName = 'sticky_notes.db';
  static const int databaseVersion = 1;
  
  static const int passwordMinLength = 6;
  static const int saltLength = 16;
}
