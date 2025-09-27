import 'package:dartz/dartz.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetUserHabitsUseCase {
  final HabitRepository _repository;

  GetUserHabitsUseCase(this._repository);

  Future<Either<String, List<Habit>>> call(int userId) async {
    try {
      return await _repository.getUserHabits(userId);
    } catch (e) {
      return Left('Failed to get user habits: $e');
    }
  }
}
