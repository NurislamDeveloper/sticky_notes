import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String email;
  final String username;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? avatarPath;

  const User({
    this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    this.lastLoginAt,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [id, email, username, createdAt, lastLoginAt, avatarPath];

  User copyWith({
    int? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? avatarPath,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
