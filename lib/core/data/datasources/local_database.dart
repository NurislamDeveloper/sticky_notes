import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  LocalDatabase._internal();

  factory LocalDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      debugPrint('Database initialization failed: $e');
      await recreateDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sticky_notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          username TEXT NOT NULL,
          password_hash TEXT NOT NULL,
          avatar_path TEXT,
          created_at INTEGER NOT NULL,
          last_login_at INTEGER
        )
      ''');

    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_username ON users(username)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('users');
      debugPrint('All user data cleared from database');
    } catch (e) {
      debugPrint('Error clearing data: $e');
      await recreateDatabase();
    }
  }

  Future<void> deleteDatabase() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
        _database = null;
      }
      
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'sticky_notes.db');
      await databaseFactory.deleteDatabase(path);
      debugPrint('Database file deleted: $path');
    } catch (e) {
      debugPrint('Error deleting database: $e');
    }
  }

  Future<void> recreateDatabase() async {
    try {
      final db = _database;
      if (db != null) {
        await db.close();
        _database = null;
      }
      
      await deleteDatabase();
      
      _database = await _initDatabase();
      debugPrint('Database recreated successfully');
    } catch (e) {
      debugPrint('Error recreating database: $e');
    }
  }
}
