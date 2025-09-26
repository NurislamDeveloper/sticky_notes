import '../../domain/entities/user.dart';

class UserModel extends User {
  final String passwordHash;
  final String? avatarPath;

  const UserModel({
    super.id,
    required super.email,
    required super.username,
    required super.createdAt,
    super.lastLoginAt,
    required this.passwordHash,
    this.avatarPath,
  });

  factory UserModel.fromEntity(User user, String passwordHash, {String? avatarPath}) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      passwordHash: passwordHash,
      avatarPath: avatarPath,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      email: map['email'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_login_at'] as int)
          : null,
      avatarPath: map['avatar_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password_hash': passwordHash,
      'avatar_path': avatarPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_login_at': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  @override
  UserModel copyWith({
    int? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? passwordHash,
    String? avatarPath,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      passwordHash: passwordHash ?? this.passwordHash,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
