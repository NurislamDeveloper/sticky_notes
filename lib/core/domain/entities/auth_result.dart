import 'package:equatable/equatable.dart';
import 'user.dart';
class AuthResult extends Equatable {
  final User? user;
  final String? errorMessage;
  final bool isSuccess;
  const AuthResult({
    this.user,
    this.errorMessage,
    required this.isSuccess,
  });
  factory AuthResult.success(User user) {
    return AuthResult(
      user: user,
      isSuccess: true,
    );
  }
  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      errorMessage: errorMessage,
      isSuccess: false,
    );
  }
  @override
  List<Object?> get props => [user, errorMessage, isSuccess];
}
