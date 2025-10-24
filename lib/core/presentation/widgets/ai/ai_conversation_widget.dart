import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../services/ai_conversation_service.dart';
import '../inputs/voice_input_widget.dart';

class AIConversationWidget extends StatefulWidget {
  final Function(AIHabitData) onHabitCreated;
  final Function(String) onError;

  const AIConversationWidget({
    super.key,
    required this.onHabitCreated,
    required this.onError,
  });

  @override
  State<AIConversationWidget> createState() => _AIConversationWidgetState();
}

class _AIConversationWidgetState extends State<AIConversationWidget> {
  final AIConversationService _aiService = AIConversationService();
  final TextEditingController _textController = TextEditingController();
  
  String _currentQuestion = '';
  String _userAnswer = '';
  bool _isLoading = false;
  bool _isCreatingHabit = false;
  List<String> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  void _startConversation() {
    setState(() {
      _aiService.reset();
      _currentQuestion = _aiService.currentQuestion;
      _conversationHistory.clear();
    });
  }

  Future<void> _submitAnswer() async {
    if (_userAnswer.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an answer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _conversationHistory.add('You: $_userAnswer');
    });

    try {
      // Add user's answer to the conversation
      _aiService.askNextQuestion(_userAnswer);
      
      if (_aiService.isComplete) {
        // All questions answered, create the habit
        await _createHabit();
      } else {
        // Ask next question
        setState(() {
          _currentQuestion = _aiService.currentQuestion;
          _conversationHistory.add('AI: $_currentQuestion');
          _textController.clear();
          _userAnswer = '';
        });
      }
    } catch (e) {
      widget.onError('Error processing answer: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createHabit() async {
    setState(() {
      _isCreatingHabit = true;
    });

    try {
      final habitData = await _aiService.createHabitFromConversation();
      widget.onHabitCreated(habitData);
    } catch (e) {
      widget.onError('Failed to create habit: $e');
    } finally {
      setState(() {
        _isCreatingHabit = false;
      });
    }
  }

  void _resetConversation() {
    _aiService.reset();
    _textController.clear();
    _userAnswer = '';
    _conversationHistory.clear();
    _startConversation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Habit Creator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_aiService.currentStep}/${_aiService.totalSteps}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          LinearProgressIndicator(
            value: _aiService.currentStep / _aiService.totalSteps,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 20),

          // Conversation History
          if (_conversationHistory.isNotEmpty) ...[
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.builder(
                itemCount: _conversationHistory.length,
                itemBuilder: (context, index) {
                  final message = _conversationHistory[index];
                  final isUser = message.startsWith('You:');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isUser ? Icons.person : Icons.smart_toy,
                          color: isUser ? AppColors.primary : AppColors.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_isCreatingHabit) ...[
            // Creating habit state
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Creating your habit...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Current Question
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_toy,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentQuestion,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Voice Input
            VoiceInputWidget(
              onTextReceived: (text) {
                setState(() {
                  _userAnswer = text;
                  _textController.text = text;
                });
              },
              onError: widget.onError,
              isEnabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Manual Input
            TextField(
              controller: _textController,
              enabled: !_isLoading,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (text) {
                setState(() {
                  _userAnswer = text;
                });
              },
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _userAnswer.trim().isEmpty 
                        ? null 
                        : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _aiService.isComplete ? 'Create Habit' : 'Submit Answer',
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _resetConversation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Restart'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
