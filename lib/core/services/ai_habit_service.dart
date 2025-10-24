import 'dart:convert';
import 'package:http/http.dart' as http;

class AIHabitService {
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with actual API key
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<AIHabitSuggestion> generateHabitSuggestion(String voiceText) async {
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
              'content': '''You are a habit formation expert. Based on the user's voice input, suggest a specific, actionable habit following these rules:
1. Make it specific - define exactly what, when, and where
2. Start small - make it achievable
3. Stack with existing habits - attach to something they already do
4. Track progress - suggest how to measure success

Return a JSON response with:
- title: A clear, specific habit title
- description: Why this habit is important
- category: One of: Health, Fitness, Learning, Productivity, Mindfulness, Social, Creative, Other
- targetDays: Suggested number of days (30-90)
- color: A hex color code
- icon: An icon name from: fitness_center, book, water_drop, bedtime, restaurant, work, school, home
- tips: Array of 2-3 specific tips for success'''
            },
            {
              'role': 'user',
              'content': 'User said: "$voiceText"'
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return AIHabitSuggestion.fromJson(jsonDecode(content));
      } else {
        throw Exception('Failed to generate habit suggestion: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to local suggestion if API fails
      return _generateFallbackSuggestion(voiceText);
    }
  }

  AIHabitSuggestion _generateFallbackSuggestion(String voiceText) {
    // Simple keyword-based fallback suggestions
    final text = voiceText.toLowerCase();
    
    if (text.contains('exercise') || text.contains('workout') || text.contains('gym')) {
      return AIHabitSuggestion(
        title: 'Daily Exercise',
        description: 'Regular physical activity improves health and energy levels.',
        category: 'Fitness',
        targetDays: 30,
        color: '#3B82F6',
        icon: 'fitness_center',
        tips: [
          'Start with 10 minutes of exercise daily',
          'Choose activities you enjoy',
          'Track your workouts in the app'
        ],
      );
    } else if (text.contains('read') || text.contains('book') || text.contains('study')) {
      return AIHabitSuggestion(
        title: 'Daily Reading',
        description: 'Reading expands knowledge and improves focus.',
        category: 'Learning',
        targetDays: 30,
        color: '#10B981',
        icon: 'book',
        tips: [
          'Read for 15 minutes before bed',
          'Keep a book nearby',
          'Track pages read daily'
        ],
      );
    } else if (text.contains('water') || text.contains('drink') || text.contains('hydrate')) {
      return AIHabitSuggestion(
        title: 'Drink More Water',
        description: 'Proper hydration is essential for health and energy.',
        category: 'Health',
        targetDays: 30,
        color: '#14B8A6',
        icon: 'water_drop',
        tips: [
          'Drink a glass of water after waking up',
          'Set hourly reminders',
          'Track glasses consumed'
        ],
      );
    } else {
      return AIHabitSuggestion(
        title: 'Daily Habit',
        description: 'Building consistent daily habits leads to long-term success.',
        category: 'Other',
        targetDays: 30,
        color: '#8B5CF6',
        icon: 'fitness_center',
        tips: [
          'Start small and build gradually',
          'Be consistent with timing',
          'Track your progress daily'
        ],
      );
    }
  }
}

class AIHabitSuggestion {
  final String title;
  final String description;
  final String category;
  final int targetDays;
  final String color;
  final String icon;
  final List<String> tips;

  AIHabitSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.targetDays,
    required this.color,
    required this.icon,
    required this.tips,
  });

  factory AIHabitSuggestion.fromJson(Map<String, dynamic> json) {
    return AIHabitSuggestion(
      title: json['title'] ?? 'Daily Habit',
      description: json['description'] ?? 'Building consistent habits for success.',
      category: json['category'] ?? 'Other',
      targetDays: json['targetDays'] ?? 30,
      color: json['color'] ?? '#3B82F6',
      icon: json['icon'] ?? 'fitness_center',
      tips: List<String>.from(json['tips'] ?? ['Start small and be consistent']),
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
      'tips': tips,
    };
  }
}

