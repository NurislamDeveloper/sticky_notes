import 'package:equatable/equatable.dart';

import '../../../domain/entities/habit.dart';

abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitSuccess extends HabitState {
  final List<Habit> habits;

  const HabitSuccess(this.habits);

  @override
  List<Object?> get props => [habits];
}

class HabitCreated extends HabitState {
  final Habit habit;

  const HabitCreated(this.habit);

  @override
  List<Object?> get props => [habit];
}

class HabitCompleted extends HabitState {
  final Habit habit;

  const HabitCompleted(this.habit);

  @override
  List<Object?> get props => [habit];
}

class HabitDeleted extends HabitState {
  final int habitId;

  const HabitDeleted(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class HabitFailure extends HabitState {
  final String message;

  const HabitFailure(this.message);

  @override
  List<Object?> get props => [message];
}