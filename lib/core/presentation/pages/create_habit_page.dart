import 'package:flutter/material.dart';
import '../../injection/injection_container.dart' as di;
import '../../domain/entities/habit.dart';
import '../../domain/usecases/create_habit_usecase.dart';

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
      title: 'Make it Specific',
      description: 'Define exactly what you will do, when, and where. Instead of "exercise more," say "I will do 20 push-ups every morning in my bedroom."',
    ),
    const HabitRule(
      title: 'Start Small',
      description: 'Begin with a habit so small it\'s impossible to fail. You can always build up from there. Better to do 1 push-up daily than 100 push-ups once.',
    ),
    const HabitRule(
      title: 'Stack with Existing Habits',
      description: 'Attach your new habit to something you already do consistently. "After I brush my teeth, I will do 5 push-ups."',
    ),
    const HabitRule(
      title: 'Track Progress',
      description: 'Use this app to track your daily progress. Seeing your streak grow will motivate you to continue and not break the chain.',
    ),
  ];

  final List<String> _categories = [
    'Health',
    'Fitness',
    'Learning',
    'Productivity',
    'Mindfulness',
    'Social',
    'Creative',
    'Other',
  ];

  final List<Map<String, String>> _colors = [
    {'name': 'Blue', 'value': '#3B82F6'},
    {'name': 'Green', 'value': '#10B981'},
    {'name': 'Purple', 'value': '#8B5CF6'},
    {'name': 'Orange', 'value': '#F59E0B'},
    {'name': 'Red', 'value': '#EF4444'},
    {'name': 'Pink', 'value': '#EC4899'},
    {'name': 'Indigo', 'value': '#6366F1'},
    {'name': 'Teal', 'value': '#14B8A6'},
  ];

  final List<Map<String, String>> _icons = [
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Create New Habit'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRulesSection(),
                const SizedBox(height: 32),
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

  Widget _buildRulesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '4 Rules for Building Habits',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Follow these proven principles to create habits that stick:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ..._rules.asMap().entries.map((entry) {
            final index = entry.key;
            final rule = entry.value;
            return _buildRuleCard(rule, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildRuleCard(HabitRule rule, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rule.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            'Habit Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Habit Title',
              hintText: 'e.g., Drink 8 glasses of water',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a habit title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Why is this habit important to you?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
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
              labelText: 'Target Days',
              hintText: 'How many days to build this habit?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter target days';
              }
              final days = int.tryParse(value);
              if (days == null || days <= 0) {
                return 'Please enter a valid number of days';
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
            'Customization',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Color',
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
            'Icon',
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
        onPressed: () async {
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
              final result = await createHabitUseCase.call(params);
              
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
                          Text('Habit created successfully!'),
                        ],
                      ),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context, true); // Return true to indicate habit was created
                },
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Error creating habit: $e')),
                    ],
                  ),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Create Habit',
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
