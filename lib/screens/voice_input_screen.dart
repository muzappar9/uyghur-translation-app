import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/voice_button.dart';
import '../i18n/localizations.dart';

/// VoiceInputScreen: 语音输入页
/// 使用 VoiceButton 和 VoiceWaveform 组件，带麦克风波纹动画
class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController1;
  late AnimationController _rippleController2;
  late AnimationController _rippleController3;
  late AnimationController _waveformController;

  bool _isListening = false;
  String _recognizedText = '';
  String _partialText = '';

  @override
  void initState() {
    super.initState();

    _rippleController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rippleController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rippleController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _rippleController1.dispose();
    _rippleController2.dispose();
    _rippleController3.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    // 波纹错开启动
    _rippleController1.repeat();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isListening) _rippleController2.repeat();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _isListening) _rippleController3.repeat();
    });
  }

  void _stopAnimations() {
    _rippleController1.stop();
    _rippleController1.reset();
    _rippleController2.stop();
    _rippleController2.reset();
    _rippleController3.stop();
    _rippleController3.reset();
  }

  void _toggleListening() {
    HapticFeedback.mediumImpact();

    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _partialText = '';
      }
    });

    if (_isListening) {
      _startAnimations();
      // 模拟语音识别过程
      _simulateSpeechRecognition();
    } else {
      _stopAnimations();
      // 完成识别
      if (_partialText.isNotEmpty) {
        setState(() {
          _recognizedText = _partialText;
        });
      }
    }
  }

  void _simulateSpeechRecognition() {
    final phrases = ['你好', '你好，', '你好，请问', '你好，请问有什么', '你好，请问有什么可以帮您？'];
    int index = 0;

    void updateText() {
      if (!mounted || !_isListening || index >= phrases.length) return;

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _isListening) {
          setState(() {
            _partialText = phrases[index];
          });
          index++;
          if (index < phrases.length) {
            updateText();
          } else {
            // 自动停止
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _isListening) {
                _toggleListening();
              }
            });
          }
        }
      });
    }

    updateText();
  }

  void _clearText() {
    HapticFeedback.lightImpact();
    setState(() {
      _recognizedText = '';
      _partialText = '';
    });
  }

  void _copyText() {
    if (_recognizedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _recognizedText));
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t(context, 'common.copied')),
          backgroundColor: const Color(0xFFFF7F50),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _useForTranslation() {
    if (_recognizedText.isNotEmpty) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context, _recognizedText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF7F50), // Coral
              Color(0xFFFF6B6B),
              Color(0xFFFF8E53),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t(context, 'voice.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (_recognizedText.isNotEmpty)
                      IconButton(
                        onPressed: _clearText,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: t(context, 'common.clear'),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Status Text with animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _isListening
                      ? t(context, 'voice.status.listening')
                      : _recognizedText.isNotEmpty
                          ? t(context, 'voice.status.complete')
                          : t(context, 'voice.status.ready'),
                  key:
                      ValueKey('${_isListening}_${_recognizedText.isNotEmpty}'),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Waveform visualization when listening
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isListening ? 60 : 0,
                child: _isListening
                    ? VoiceWaveform(
                        barCount: 20,
                        color: Colors.white,
                        height: 40,
                        barWidth: 4,
                        isActive: _isListening,
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Main Voice Button with ripples
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 波纹层1
                    if (_isListening)
                      AnimatedBuilder(
                        animation: _rippleController1,
                        builder: (context, child) {
                          return _buildRipple(_rippleController1.value, 180);
                        },
                      ),
                    // 波纹层2
                    if (_isListening)
                      AnimatedBuilder(
                        animation: _rippleController2,
                        builder: (context, child) {
                          return _buildRipple(_rippleController2.value, 160);
                        },
                      ),
                    // 波纹层3
                    if (_isListening)
                      AnimatedBuilder(
                        animation: _rippleController3,
                        builder: (context, child) {
                          return _buildRipple(_rippleController3.value, 140);
                        },
                      ),
                    // 主麦克风按钮 - 使用 VoiceButton
                    VoiceButton(
                      size: 120,
                      isListening: _isListening,
                      onTap: _toggleListening,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Hint text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _isListening
                      ? t(context, 'voice.hint.speak')
                      : _recognizedText.isEmpty
                          ? t(context, 'voice.hint.tap')
                          : t(context, 'voice.hint.tapAgain'),
                  key: ValueKey('hint_$_isListening${_recognizedText.isEmpty}'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Real-time Text Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  blurSigma: 15,
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          _isListening
                              ? _partialText.isEmpty
                                  ? t(context, 'voice.result.listening')
                                  : _partialText
                              : _recognizedText.isEmpty
                                  ? t(context, 'voice.result.placeholder')
                                  : _recognizedText,
                          key: ValueKey(
                              '$_isListening$_partialText$_recognizedText'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(
                              alpha: (_recognizedText.isEmpty && !_isListening)
                                  ? 0.5
                                  : 0.9,
                            ),
                            fontStyle:
                                (_recognizedText.isEmpty && !_isListening)
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Copy button
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'common.copy'),
                        icon: Icons.copy,
                        onPressed:
                            _recognizedText.isNotEmpty ? _copyText : null,
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Use for translation button
                    Expanded(
                      flex: 2,
                      child: GlassButton(
                        text: t(context, 'voice.button.useText'),
                        icon: Icons.translate,
                        onPressed: _recognizedText.isNotEmpty
                            ? _useForTranslation
                            : null,
                        textColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Main action button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    text: _isListening
                        ? t(context, 'voice.button.stop')
                        : t(context, 'voice.button.start'),
                    icon: _isListening ? Icons.stop : Icons.mic,
                    onPressed: _toggleListening,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRipple(double animValue, double maxSize) {
    final size = maxSize * animValue;
    final opacity = (1.0 - animValue) * 0.4;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }
}
