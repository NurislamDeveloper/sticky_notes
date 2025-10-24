class VoiceInputService {
  bool _isListening = false;
  bool _isAvailable = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  Future<bool> initialize() async {
    try {
      // Check microphone availability (simulated for now)
      // In a real app, use permission_handler to check RECORD_AUDIO permission
      _isAvailable = true;
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      return false;
    }
  }

  Future<String?> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isAvailable) {
      onError('Microphone permission not granted. Please enable microphone permissions in Settings > Apps > NoteFlow > Permissions > Microphone');
      return null;
    }

    try {
      _isListening = true;
      
      return null;
    } catch (e) {
      onError('Error starting voice recording: $e');
      _isListening = false;
      return null;
    }
  }

  Future<void> stopListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_isListening) return;

    try {
      _isListening = false;
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      final transcription = _getRandomResponse();
      onResult(transcription);
    } catch (e) {
      onError('Error stopping voice recording: $e');
      _isListening = false;
    }
  }

  String _getRandomResponse() {
    final responses = [
      'I want to exercise more to stay healthy and improve my fitness',
      'Reading books helps me learn new things and expand my knowledge',
      'I would like to meditate every morning for mental clarity',
      'I want to drink more water daily to stay hydrated',
      'I need to sleep better at night for better energy',
      'Morning is the best time for me to exercise',
      '30 days sounds like a good target for building this habit',
      'I can do this at home easily without any equipment',
      'I want to develop a consistent morning routine',
      'Building this habit will improve my overall wellness',
    ];
    
    responses.shuffle();
    return responses.first;
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      _isListening = false;
    }
  }

  void dispose() {
    _isListening = false;
  }
}
