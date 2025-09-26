import 'package:dartz/dartz.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../models/user_model.dart';
import '../services/password_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final UserLocalDataSource _userLocalDataSource;
  final PasswordService _passwordService;

  AuthRepositoryImpl(
    this._userLocalDataSource,
    this._passwordService,
  );

  @override
  Future<Either<String, AuthResult>> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      if (!EmailValidator.validate(email)) {
        return const Left('Please enter a valid email address');
      }

      if (await _userLocalDataSource.emailExists(email)) {
        return const Left('Email already exists');
      }

      if (await _userLocalDataSource.usernameExists(username)) {
        return const Left('Username already exists');
      }

      final passwordHash = await _passwordService.hashPassword(password);

      final userModel = UserModel(
        email: email.toLowerCase().trim(),
        username: username.trim(),
        passwordHash: passwordHash,
        createdAt: DateTime.now(),
      );

      final createdUser = await _userLocalDataSource.createUser(userModel);
      final user = createdUser.toEntity();

      return Right(AuthResult.success(user));
    } catch (e) {
      return Left('Failed to create account: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AuthResult>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Sign in attempt for email: $email');
      
      if (!EmailValidator.validate(email)) {
        debugPrint('Invalid email format: $email');
        return const Left('Please enter a valid email address');
      }

      final userModel = await _userLocalDataSource.getUserByEmail(email.toLowerCase().trim());
      if (userModel == null) {
        debugPrint('User not found for email: $email');
        return const Left('Invalid email or password');
      }

      debugPrint('User found: ${userModel.email}, ID: ${userModel.id}');
      debugPrint('Stored password hash: ${userModel.passwordHash}');
      debugPrint('Input password: $password');

      final isPasswordValid = await _passwordService.verifyPassword(password, userModel.passwordHash);
      debugPrint('Password verification result: $isPasswordValid');
      
      if (!isPasswordValid) {
        debugPrint('Password verification failed');
        return const Left('Invalid email or password');
      }

      await _userLocalDataSource.updateLastLogin(userModel.id!, DateTime.now());

      final user = userModel.toEntity();
      return Right(AuthResult.success(user));
    } catch (e) {
      return Left('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    return const Right(null);
  }

  @override
  Future<Either<String, User?>> getCurrentUser() async {
    return const Right(null);
  }

  @override
  Future<Either<String, bool>> isUserLoggedIn() async {
    return const Right(false);
  }

  @override
  Future<Either<String, void>> updateAvatar({
    required int userId,
    required String avatarPath,
  }) async {
    try {
      await _userLocalDataSource.updateAvatarPath(userId, avatarPath);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update avatar: ${e.toString()}');
    }
  }
}
