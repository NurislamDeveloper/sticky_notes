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
      await _ensureAvatarPathColumn();
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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        target_days INTEGER NOT NULL,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        last_completed_at INTEGER,
        is_active INTEGER DEFAULT 1,
        color TEXT DEFAULT '#3B82F6',
        icon TEXT DEFAULT 'fitness_center',
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_username ON users(username)');
    await db.execute('CREATE INDEX idx_habits_user_id ON habits(user_id)');
    await db.execute('CREATE INDEX idx_habits_category ON habits(category)');
    await db.execute('CREATE INDEX idx_habit_completions_habit_id ON habit_completions(habit_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN avatar_path TEXT');
        debugPrint('Added avatar_path column to users table');
      } catch (e) {
        debugPrint('Error adding avatar_path column: $e');
      }
    }
    
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            target_days INTEGER NOT NULL,
            current_streak INTEGER DEFAULT 0,
            longest_streak INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            last_completed_at INTEGER,
            is_active INTEGER DEFAULT 1,
            color TEXT DEFAULT '#3B82F6',
            icon TEXT DEFAULT 'fitness_center',
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        
        await db.execute('''
          CREATE TABLE habit_completions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit_id INTEGER NOT NULL,
            completed_at INTEGER NOT NULL,
            notes TEXT,
            FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
          )
        ''');
        
        await db.execute('CREATE INDEX idx_habits_user_id ON habits(user_id)');
        await db.execute('CREATE INDEX idx_habits_category ON habits(category)');
        await db.execute('CREATE INDEX idx_habit_completions_habit_id ON habit_completions(habit_id)');
        
        debugPrint('Added habits and habit_completions tables');
      } catch (e) {
        debugPrint('Error adding habits tables: $e');
      }
    }
  }

  Future<void> _ensureAvatarPathColumn() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA table_info(users)');
      final hasAvatarPath = result.any((column) => column['name'] == 'avatar_path');
      
      if (!hasAvatarPath) {
        await db.execute('ALTER TABLE users ADD COLUMN avatar_path TEXT');
        debugPrint('Added missing avatar_path column to users table');
      }
    } catch (e) {
      debugPrint('Error ensuring avatar_path column: $e');
    }
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
