import 'dart:ui';
import 'package:flutter/material.dart';

/// GlassButton: iOS 17/18 Glass风格按钮
/// 升级: BackdropFilter(sigma:15) + Coral渐变支持
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Light/Dark | Size (Small/Medium/Large) | State (Default/Pressed/Disabled)
/// - Import to Figma: Use Auto Layout (H:Center, V:Center, padding 16x12),
///   add Background Blur (sigma 15), fill LinearGradient(Coral→White, 0.8),
///   corner radius 16px, include icon + text frame
class GlassButton extends StatelessWidget {
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
  final bool useCoralGradient; // 新增Coral渐变选项

  const GlassButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.blurSigma = 15.0, // 升级默认sigma从10到15
    this.borderRadius = 16.0,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.iconOnly = false,
    this.useCoralGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark
        ? const Color(0x66000000)
        : const Color(0xCCFFFFFF); // 80%透明度
    final defaultTextColor = isDark ? Colors.white : Colors.black87;

    final coralGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFF7F50).withOpacity(0.8),
        Colors.white.withOpacity(0.6),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: useCoralGradient ? coralGradient : null,
                color: useCoralGradient ? null : (backgroundColor ?? defaultBgColor),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.5),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7F50).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: textColor ?? defaultTextColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor ?? defaultTextColor, size: 20),
                          if (!iconOnly) const SizedBox(width: 8),
                        ],
                        if (!iconOnly)
                          Text(
                            text,
                            style: TextStyle(
                              color: textColor ?? defaultTextColor,
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
