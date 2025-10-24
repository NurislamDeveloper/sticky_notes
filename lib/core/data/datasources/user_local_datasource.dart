import '../models/user_model.dart';
import 'local_database.dart';
abstract class UserLocalDataSource {
  Future<UserModel?> getUserByEmail(String email);
  Future<UserModel?> getUserById(int id);
  Future<UserModel> createUser(UserModel user);
  Future<void> updateLastLogin(int userId, DateTime lastLoginAt);
  Future<void> updateAvatarPath(int userId, String avatarPath);
  Future<bool> emailExists(String email);
  Future<bool> usernameExists(String username);
  Future<void> setCurrentUser(int userId);
  Future<int?> getCurrentUserId();
  Future<void> clearCurrentUser();
}
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final LocalDatabase _database;
  UserLocalDataSourceImpl(this._database);
  @override
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
  @override
  Future<UserModel?> getUserById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }
  @override
  Future<UserModel> createUser(UserModel user) async {
    final db = await _database.database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }
  @override
  Future<void> updateLastLogin(int userId, DateTime lastLoginAt) async {
    final db = await _database.database;
    await db.update(
      'users',
      {'last_login_at': lastLoginAt.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
  @override
  Future<bool> emailExists(String email) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
  @override
  Future<bool> usernameExists(String username) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }
  @override
  Future<void> updateAvatarPath(int userId, String avatarPath) async {
    final db = await _database.database;
    await db.update(
      'users',
      {'avatar_path': avatarPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
  @override
  Future<void> setCurrentUser(int userId) async {
    print('🔐 setCurrentUser called with userId: $userId');
    final db = await _database.database;
    await db.execute('DELETE FROM current_user');
    await db.insert('current_user', {'user_id': userId});
    print('✅ Current user set in database: $userId');
    final result = await db.query('current_user');
    print('🔍 Verification - current_user table contents: $result');
  }
  @override
  Future<int?> getCurrentUserId() async {
    print('🔐 getCurrentUserId called');
    final db = await _database.database;
    final List<Map<String, dynamic>> result = await db.query('current_user');
    print('🔍 current_user table query result: $result');
    if (result.isNotEmpty) {
      final userId = result.first['user_id'] as int?;
      print('✅ Found current user ID: $userId');
      return userId;
    }
    print('❌ No current user found in database');
    return null;
  }
  @override
  Future<void> clearCurrentUser() async {
    print('🔐 clearCurrentUser called');
    final db = await _database.database;
    await db.execute('DELETE FROM current_user');
    print('✅ Current user cleared from database');
  }
}
