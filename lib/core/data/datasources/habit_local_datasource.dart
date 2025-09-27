import '../models/habit_model.dart';
import 'local_database.dart';

abstract class HabitLocalDataSource {
  Future<List<HabitModel>> getUserHabits(int userId);
  Future<HabitModel> createHabit(HabitModel habit);
  Future<HabitModel> updateHabit(HabitModel habit);
  Future<void> deleteHabit(int habitId);
  Future<HabitModel> completeHabit(int habitId);
  Future<List<HabitModel>> searchHabits(int userId, String query);
  Future<List<HabitCompletionModel>> getHabitCompletions(int habitId);
  Future<HabitCompletionModel> addHabitCompletion(HabitCompletionModel completion);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  final LocalDatabase _database;

  HabitLocalDataSourceImpl(this._database);

  @override
  Future<List<HabitModel>> getUserHabits(int userId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitModel.fromMap(maps[i]);
    });
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    final db = await _database.database;
    final id = await db.insert('habits', habit.toMap());
    return habit.copyWith(id: id);
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    final db = await _database.database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
    return habit;
  }

  @override
  Future<void> deleteHabit(int habitId) async {
    final db = await _database.database;
    await db.update(
      'habits',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  @override
  Future<HabitModel> completeHabit(int habitId) async {
    final db = await _database.database;
    final now = DateTime.now();
    
    await db.insert('habit_completions', {
      'habit_id': habitId,
      'completed_at': now.millisecondsSinceEpoch,
    });

    final habit = await db.query('habits', where: 'id = ?', whereArgs: [habitId]);
    if (habit.isEmpty) {
      throw Exception('Habit not found');
    }

    final habitModel = HabitModel.fromMap(habit.first);
    final newStreak = habitModel.currentStreak + 1;
    final longestStreak = newStreak > habitModel.longestStreak ? newStreak : habitModel.longestStreak;

    await db.update(
      'habits',
      {
        'current_streak': newStreak,
        'longest_streak': longestStreak,
        'last_completed_at': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [habitId],
    );

    return habitModel.copyWith(
      currentStreak: newStreak,
      longestStreak: longestStreak,
      lastCompletedAt: now,
    );
  }

  @override
  Future<List<HabitModel>> searchHabits(int userId, String query) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'user_id = ? AND is_active = 1 AND (title LIKE ? OR description LIKE ? OR category LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitModel.fromMap(maps[i]);
    });
  }

  @override
  Future<List<HabitCompletionModel>> getHabitCompletions(int habitId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitCompletionModel.fromMap(maps[i]);
    });
  }

  @override
  Future<HabitCompletionModel> addHabitCompletion(HabitCompletionModel completion) async {
    final db = await _database.database;
    final id = await db.insert('habit_completions', completion.toMap());
    return completion.copyWith(id: id);
  }
}
