import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// GlassButton: iOS 17/18 Glass风格按钮
/// 升级: Stage 19 添加按压动画反馈
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Light/Dark | Size (Small/Medium/Large) | State (Default/Pressed/Disabled)
/// - Import to Figma: Use Auto Layout (H:Center, V:Center, padding 16x12),
///   add Background Blur (sigma 15), fill LinearGradient(Coral→White, 0.8),
///   corner radius 16px, include icon + text frame
class GlassButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double blurSigma;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final bool iconOnly;
  final bool useCoralGradient;
  final bool enableHaptic;

  const GlassButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.blurSigma = 15.0,
    this.borderRadius = 16.0,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.iconOnly = false,
    this.useCoralGradient = false,
    this.enableHaptic = true,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
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
    if (widget.isLoading || widget.onPressed == null) return;
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
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
    final defaultBgColor = isDark
        ? const Color(0x66000000)
        : const Color(0xCCFFFFFF);
    final defaultTextColor = isDark ? Colors.white : Colors.black87;

    final coralGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFF7F50).withValues(alpha: 0.8),
        Colors.white.withValues(alpha: 0.6),
      ],
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blurSigma,
                    sigmaY: widget.blurSigma,
                  ),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: widget.useCoralGradient ? coralGradient : null,
                      color: widget.useCoralGradient ? null : (widget.backgroundColor ?? defaultBgColor),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7F50).withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: widget.textColor ?? defaultTextColor,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: widget.textColor ?? defaultTextColor,
                                  size: 20,
                                ),
                                if (!widget.iconOnly) const SizedBox(width: 8),
                              ],
                              if (!widget.iconOnly)
                                Text(
                                  widget.text,
                                  style: TextStyle(
                                    color: widget.textColor ?? defaultTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Coral风格Glass按钮变体
class CoralGlassButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const CoralGlassButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      padding: padding,
      isLoading: isLoading,
      useCoralGradient: true,
      textColor: Colors.white,
    );
  }
}
