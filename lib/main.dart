import 'package:flutter/material.dart';
import 'core/config/app_initializer.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(AppInitializer.createApp());
}