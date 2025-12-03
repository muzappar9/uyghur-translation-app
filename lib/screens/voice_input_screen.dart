import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../i18n/localizations.dart';

/// VoiceInputScreen: 语音输入页
/// 添加AnimatedBuilder麦克风波纹动画 (scale 1.0→1.5, duration 500ms)
class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _rippleController1;
  late AnimationController _rippleController2;
  late AnimationController _rippleController3;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isListening = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController1.dispose();
    _rippleController2.dispose();
    _rippleController3.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _scaleController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);

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
    _scaleController.stop();
    _scaleController.reset();
    _pulseController.stop();
    _pulseController.reset();
    _rippleController1.stop();
    _rippleController1.reset();
    _rippleController2.stop();
    _rippleController2.reset();
    _rippleController3.stop();
    _rippleController3.reset();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _startAnimations();
    } else {
      _stopAnimations();
    }
    // TODO: 实现语音识别
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
                  ],
                ),
              ),

              const Spacer(),

              // Status Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isListening
                      ? t(context, 'voice.status.listening')
                      : t(context, 'voice.status.ready'),
                  key: ValueKey(_isListening),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 40),

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
                    // 主麦克风按钮
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        final scale =
                            _isListening ? _scaleAnimation.value : 1.0;
                        return Transform.scale(
                          scale: scale * 0.7 + 0.3, // 限制缩放范围 0.3-1.05
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.25),
                                  boxShadow: _isListening
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              _pulseAnimation.value,
                                            ),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _toggleListening,
                                    borderRadius: BorderRadius.circular(60),
                                    child: Center(
                                      child: Icon(
                                        _isListening
                                            ? Icons.mic
                                            : Icons.mic_none,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                _isListening
                    ? t(context, 'voice.hint.speak')
                    : t(context, 'voice.hint.tap'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
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
                    child: Center(
                      child: Text(
                        t(context, 'voice.result.placeholder'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Stop Button
              Padding(
                padding: const EdgeInsets.all(24),
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
          color: Colors.white.withOpacity(opacity),
          width: 2,
        ),
      ),
    );
  }
}
