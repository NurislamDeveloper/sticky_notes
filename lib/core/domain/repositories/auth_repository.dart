import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/auth_result.dart';
abstract class AuthRepository {
  Future<Either<String, AuthResult>> signUp({
    required String email,
    required String username,
    required String password,
  });
  Future<Either<String, AuthResult>> signIn({
    required String email,
    required String password,
  });
  Future<Either<String, void>> signOut();
  Future<Either<String, User?>> getCurrentUser();
  Future<Either<String, bool>> isUserLoggedIn();
  Future<Either<String, void>> updateAvatar({
    required int userId,
    required String avatarPath,
  });
}
