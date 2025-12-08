import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glass_card.dart';
import '../i18n/localizations.dart';
import '../core/animations/animations.dart';

/// LanguageSwitchBar: 源语言/交换/目标语言切换栏
/// 升级: Stage 19 添加动画支持
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Expanded/Compact | Active Source/Target
/// - Import to Figma: Use Auto Layout (H:Space Between), 
///   3 frames (source btn | swap icon | target btn),
///   RTL variant mirrors order automatically via direction prop
class LanguageSwitchBar extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback? onSourceTap;
  final VoidCallback? onTargetTap;
  final VoidCallback? onSwapTap;

  const LanguageSwitchBar({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.onSourceTap,
    this.onTargetTap,
    this.onSwapTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Source Language Button
          Expanded(
            child: _AnimatedLanguageButton(
              label: sourceLanguage.isEmpty ? t(context, 'home.lang.source') : sourceLanguage,
              onTap: onSourceTap,
              isActive: true,
            ),
          ),
          
          // Animated Swap Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedLanguageSwap(
              onSwap: onSwapTap,
              iconColor: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          
          // Target Language Button
          Expanded(
            child: _AnimatedLanguageButton(
              label: targetLanguage.isEmpty ? t(context, 'home.lang.target') : targetLanguage,
              onTap: onTargetTap,
              isActive: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedLanguageButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _AnimatedLanguageButton({
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  @override
  State<_AnimatedLanguageButton> createState() => _AnimatedLanguageButtonState();
}

class _AnimatedLanguageButtonState extends State<_AnimatedLanguageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppAnimationDuration.fast,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
