import 'package:dartz/dartz.dart';
import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  final HabitRepository _habitRepository;

  DeleteHabitUseCase(this._habitRepository);

  Future<Either<String, void>> call(int habitId) async {
    try {
      await _habitRepository.deleteHabit(habitId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete habit: $e');
    }
  }
}
