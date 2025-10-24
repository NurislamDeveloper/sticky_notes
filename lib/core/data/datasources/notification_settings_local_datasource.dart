import 'package:noteflow/core/data/models/notification_settings_model.dart';
import 'package:noteflow/core/data/datasources/local_database.dart';
abstract class NotificationSettingsLocalDataSource {
  Future<NotificationSettingsModel> getNotificationSettings(int userId);
  Future<NotificationSettingsModel> updateNotificationSettings(NotificationSettingsModel settings);
  Future<void> createDefaultNotificationSettings(int userId);
}
class NotificationSettingsLocalDataSourceImpl implements NotificationSettingsLocalDataSource {
  final LocalDatabase _localDatabase;
  NotificationSettingsLocalDataSourceImpl({required LocalDatabase localDatabase}) : _localDatabase = localDatabase;
  @override
  Future<NotificationSettingsModel> getNotificationSettings(int userId) async {
    final database = await _localDatabase.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'notification_settings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return NotificationSettingsModel.fromMap(maps.first);
    } else {
      await createDefaultNotificationSettings(userId);
      return getNotificationSettings(userId);
    }
  }
  @override
  Future<NotificationSettingsModel> updateNotificationSettings(NotificationSettingsModel settings) async {
    final database = await _localDatabase.database;
    await database.update(
      'notification_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
    return settings;
  }
  @override
  Future<void> createDefaultNotificationSettings(int userId) async {
    final database = await _localDatabase.database;
    final defaultSettings = NotificationSettingsModel(
      id: 0,
      userId: userId,
      isEnabled: true,
      reminderTime: '09:00',
      dailyReminders: true,
      weeklyReports: true,
      streakReminders: true,
      achievementNotifications: true,
    );
    await database.insert('notification_settings', defaultSettings.toMap());
  }
}
