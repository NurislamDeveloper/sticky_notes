import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class UpdateAvatarUseCase {
  final AuthRepository _authRepository;

  UpdateAvatarUseCase(this._authRepository);

  Future<Either<String, void>> call({
    required int userId,
    required String avatarPath,
  }) async {
    try {
      return await _authRepository.updateAvatar(
        userId: userId,
        avatarPath: avatarPath,
      );
    } catch (e) {
      return Left('Failed to update avatar: $e');
    }
  }
}
