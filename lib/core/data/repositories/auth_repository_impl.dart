import 'package:dartz/dartz.dart';
import 'package:email_validator/email_validator.dart';
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
      if (!EmailValidator.validate(email)) {
        return const Left('Please enter a valid email address');
      }
      final userModel = await _userLocalDataSource.getUserByEmail(email.toLowerCase().trim());
      if (userModel == null) {
        return const Left('Invalid email or password');
      }
      final isPasswordValid = await _passwordService.verifyPassword(password, userModel.passwordHash);
      if (!isPasswordValid) {
        return const Left('Invalid email or password');
      }
      if (userModel.id != null) {
        print('🔐 Sign in successful - userId: ${userModel.id}');
        await _userLocalDataSource.updateLastLogin(userModel.id!, DateTime.now());
        print('🔐 Calling setCurrentUser with userId: ${userModel.id}');
        await _userLocalDataSource.setCurrentUser(userModel.id!);
        print('✅ Current user set successfully');
      }
      final user = userModel.toEntity();
      return Right(AuthResult.success(user));
    } catch (e) {
      return Left('Failed to sign in: ${e.toString()}');
    }
  }
  @override
  Future<Either<String, void>> signOut() async {
    try {
      await _userLocalDataSource.clearCurrentUser();
      return const Right(null);
    } catch (e) {
      return Left('Failed to sign out: ${e.toString()}');
    }
  }
  @override
  Future<Either<String, User?>> getCurrentUser() async {
    try {
      print('🔐 AuthRepository: getCurrentUser() called');
      final userId = await _userLocalDataSource.getCurrentUserId();
      print('🔍 Retrieved userId: $userId');
      if (userId == null) {
        print('⚠️ No userId found - returning null');
        return const Right(null);
      }
      print('🔍 Fetching user by ID: $userId');
      final userModel = await _userLocalDataSource.getUserById(userId);
      if (userModel == null) {
        print('❌ User not found for ID: $userId - clearing current user');
        await _userLocalDataSource.clearCurrentUser();
        return const Right(null);
      }
      print('✅ User found: ${userModel.email}');
      return Right(userModel.toEntity());
    } catch (e) {
      print('❌ Error in getCurrentUser: $e');
      return Left('Failed to get current user: ${e.toString()}');
    }
  }
  @override
  Future<Either<String, bool>> isUserLoggedIn() async {
    try {
      final userId = await _userLocalDataSource.getCurrentUserId();
      return Right(userId != null);
    } catch (e) {
      return Left('Failed to check login status: ${e.toString()}');
    }
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
