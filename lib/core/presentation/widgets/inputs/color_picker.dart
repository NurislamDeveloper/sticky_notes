import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ColorPicker extends StatelessWidget {
  final String selectedColor;
  final Function(String) onColorSelected;
  final String title;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.title = 'Color',
  });

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
          children: AppColors.habitColorValues.asMap().entries.map((entry) {
            final index = entry.key;
            final colorValue = entry.value;
            final isSelected = selectedColor == colorValue;
            
            return GestureDetector(
              onTap: () => onColorSelected(colorValue),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(colorValue.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.textPrimary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
