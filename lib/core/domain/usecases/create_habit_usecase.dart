import 'package:dartz/dartz.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository _repository;

  CreateHabitUseCase(this._repository);

  Future<Either<String, Habit>> call(CreateHabitParams params) async {
    try {
      final habit = Habit(
        userId: params.userId,
        title: params.title,
        description: params.description,
        category: params.category,
        targetDays: params.targetDays,
        createdAt: DateTime.now(),
        color: params.color,
        icon: params.icon,
      );

      return await _repository.createHabit(habit);
    } catch (e) {
      return Left('Failed to create habit: $e');
    }
  }
}

class CreateHabitParams {
  final int userId;
  final String title;
  final String description;
  final String category;
  final int targetDays;
  final String color;
  final String icon;

  CreateHabitParams({
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDays,
    required this.color,
    required this.icon,
  });
}
