import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/usecases/create_habit_usecase.dart';
import '../../../domain/usecases/get_user_habits_usecase.dart';
import '../../../domain/usecases/complete_habit_usecase.dart';
import '../../../domain/usecases/delete_habit_usecase.dart';

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

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final CreateHabitUseCase _createHabitUseCase;
  final GetUserHabitsUseCase _getUserHabitsUseCase;
  final CompleteHabitUseCase _completeHabitUseCase;
  final DeleteHabitUseCase _deleteHabitUseCase;

  HabitBloc({
    required CreateHabitUseCase createHabitUseCase,
    required GetUserHabitsUseCase getUserHabitsUseCase,
    required CompleteHabitUseCase completeHabitUseCase,
    required DeleteHabitUseCase deleteHabitUseCase,
  })  : _createHabitUseCase = createHabitUseCase,
        _getUserHabitsUseCase = getUserHabitsUseCase,
        _completeHabitUseCase = completeHabitUseCase,
        _deleteHabitUseCase = deleteHabitUseCase,
        super(HabitInitial()) {
        on<LoadUserHabits>(_onLoadUserHabits);
        on<CreateHabit>(_onCreateHabit);
        on<CompleteHabit>(_onCompleteHabit);
        on<SearchHabits>(_onSearchHabits);
        on<DeleteHabit>(_onDeleteHabit);
  }

  Future<void> _onLoadUserHabits(LoadUserHabits event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    
    try {
      final result = await _getUserHabitsUseCase(event.userId);
      
      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => '');
        print('HabitBloc: Error loading habits: $error');
        emit(HabitFailure(error));
        return;
      }
      
      final habits = result.fold((l) => <Habit>[], (r) => r);
      print('HabitBloc: Successfully loaded ${habits.length} habits');
      emit(HabitSuccess(habits));
    } catch (e) {
      print('HabitBloc: Exception loading habits: $e');
      emit(HabitFailure('Failed to load habits: $e'));
    }
  }

  Future<void> _onCreateHabit(CreateHabit event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    
    try {
      final result = await _createHabitUseCase(event.params);
      
      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => '');
        emit(HabitFailure(error));
        return;
      }
      
      final habit = result.fold((l) => null, (r) => r);
      if (habit == null) {
        emit(HabitFailure('Failed to create habit'));
        return;
      }
      
      // Refresh the habits list after creating a new one
      final habitsResult = await _getUserHabitsUseCase(habit.userId);
      
      if (habitsResult.isLeft()) {
        final error = habitsResult.fold((l) => l, (r) => '');
        emit(HabitFailure(error));
        return;
      }
      
      final habits = habitsResult.fold((l) => <Habit>[], (r) => r);
      emit(HabitSuccess(habits));
    } catch (e) {
      emit(HabitFailure('Failed to create habit: $e'));
    }
  }

  Future<void> _onCompleteHabit(CompleteHabit event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    
    try {
      final result = await _completeHabitUseCase(event.habitId);
      
      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => '');
        emit(HabitFailure(error));
        return;
      }
      
      final habit = result.fold((l) => null, (r) => r);
      if (habit == null) {
        emit(HabitFailure('Failed to complete habit'));
        return;
      }
      
      // Update the habits list after completion
      final habitsResult = await _getUserHabitsUseCase(habit.userId);
      
      if (habitsResult.isLeft()) {
        final error = habitsResult.fold((l) => l, (r) => '');
        emit(HabitFailure(error));
        return;
      }
      
      final habits = habitsResult.fold((l) => <Habit>[], (r) => r);
      emit(HabitSuccess(habits));
    } catch (e) {
      emit(HabitFailure('Failed to complete habit: $e'));
    }
  }

  Future<void> _onSearchHabits(SearchHabits event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    
    try {
      final result = await _getUserHabitsUseCase(event.userId);
      
      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => '');
        emit(HabitFailure(error));
        return;
      }
      
      final habits = result.fold((l) => <Habit>[], (r) => r);
      
      if (event.query.isEmpty) {
        emit(HabitSuccess(habits));
      } else {
        // Filter habits based on search query
        final filteredHabits = habits.where((habit) =>
          habit.title.toLowerCase().contains(event.query.toLowerCase()) ||
          habit.description.toLowerCase().contains(event.query.toLowerCase()) ||
          habit.category.toLowerCase().contains(event.query.toLowerCase())
        ).toList();
        emit(HabitSuccess(filteredHabits));
      }
    } catch (e) {
      emit(HabitFailure('Failed to search habits: $e'));
    }
  }

  Future<void> _onDeleteHabit(DeleteHabit event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    
    try {
      final result = await _deleteHabitUseCase(event.habitId);
      
      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => '');
        emit(HabitFailure(error));
        return;
      }
      
      // Simply emit deleted state - let the UI handle refreshing
      emit(HabitDeleted(event.habitId));
    } catch (e) {
      emit(HabitFailure('Failed to delete habit: $e'));
    }
  }
}
