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
}
