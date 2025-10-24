import 'package:flutter/material.dart';
import '../../injection/injection_container.dart' as di;
import '../../domain/entities/habit.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../widgets/collapsible_widgets.dart';
import '../widgets/cards/rule_card.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
class CreateHabitPage extends StatefulWidget {
  final int userId;
  const CreateHabitPage({super.key, required this.userId});
  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}
class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetDaysController = TextEditingController(text: '30');
  String _selectedCategory = 'Health';
  String _selectedColor = '#3B82F6';
  String _selectedIcon = 'fitness_center';
  
  final List<HabitRule> _rules = [
    const HabitRule(
      title: AppStrings.rule1Title,
      description: AppStrings.rule1Description,
      isAccepted: false,
    ),
    const HabitRule(
      title: AppStrings.rule2Title,
      description: AppStrings.rule2Description,
      isAccepted: false,
    ),
    const HabitRule(
      title: AppStrings.rule3Title,
      description: AppStrings.rule3Description,
      isAccepted: false,
    ),
    const HabitRule(
      title: AppStrings.rule4Title,
      description: AppStrings.rule4Description,
      isAccepted: false,
    ),
  ];
  final List<String> _categories = [
    AppStrings.health,
    AppStrings.fitness,
    AppStrings.learning,
    AppStrings.productivity,
    AppStrings.mindfulness,
    AppStrings.social,
    AppStrings.creative,
    AppStrings.other,
  ];
  final List<Map<String, String>> _colors = [
    {'name': AppStrings.blue, 'value': '#3B82F6'},
    {'name': AppStrings.green, 'value': '#10B981'},
    {'name': AppStrings.purple, 'value': '#8B5CF6'},
    {'name': AppStrings.orange, 'value': '#F59E0B'},
    {'name': AppStrings.red, 'value': '#EF4444'},
    {'name': AppStrings.pink, 'value': '#EC4899'},
    {'name': AppStrings.indigo, 'value': '#6366F1'},
    {'name': AppStrings.teal, 'value': '#14B8A6'},
  ];
  final List<Map<String, String>> _icons = [
    {'name': AppStrings.fitnessIcon, 'value': 'fitness_center'},
    {'name': AppStrings.bookIcon, 'value': 'book'},
    {'name': AppStrings.waterIcon, 'value': 'water_drop'},
    {'name': AppStrings.sleepIcon, 'value': 'bedtime'},
    {'name': AppStrings.foodIcon, 'value': 'restaurant'},
    {'name': AppStrings.workIcon, 'value': 'work'},
    {'name': AppStrings.schoolIcon, 'value': 'school'},
    {'name': AppStrings.homeIcon, 'value': 'home'},
  ];
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetDaysController.dispose();
    super.dispose();
  }

  void _createHabit() {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final params = CreateHabitParams(
          userId: widget.userId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          targetDays: int.parse(_targetDaysController.text),
          color: _selectedColor,
          icon: _selectedIcon,
        );
        final createHabitUseCase = di.sl<CreateHabitUseCase>();
        createHabitUseCase.call(params).then((result) {
          result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(failure)),
                    ],
                  ),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            (habit) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(AppStrings.habitCreatedSuccess),
                    ],
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
              Navigator.pop(context, true); 
            },
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('${AppStrings.habitCreatedError} $e')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.createNewHabitWithRules),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _createHabit,
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            tooltip: 'Create Habit',
          ),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CollapsibleSection(
                  title: AppStrings.fourRulesTitle,
                  icon: Icons.lightbulb_outline,
                  initiallyExpanded: false,
                  content: _buildRulesContent(),
                ),
                const SizedBox(height: 32),
                
                // Voice Input Section
                // Removed voice input section
                
                // Manual Form Section
                _buildFormSection(),
                const SizedBox(height: 32),
                _buildCustomizationSection(),
                const SizedBox(height: 32),
                
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      );
  }
  Widget _buildRulesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.fourRulesDescription,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        ..._rules.asMap().entries.map((entry) {
          final index = entry.key;
          final rule = entry.value;
          return RuleCard(rule: rule, number: index + 1);
        }),
      ],
    );
  }
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.habitDetails,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: AppStrings.habitTitle,
              hintText: AppStrings.habitTitleHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterHabitTitle;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: AppStrings.description,
              hintText: AppStrings.descriptionHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterDescription;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: AppStrings.category,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'Health';
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _targetDaysController,
            decoration: InputDecoration(
              labelText: AppStrings.targetDays,
              hintText: AppStrings.targetDaysHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterTargetDays;
              }
              final days = int.tryParse(value);
              if (days == null || days <= 0) {
                return AppStrings.pleaseEnterValidDays;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  Widget _buildCustomizationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.customization,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.color,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((color) {
              final isSelected = _selectedColor == color['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color['value'] ?? '#3B82F6';
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse((color['value'] ?? '#3B82F6').replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.transparent,
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
          const SizedBox(height: 24),
          Text(
            AppStrings.icon,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _icons.map((icon) {
              final isSelected = _selectedIcon == icon['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = icon['value'] ?? 'fitness_center';
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300] ?? Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getIconData(icon['value'] ?? 'fitness_center'),
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 24,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          AppStrings.createHabit,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
