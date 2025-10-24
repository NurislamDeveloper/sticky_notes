import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final daysSinceCreated = DateTime.now().difference(habit.createdAt).inDays;
    final completionRate = daysSinceCreated > 0
        ? (habit.currentStreak / daysSinceCreated * 100).clamp(0.0, 100.0)
        : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _parseColor(habit.color),
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                _parseColor(habit.color).withValues(alpha: 0.8),
                _parseColor(habit.color).withValues(alpha: 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      _getIconData(habit.icon),
                      color: Colors.white,
                      size: 30,
                    ),
                    Text(
                      '${habit.currentStreak} / ${habit.targetDays} days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  habit.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  habit.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                LinearProgressIndicator(
                  value: habit.currentStreak / habit.targetDays.toDouble(),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${completionRate.toStringAsFixed(0)}% Completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _getStreakStatus(habit),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _getStreakStatus(Habit habit) {
    if (habit.currentStreak >= habit.targetDays) {
      return 'Goal Achieved!';
    } else if (habit.currentStreak > 0) {
      return 'Streak: ${habit.currentStreak} days';
    } else {
      return 'Start Today!';
    }
  }
  Color _parseColor(String colorString) {
    try {
      String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      } else if (cleanColor.length == 8) {
        return Color(int.parse(cleanColor, radix: 16));
      }
    } catch (e) {
      debugPrint('Error parsing color: $colorString, error: $e');
    }
    return const Color(0xFF3B82F6); 
  }
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'water_drop':
        return Icons.water_drop;
      case 'bedtime':
        return Icons.bedtime;
      case 'fastfood':
        return Icons.fastfood;
      case 'code':
        return Icons.code;
      case 'clean_hands':
        return Icons.clean_hands;
      case 'money':
        return Icons.money;
      case 'meditation':
        return Icons.self_improvement;
      case 'lightbulb':
        return Icons.lightbulb;
      default:
        return Icons.check_circle_outline;
    }
  }
}
