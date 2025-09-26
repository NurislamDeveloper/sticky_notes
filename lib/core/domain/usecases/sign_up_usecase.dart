import 'package:dartz/dartz.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  Future<Either<String, AuthResult>> call({
    required String email,
    required String username,
    required String password,
  }) async {
    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      return const Left('All fields are required');
    }

    if (password.length < 6) {
      return const Left('Password must be at least 6 characters long');
    }
    return await _authRepository.signUp(
      email: email,
      username: username,
      password: password,
    );
  }
}
