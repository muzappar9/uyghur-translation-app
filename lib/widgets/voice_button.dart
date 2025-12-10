import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// VoiceButton: 语音输入按钮组件
/// 支持录音状态动画、波纹效果和触觉反馈
class VoiceButton extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final bool isListening;
  final bool isProcessing;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showRipple;
  final bool enableHaptic;

  const VoiceButton({
    super.key,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.isListening = false,
    this.isProcessing = false,
    this.size = 64,
    this.activeColor,
    this.inactiveColor,
    this.showRipple = true,
    this.enableHaptic = true,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 合并动画控制器，减少Ticker数量
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    // 优化：减少不必要的动画控制器，只在需要时创建
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rippleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // 优化：使用更简单的动画，避免过度动画
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startListeningAnimations();
      } else {
        _stopListeningAnimations();
      }
    }
  }

  void _startListeningAnimations() {
    _pulseController.repeat(reverse: true);
    if (widget.showRipple) {
      _rippleController.repeat();
    }
  }

  void _stopListeningAnimations() {
    _pulseController.stop();
    _pulseController.reset();
    _rippleController.stop();
    _rippleController.reset();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (widget.enableHaptic) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPressStart?.call();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    widget.onLongPressEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? const Color(0xFFFF6B6B);
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPressStart:
          widget.onLongPressStart != null ? _onLongPressStart : null,
      onLongPressEnd: widget.onLongPressEnd != null ? _onLongPressEnd : null,
      child: SizedBox(
        width: widget.size * 2,
        height: widget.size * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 波纹效果
            if (widget.isListening && widget.showRipple)
              AnimatedBuilder(
                animation: _rippleController,
                builder: (context, child) {
                  return Container(
                    width: widget.size * _rippleAnimation.value,
                    height: widget.size * _rippleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: activeColor.withValues(
                          alpha: 1.0 - _rippleController.value,
                        ),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

            // 主按钮
            AnimatedBuilder(
              animation: Listenable.merge([_scaleController, _pulseController]),
              builder: (context, child) {
                final scale = _scaleAnimation.value *
                    (widget.isListening ? _pulseAnimation.value : 1.0);
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isListening
                        ? [activeColor, activeColor.withValues(alpha: 0.8)]
                        : [inactiveColor, inactiveColor.withValues(alpha: 0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isListening ? activeColor : inactiveColor)
                          .withValues(alpha: 0.4),
                      blurRadius: widget.isListening ? 20 : 10,
                      spreadRadius: widget.isListening ? 5 : 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(
                      child: widget.isProcessing
                          ? SizedBox(
                              width: widget.size * 0.4,
                              height: widget.size * 0.4,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            )
                          : Icon(
                              widget.isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: widget.size * 0.5,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// VoiceWaveform: 语音波形动画组件
class VoiceWaveform extends StatefulWidget {
  final bool isActive;
  final int barCount;
  final double height;
  final double barWidth;
  final Color? color;
  final Duration animationDuration;

  const VoiceWaveform({
    super.key,
    this.isActive = false,
    this.barCount = 5,
    this.height = 40,
    this.barWidth = 4,
    this.color,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<VoiceWaveform>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.animationDuration.inMilliseconds + (index * 100),
        ),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(VoiceWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted && widget.isActive) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.animateTo(0.3, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: widget.barWidth / 2),
                width: widget.barWidth,
                height: widget.height * _animations[index].value,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.barWidth / 2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// SpeakButton: 朗读按钮组件
class SpeakButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isSpeaking;
  final double size;
  final Color? color;

  const SpeakButton({
    super.key,
    this.onTap,
    this.isSpeaking = false,
    this.size = 40,
    this.color,
  });

  @override
  State<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<SpeakButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SpeakButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking != oldWidget.isSpeaking) {
      if (widget.isSpeaking) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSpeaking ? _animation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.isSpeaking
                    ? color.withValues(alpha: 0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                color: color,
                size: widget.size * 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}
