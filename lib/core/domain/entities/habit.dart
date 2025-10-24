import 'package:equatable/equatable.dart';
class Habit extends Equatable {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String category;
  final int targetDays;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime? lastCompletedAt;
  final bool isActive;
  final String color;
  final String icon;
  const Habit({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDays,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.createdAt,
    this.lastCompletedAt,
    this.isActive = true,
    this.color = '#3B82F6',
    this.icon = 'fitness_center',
  });
  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        category,
        targetDays,
        currentStreak,
        longestStreak,
        createdAt,
        lastCompletedAt,
        isActive,
        color,
        icon,
      ];
  Habit copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? category,
    int? targetDays,
    int? currentStreak,
    int? longestStreak,
    DateTime? createdAt,
    DateTime? lastCompletedAt,
    bool? isActive,
    String? color,
    String? icon,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDays: targetDays ?? this.targetDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      isActive: isActive ?? this.isActive,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
class HabitCompletion extends Equatable {
  final int? id;
  final int habitId;
  final DateTime completedAt;
  final String? notes;
  const HabitCompletion({
    this.id,
    required this.habitId,
    required this.completedAt,
    this.notes,
  });
  @override
  List<Object?> get props => [id, habitId, completedAt, notes];
}
class HabitRule extends Equatable {
  final String title;
  final String description;
  final bool isAccepted;
  const HabitRule({
    required this.title,
    required this.description,
    this.isAccepted = false,
  });
  @override
  List<Object?> get props => [title, description, isAccepted];
  HabitRule copyWith({
    String? title,
    String? description,
    bool? isAccepted,
  }) {
    return HabitRule(
      title: title ?? this.title,
      description: description ?? this.description,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }
}
