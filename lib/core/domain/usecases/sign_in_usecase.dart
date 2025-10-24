import 'package:dartz/dartz.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';
class SignInUseCase {
  final AuthRepository _authRepository;
  SignInUseCase(this._authRepository);
  Future<Either<String, AuthResult>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return const Left('Email and password are required');
    }
    return await _authRepository.signIn(
      email: email,
      password: password,
    );
  }
}
