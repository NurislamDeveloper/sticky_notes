import 'package:dartz/dartz.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_datasource.dart';
import '../models/habit_model.dart';
class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource _localDataSource;
  HabitRepositoryImpl(this._localDataSource);
  @override
  Future<Either<String, List<Habit>>> getUserHabits(int userId) async {
    try {
      final habits = await _localDataSource.getUserHabits(userId);
      return Right(habits);
    } catch (e) {
      return Left('Failed to get user habits: $e');
    }
  }
  @override
  Future<Either<String, Habit>> createHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);
      final createdHabit = await _localDataSource.createHabit(habitModel);
      return Right(createdHabit);
    } catch (e) {
      return Left('Failed to create habit: $e');
    }
  }
  @override
  Future<Either<String, Habit>> updateHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);
      final updatedHabit = await _localDataSource.updateHabit(habitModel);
      return Right(updatedHabit);
    } catch (e) {
      return Left('Failed to update habit: $e');
    }
  }
  @override
  Future<Either<String, void>> deleteHabit(int habitId) async {
    try {
      await _localDataSource.deleteHabit(habitId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete habit: $e');
    }
  }
  @override
  Future<Either<String, Habit>> completeHabit(int habitId) async {
    try {
      final completedHabit = await _localDataSource.completeHabit(habitId);
      return Right(completedHabit);
    } catch (e) {
      return Left('Failed to complete habit: $e');
    }
  }
  @override
  Future<Either<String, List<Habit>>> searchHabits(int userId, String query) async {
    try {
      final habits = await _localDataSource.searchHabits(userId, query);
      return Right(habits);
    } catch (e) {
      return Left('Failed to search habits: $e');
    }
  }
  @override
  Future<Either<String, List<HabitCompletion>>> getHabitCompletions(int habitId) async {
    try {
      final completions = await _localDataSource.getHabitCompletions(habitId);
      return Right(completions);
    } catch (e) {
      return Left('Failed to get habit completions: $e');
    }
  }
  @override
  Future<Either<String, HabitCompletion>> addHabitCompletion(HabitCompletion completion) async {
    try {
      final completionModel = HabitCompletionModel.fromEntity(completion);
      final addedCompletion = await _localDataSource.addHabitCompletion(completionModel);
      return Right(addedCompletion);
    } catch (e) {
      return Left('Failed to add habit completion: $e');
    }
  }
}
