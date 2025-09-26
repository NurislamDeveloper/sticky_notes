import 'package:dartz/dartz.dart';
import 'package:sticky_notes/core/domain/entities/auth_result.dart';
import 'package:sticky_notes/core/domain/entities/user.dart';
import 'package:sticky_notes/core/domain/usecases/sign_up_usecase.dart';
import 'package:sticky_notes/core/domain/usecases/sign_in_usecase.dart';

class MockSignUpUseCase implements SignUpUseCase {
  @override
  Future<Either<String, AuthResult>> call({
    required String email,
    required String username,
    required String password,
  }) async {
    final mockUser = User(
      email: email,
      username: username,
      createdAt: DateTime.now(),
    );
    return Right(AuthResult.success(mockUser));
  }
}

class MockSignInUseCase implements SignInUseCase {
  @override
  Future<Either<String, AuthResult>> call({
    required String email,
    required String password,
  }) async {
    final mockUser = User(
      email: email,
      username: 'testuser',
      createdAt: DateTime.now(),
    );
    return Right(AuthResult.success(mockUser));
  }
}
