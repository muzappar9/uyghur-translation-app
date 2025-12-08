/// 辅助功能辅助类
///
/// 提供辅助功能相关的辅助方法
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'accessibility_settings.dart';

/// 辅助功能辅助类
class AccessibilityHelpers {
  AccessibilityHelpers._();

  /// 获取调整后的字体大小
  static double scaledFontSize(
      double baseSize, AccessibilitySettings settings) {
    var scaled = baseSize * settings.fontSize.scaleFactor;
    if (settings.boldText) {
      scaled *= 1.05; // 粗体文字略微增大
    }
    return scaled;
  }

  /// 获取调整后的字体粗细
  static FontWeight scaledFontWeight(
    FontWeight baseWeight,
    AccessibilitySettings settings,
  ) {
    if (!settings.boldText) return baseWeight;

    switch (baseWeight) {
      case FontWeight.w100:
        return FontWeight.w300;
      case FontWeight.w200:
        return FontWeight.w400;
      case FontWeight.w300:
        return FontWeight.w500;
      case FontWeight.w400:
        return FontWeight.w600;
      case FontWeight.w500:
        return FontWeight.w700;
      case FontWeight.w600:
        return FontWeight.w800;
      case FontWeight.w700:
      case FontWeight.w800:
      case FontWeight.w900:
        return FontWeight.w900;
      default:
        return FontWeight.w600;
    }
  }

  /// 获取调整后的动画时长
  static Duration scaledDuration(
    Duration baseDuration,
    AccessibilitySettings settings,
  ) {
    if (settings.disableAnimations) return Duration.zero;
    final factor = settings.animationDurationFactor;
    return Duration(
      milliseconds: (baseDuration.inMilliseconds * factor).round(),
    );
  }

  /// 提供触觉反馈
  static Future<void> hapticFeedback(
    AccessibilitySettings settings, {
    HapticFeedbackType type = HapticFeedbackType.light,
  }) async {
    if (!settings.hapticFeedback) return;

    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        await HapticFeedback.vibrate();
        break;
    }
  }

  /// 播报文本
  static void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// 检查对比度是否满足 WCAG AA 标准
  static bool meetsContrastRatioAA(
    Color foreground,
    Color background, {
    bool largeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    return largeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// 检查对比度是否满足 WCAG AAA 标准
  static bool meetsContrastRatioAAA(
    Color foreground,
    Color background, {
    bool largeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    return largeText ? ratio >= 4.5 : ratio >= 7.0;
  }

  /// 计算对比度
  static double calculateContrastRatio(Color c1, Color c2) {
    final l1 = _relativeLuminance(c1);
    final l2 = _relativeLuminance(c2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color c) {
    double transform(int value) {
      final v = value / 255;
      return v <= 0.03928 ? v / 12.92 : _pow((v + 0.055) / 1.055, 2.4);
    }

    final r = ((c.r * 255).round() & 0xff);
    final g = ((c.g * 255).round() & 0xff);
    final b = ((c.b * 255).round() & 0xff);

    return 0.2126 * transform(r) +
        0.7152 * transform(g) +
        0.0722 * transform(b);
  }

  static double _pow(double base, double exp) {
    if (base <= 0) return 0;
    double result = 1;
    for (int i = 0; i < exp.toInt(); i++) {
      result *= base;
    }
    return result;
  }

  /// 创建符合辅助功能要求的按钮
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? hint,
    bool isButton = true,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      button: isButton,
      enabled: onPressed != null,
      label: semanticLabel,
      hint: hint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// 创建语义化容器
  static Widget semanticContainer({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? header,
    bool? image,
    bool? link,
    bool? liveRegion,
    bool container = false,
    int? sortKey,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      header: header,
      image: image,
      link: link,
      liveRegion: liveRegion,
      container: container,
      sortKey: sortKey != null ? OrdinalSortKey(sortKey.toDouble()) : null,
      child: child,
    );
  }

  /// 合并语义信息
  static Widget mergeSemantics({
    required Widget child,
    String? label,
  }) {
    return MergeSemantics(
      child: label != null ? Semantics(label: label, child: child) : child,
    );
  }

  /// 排除语义信息
  static Widget excludeSemantics({
    required Widget child,
    bool excluding = true,
  }) {
    return ExcludeSemantics(
      excluding: excluding,
      child: child,
    );
  }
}

/// 触觉反馈类型
enum HapticFeedbackType {
  /// 轻触
  light,

  /// 中等
  medium,

  /// 重
  heavy,

  /// 选择
  selection,

  /// 振动
  vibrate,
}

/// 辅助功能颜色扩展
extension AccessibilityColorExtension on Color {
  /// 获取合适的前景色（黑或白）
  Color get contrastingColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// 调整到满足对比度要求
  Color ensureContrastWith(Color background, {double minRatio = 4.5}) {
    var adjusted = this;
    var ratio =
        AccessibilityHelpers.calculateContrastRatio(adjusted, background);

    if (ratio >= minRatio) return adjusted;

    final bgLuminance = background.computeLuminance();

    // 迭代调整亮度
    for (int i = 0; i < 10 && ratio < minRatio; i++) {
      if (bgLuminance > 0.5) {
        // 背景较亮，前景变暗
        adjusted = _darken(adjusted, 0.1);
      } else {
        // 背景较暗，前景变亮
        adjusted = _lighten(adjusted, 0.1);
      }
      ratio = AccessibilityHelpers.calculateContrastRatio(adjusted, background);
    }

    return adjusted;
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

/// 辅助功能文本样式扩展
extension AccessibilityTextStyleExtension on TextStyle {
  /// 应用辅助功能设置
  TextStyle withAccessibility(AccessibilitySettings settings) {
    return copyWith(
      fontSize: fontSize != null
          ? AccessibilityHelpers.scaledFontSize(fontSize!, settings)
          : null,
      fontWeight: fontWeight != null
          ? AccessibilityHelpers.scaledFontWeight(fontWeight!, settings)
          : null,
    );
  }
}
