import 'package:dartz/dartz.dart';
import '../entities/habit.dart';

abstract class HabitRepository {
  Future<Either<String, List<Habit>>> getUserHabits(int userId);
  Future<Either<String, Habit>> createHabit(Habit habit);
  Future<Either<String, Habit>> updateHabit(Habit habit);
  Future<Either<String, void>> deleteHabit(int habitId);
  Future<Either<String, Habit>> completeHabit(int habitId);
  Future<Either<String, List<Habit>>> searchHabits(int userId, String query);
  Future<Either<String, List<HabitCompletion>>> getHabitCompletions(int habitId);
  Future<Either<String, HabitCompletion>> addHabitCompletion(HabitCompletion completion);
}
