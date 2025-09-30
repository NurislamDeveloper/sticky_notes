import 'package:equatable/equatable.dart';

import '../../../domain/usecases/create_habit_usecase.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserHabits extends HabitEvent {
  final int userId;

  const LoadUserHabits(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateHabit extends HabitEvent {
  final CreateHabitParams params;

  const CreateHabit(this.params);

  @override
  List<Object?> get props => [params];
}

class CompleteHabit extends HabitEvent {
  final int habitId;

  const CompleteHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class SearchHabits extends HabitEvent {
  final int userId;
  final String query;

  const SearchHabits(this.userId, this.query);

  @override
  List<Object?> get props => [userId, query];
}

class DeleteHabit extends HabitEvent {
  final int habitId;

  const DeleteHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}
