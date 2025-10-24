import '../../domain/entities/habit.dart';
class HabitModel extends Habit {
  const HabitModel({
    super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.category,
    required super.targetDays,
    super.currentStreak,
    super.longestStreak,
    required super.createdAt,
    super.lastCompletedAt,
    super.isActive,
    super.color,
    super.icon,
  });
  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      userId: habit.userId,
      title: habit.title,
      description: habit.description,
      category: habit.category,
      targetDays: habit.targetDays,
      currentStreak: habit.currentStreak,
      longestStreak: habit.longestStreak,
      createdAt: habit.createdAt,
      lastCompletedAt: habit.lastCompletedAt,
      isActive: habit.isActive,
      color: habit.color,
      icon: habit.icon,
    );
  }
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      targetDays: map['target_days'] as int,
      currentStreak: map['current_streak'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      lastCompletedAt: map['last_completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_completed_at'] as int)
          : null,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      color: map['color'] as String? ?? '#3B82F6',
      icon: map['icon'] as String? ?? 'fitness_center',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'target_days': targetDays,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_completed_at': lastCompletedAt?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'color': color,
      'icon': icon,
    };
  }
  @override
  HabitModel copyWith({
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
    return HabitModel(
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
class HabitCompletionModel extends HabitCompletion {
  const HabitCompletionModel({
    super.id,
    required super.habitId,
    required super.completedAt,
    super.notes,
  });
  factory HabitCompletionModel.fromEntity(HabitCompletion completion) {
    return HabitCompletionModel(
      id: completion.id,
      habitId: completion.habitId,
      completedAt: completion.completedAt,
      notes: completion.notes,
    );
  }
  factory HabitCompletionModel.fromMap(Map<String, dynamic> map) {
    return HabitCompletionModel(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      completedAt: DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int),
      notes: map['notes'] as String?,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'completed_at': completedAt.millisecondsSinceEpoch,
      'notes': notes,
    };
  }
  HabitCompletionModel copyWith({
    int? id,
    int? habitId,
    DateTime? completedAt,
    String? notes,
  }) {
    return HabitCompletionModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
}
