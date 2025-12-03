import 'dart:ui';
import 'package:flutter/material.dart';

/// GlassCard: iOS 17/18 真实Glass效果组件
/// 升级: BackdropFilter(sigma:15) + LinearGradient(Coral→white, opacity 0.8)
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Light/Dark | Blur Level (10/15/20)
/// - Import to Figma: Use Auto Layout, add Background Blur effect (15px default),
///   set fill to LinearGradient (Coral #FF7F50 → White, 0.8 opacity),
///   corner radius 24px, add RTL variant via direction prop
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? border;
  final bool useGradient;
  final Gradient? customGradient;

  const GlassCard({
    super.key,
    required this.child,
    this.blurSigma = 15.0, // 升级默认sigma从10到15
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.border,
    this.useGradient = false,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final coralGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFF7F50).withOpacity(0.15), // Coral 15%
        Colors.white.withOpacity(isDark ? 0.05 : 0.3),
      ],
    );

    final defaultBgColor = isDark
        ? const Color(0x4D000000) // 30% black
        : const Color(0xCCFFFFFF); // 80% white (升级透明度)

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: useGradient ? (customGradient ?? coralGradient) : null,
              color: useGradient ? null : (backgroundColor ?? defaultBgColor),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.5),
                    width: 0.5,
                  ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7F50).withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// GlassCard变体：带Coral渐变
class CoralGlassCard extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CoralGlassCard({
    super.key,
    required this.child,
    this.blurSigma = 15.0,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurSigma: blurSigma,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      useGradient: true,
      customGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x33FF7F50), // Coral 20%
          Color(0x1AFFFFFF), // White 10%
        ],
      ),
      child: child,
    );
  }
}
