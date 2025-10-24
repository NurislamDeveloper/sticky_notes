import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteflow/core/presentation/bloc/habit/habit_event.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/usecases/create_habit_usecase.dart';
import '../../../domain/usecases/get_user_habits_usecase.dart';
import '../../../domain/usecases/complete_habit_usecase.dart';
import '../../../domain/usecases/delete_habit_usecase.dart';
import 'habit_state.dart';
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
      emit(HabitDeleted(event.habitId));
    } catch (e) {
      emit(HabitFailure('Failed to delete habit: $e'));
    }
  }
}
