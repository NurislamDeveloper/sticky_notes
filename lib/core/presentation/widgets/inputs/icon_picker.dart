import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class IconPicker extends StatelessWidget {
  final String selectedIcon;
  final Function(String) onIconSelected;
  final String title;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.title = 'Icon',
  });

  static const List<Map<String, String>> _icons = [
    {'name': 'Fitness', 'value': 'fitness_center'},
    {'name': 'Book', 'value': 'book'},
    {'name': 'Water', 'value': 'water_drop'},
    {'name': 'Sleep', 'value': 'bedtime'},
    {'name': 'Food', 'value': 'restaurant'},
    {'name': 'Work', 'value': 'work'},
    {'name': 'School', 'value': 'school'},
    {'name': 'Home', 'value': 'home'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _icons.map((icon) {
            final isSelected = selectedIcon == icon['value'];
            return GestureDetector(
              onTap: () => onIconSelected(icon['value']!),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getIconData(icon['value']!),
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 24,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'water_drop':
        return Icons.water_drop;
      case 'bedtime':
        return Icons.bedtime;
      case 'restaurant':
        return Icons.restaurant;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      default:
        return Icons.fitness_center;
    }
  }
}
