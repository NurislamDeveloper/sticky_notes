import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import '../../../domain/usecases/sign_in_usecase.dart';
import '../../../domain/usecases/update_avatar_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final UpdateAvatarUseCase _updateAvatarUseCase;

  AuthBloc({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required UpdateAvatarUseCase updateAvatarUseCase,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _updateAvatarUseCase = updateAvatarUseCase,
        super(AuthInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<UpdateAvatarRequested>(_onUpdateAvatarRequested);
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signUpUseCase(
      email: event.email,
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          emit(AuthSuccess(authResult.user!));
        } else {
          emit(AuthFailure(authResult.errorMessage ?? 'Unknown error occurred'));
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signInUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (authResult) {
        if (authResult.isSuccess && authResult.user != null) {
          emit(AuthSuccess(authResult.user!));
        } else {
          emit(AuthFailure(authResult.errorMessage ?? 'Unknown error occurred'));
        }
      },
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInitial());
  }

  Future<void> _onUpdateAvatarRequested(
    UpdateAvatarRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _updateAvatarUseCase(
        userId: event.userId,
        avatarPath: event.avatarPath,
      );
      
      if (result.isLeft()) {
        return;
      }
      
      final currentState = state;
      if (currentState is AuthSuccess) {
        final updatedUser = currentState.user.copyWith(avatarPath: event.avatarPath);
        emit(AuthSuccess(updatedUser));
      }
    } catch (e) {
      // Error handling
    }
  }
}
