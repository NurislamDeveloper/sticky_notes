import 'dart:convert';
import 'package:http/http.dart' as http;

class AIConversationService {
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with actual API key
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  List<Map<String, String>> _conversationHistory = [];
  int _currentStep = 0;
  
  // Questions the AI will ask
  final List<String> _questions = [
    "What habit would you like to create? Please describe it clearly.",
    "Why is this habit important to you? What's your motivation?",
    "When would you like to do this habit? (morning, evening, specific time)",
    "Where will you do this habit? (home, gym, office, etc.)",
    "How often do you want to do this habit? (daily, weekly, etc.)",
    "What's your target? How many days do you want to maintain this habit?",
  ];

  int get currentStep => _currentStep;
  int get totalSteps => _questions.length;
  bool get isComplete => _currentStep >= _questions.length;
  String get currentQuestion => _currentStep < _questions.length ? _questions[_currentStep] : '';

  void reset() {
    _conversationHistory.clear();
    _currentStep = 0;
  }

  String askNextQuestion(String userAnswer) {
    // Add user's answer to conversation history if provided
    if (userAnswer.isNotEmpty) {
      _conversationHistory.add({
        'role': 'user',
        'content': userAnswer,
      });
    }

    // Check if we've completed all questions
    if (_currentStep >= _questions.length) {
      return 'Conversation complete!';
    }

    // Get the current question and move to next step
    final question = _questions[_currentStep];
    _currentStep++;
    
    return question;
  }

  Future<AIHabitData> createHabitFromConversation() async {
    if (_conversationHistory.isEmpty) {
      throw Exception('No conversation data available');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''Based on the conversation with the user, create a complete habit with the following information:
1. Title: A clear, specific habit title (max 50 characters)
2. Description: Why this habit is important based on their motivation
3. Category: One of: Health, Fitness, Learning, Productivity, Mindfulness, Social, Creative, Other
4. Target Days: Number of days (30-90) based on their target
5. Color: A hex color code that matches the habit type
6. Icon: An icon name from: fitness_center, book, water_drop, bedtime, restaurant, work, school, home

Return ONLY a JSON response with these exact fields:
{
  "title": "string",
  "description": "string", 
  "category": "string",
  "targetDays": number,
  "color": "string",
  "icon": "string"
}'''
            },
            ..._conversationHistory,
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return AIHabitData.fromJson(jsonDecode(content));
      } else {
        throw Exception('Failed to create habit: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to local creation if API fails
      return _createFallbackHabit();
    }
  }

  AIHabitData _createFallbackHabit() {
    // Create a habit based on the conversation history
    final answers = _conversationHistory.map((msg) => msg['content']).join(' ').toLowerCase();
    
    String title = 'Daily Habit';
    String description = 'Building consistent habits for success.';
    String category = 'Other';
    int targetDays = 30;
    String color = '#3B82F6';
    String icon = 'fitness_center';

    if (answers.contains('exercise') || answers.contains('workout') || answers.contains('gym')) {
      title = 'Daily Exercise';
      description = 'Regular physical activity for better health and energy.';
      category = 'Fitness';
      color = '#3B82F6';
      icon = 'fitness_center';
    } else if (answers.contains('read') || answers.contains('book') || answers.contains('study')) {
      title = 'Daily Reading';
      description = 'Reading to expand knowledge and improve focus.';
      category = 'Learning';
      color = '#10B981';
      icon = 'book';
    } else if (answers.contains('water') || answers.contains('drink') || answers.contains('hydrate')) {
      title = 'Drink More Water';
      description = 'Proper hydration for better health and energy.';
      category = 'Health';
      color = '#14B8A6';
      icon = 'water_drop';
    } else if (answers.contains('sleep') || answers.contains('bedtime') || answers.contains('rest')) {
      title = 'Better Sleep';
      description = 'Consistent sleep schedule for better health.';
      category = 'Health';
      color = '#8B5CF6';
      icon = 'bedtime';
    }

    // Extract target days if mentioned
    final dayMatch = RegExp(r'(\d+)\s*days?').firstMatch(answers);
    if (dayMatch != null) {
      targetDays = int.tryParse(dayMatch.group(1)!) ?? 30;
    }

    return AIHabitData(
      title: title,
      description: description,
      category: category,
      targetDays: targetDays,
      color: color,
      icon: icon,
    );
  }
}

class AIHabitData {
  final String title;
  final String description;
  final String category;
  final int targetDays;
  final String color;
  final String icon;

  AIHabitData({
    required this.title,
    required this.description,
    required this.category,
    required this.targetDays,
    required this.color,
    required this.icon,
  });

  factory AIHabitData.fromJson(Map<String, dynamic> json) {
    return AIHabitData(
      title: json['title'] ?? 'Daily Habit',
      description: json['description'] ?? 'Building consistent habits for success.',
      category: json['category'] ?? 'Other',
      targetDays: json['targetDays'] ?? 30,
      color: json['color'] ?? '#3B82F6',
      icon: json['icon'] ?? 'fitness_center',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'targetDays': targetDays,
      'color': color,
      'icon': icon,
    };
  }
}
