import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../services/voice_input_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onTextReceived;
  final Function(String) onError;
  final String? initialText;
  final bool isEnabled;

  const VoiceInputWidget({
    super.key,
    required this.onTextReceived,
    required this.onError,
    this.initialText,
    this.isEnabled = true,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  final TextEditingController _textController = TextEditingController();
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  bool _isInitialized = false;
  String _currentText = '';
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText ?? '';
    _currentText = widget.initialText ?? '';
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    final isAvailable = await _voiceService.initialize();
    setState(() {
      _isInitialized = isAvailable;
      _statusMessage = isAvailable 
          ? 'Voice input ready' 
          : 'Voice input not available';
    });
  }

  Future<void> _startListening() async {
    if (!_isInitialized || !widget.isEnabled) return;

    setState(() {
      _statusMessage = 'Listening... Speak now!';
    });

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    await _voiceService.startListening(
      onResult: (text) {
        setState(() {
          _currentText = text;
          _textController.text = text;
        });
        widget.onTextReceived(text);
      },
      onError: (error) {
        setState(() {
          _statusMessage = 'Error: $error';
        });
        widget.onError(error);
        _stopAnimations();
      },
    );
  }

  Future<void> _stopListening() async {
    await _voiceService.stopListening(
      onResult: (text) {
        setState(() {
          _currentText = text;
          _textController.text = text;
          _statusMessage = 'Voice input ready';
        });
        widget.onTextReceived(text);
      },
      onError: (error) {
        setState(() {
          _statusMessage = 'Error: $error';
        });
        widget.onError(error);
      },
    );
    _stopAnimations();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
    _pulseController.reset();
    _waveController.reset();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Answer Input',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_isInitialized && widget.isEnabled)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _voiceService.isListening ? _pulseAnimation.value : 1.0,
                      child: GestureDetector(
                        onTap: _voiceService.isListening ? _stopListening : _startListening,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _voiceService.isListening 
                                ? AppColors.error 
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _voiceService.isListening ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            enabled: widget.isEnabled,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your answer to the AI question above...',
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
                _currentText = text;
              });
              widget.onTextReceived(text);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _isInitialized ? Icons.check_circle : Icons.error,
                color: _isInitialized ? AppColors.success : AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: _isInitialized ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          if (_voiceService.isListening) ...[
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return Row(
                  children: List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 4,
                      height: 20 * (0.5 + 0.5 * (1 - (index * 0.2 - _waveAnimation.value).abs())),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
