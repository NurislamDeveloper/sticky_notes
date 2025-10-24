import 'package:dartz/dartz.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
class CompleteHabitUseCase {
  final HabitRepository _repository;
  CompleteHabitUseCase(this._repository);
  Future<Either<String, Habit>> call(int habitId) async {
    try {
      return await _repository.completeHabit(habitId);
    } catch (e) {
      return Left('Failed to complete habit: $e');
    }
  }
}
