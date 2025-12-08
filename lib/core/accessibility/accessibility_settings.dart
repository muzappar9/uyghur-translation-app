/// 辅助功能设置
///
/// 管理用户的辅助功能偏好
library;

import 'package:flutter/material.dart';

/// 字体大小设置
enum FontSizePreset {
  /// 小
  small(0.85, '小'),

  /// 正常
  normal(1.0, '正常'),

  /// 大
  large(1.15, '大'),

  /// 特大
  extraLarge(1.3, '特大'),

  /// 超大
  huge(1.5, '超大');

  final double scaleFactor;
  final String displayName;

  const FontSizePreset(this.scaleFactor, this.displayName);
}

/// 对比度设置
enum ContrastPreset {
  /// 正常
  normal(1.0, '正常'),

  /// 高对比度
  high(1.2, '高对比度'),

  /// 最高对比度
  highest(1.5, '最高对比度');

  final double factor;
  final String displayName;

  const ContrastPreset(this.factor, this.displayName);
}

/// 动画设置
enum AnimationPreset {
  /// 正常
  normal('正常'),

  /// 减弱
  reduced('减弱动画'),

  /// 关闭
  none('关闭动画');

  final String displayName;

  const AnimationPreset(this.displayName);
}

/// 辅助功能设置
class AccessibilitySettings {
  /// 字体大小
  final FontSizePreset fontSize;

  /// 粗体文字
  final bool boldText;

  /// 对比度
  final ContrastPreset contrast;

  /// 动画设置
  final AnimationPreset animation;

  /// 屏幕阅读器优化
  final bool screenReaderOptimized;

  /// 触摸目标大小放大
  final bool largerTouchTargets;

  /// 减少透明度
  final bool reduceTransparency;

  /// 高亮焦点
  final bool highlightFocus;

  /// 语音反馈
  final bool voiceFeedback;

  /// 触觉反馈
  final bool hapticFeedback;

  /// 颜色盲模式
  final ColorBlindMode colorBlindMode;

  const AccessibilitySettings({
    this.fontSize = FontSizePreset.normal,
    this.boldText = false,
    this.contrast = ContrastPreset.normal,
    this.animation = AnimationPreset.normal,
    this.screenReaderOptimized = false,
    this.largerTouchTargets = false,
    this.reduceTransparency = false,
    this.highlightFocus = false,
    this.voiceFeedback = false,
    this.hapticFeedback = true,
    this.colorBlindMode = ColorBlindMode.none,
  });

  /// 默认设置
  static const AccessibilitySettings defaults = AccessibilitySettings();

  /// 复制并修改
  AccessibilitySettings copyWith({
    FontSizePreset? fontSize,
    bool? boldText,
    ContrastPreset? contrast,
    AnimationPreset? animation,
    bool? screenReaderOptimized,
    bool? largerTouchTargets,
    bool? reduceTransparency,
    bool? highlightFocus,
    bool? voiceFeedback,
    bool? hapticFeedback,
    ColorBlindMode? colorBlindMode,
  }) {
    return AccessibilitySettings(
      fontSize: fontSize ?? this.fontSize,
      boldText: boldText ?? this.boldText,
      contrast: contrast ?? this.contrast,
      animation: animation ?? this.animation,
      screenReaderOptimized:
          screenReaderOptimized ?? this.screenReaderOptimized,
      largerTouchTargets: largerTouchTargets ?? this.largerTouchTargets,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      highlightFocus: highlightFocus ?? this.highlightFocus,
      voiceFeedback: voiceFeedback ?? this.voiceFeedback,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
    );
  }

  /// 获取动画时长倍数
  double get animationDurationFactor {
    switch (animation) {
      case AnimationPreset.normal:
        return 1.0;
      case AnimationPreset.reduced:
        return 0.5;
      case AnimationPreset.none:
        return 0.0;
    }
  }

  /// 是否禁用动画
  bool get disableAnimations => animation == AnimationPreset.none;

  /// 获取最小触摸目标尺寸
  double get minTouchTargetSize => largerTouchTargets ? 56.0 : 44.0;

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'fontSize': fontSize.index,
        'boldText': boldText,
        'contrast': contrast.index,
        'animation': animation.index,
        'screenReaderOptimized': screenReaderOptimized,
        'largerTouchTargets': largerTouchTargets,
        'reduceTransparency': reduceTransparency,
        'highlightFocus': highlightFocus,
        'voiceFeedback': voiceFeedback,
        'hapticFeedback': hapticFeedback,
        'colorBlindMode': colorBlindMode.index,
      };

  /// 从 JSON 反序列化
  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      fontSize: FontSizePreset.values[json['fontSize'] as int? ?? 1],
      boldText: json['boldText'] as bool? ?? false,
      contrast: ContrastPreset.values[json['contrast'] as int? ?? 0],
      animation: AnimationPreset.values[json['animation'] as int? ?? 0],
      screenReaderOptimized: json['screenReaderOptimized'] as bool? ?? false,
      largerTouchTargets: json['largerTouchTargets'] as bool? ?? false,
      reduceTransparency: json['reduceTransparency'] as bool? ?? false,
      highlightFocus: json['highlightFocus'] as bool? ?? false,
      voiceFeedback: json['voiceFeedback'] as bool? ?? false,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      colorBlindMode:
          ColorBlindMode.values[json['colorBlindMode'] as int? ?? 0],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessibilitySettings &&
        other.fontSize == fontSize &&
        other.boldText == boldText &&
        other.contrast == contrast &&
        other.animation == animation &&
        other.screenReaderOptimized == screenReaderOptimized &&
        other.largerTouchTargets == largerTouchTargets &&
        other.reduceTransparency == reduceTransparency &&
        other.highlightFocus == highlightFocus &&
        other.voiceFeedback == voiceFeedback &&
        other.hapticFeedback == hapticFeedback &&
        other.colorBlindMode == colorBlindMode;
  }

  @override
  int get hashCode => Object.hash(
        fontSize,
        boldText,
        contrast,
        animation,
        screenReaderOptimized,
        largerTouchTargets,
        reduceTransparency,
        highlightFocus,
        voiceFeedback,
        hapticFeedback,
        colorBlindMode,
      );
}

/// 颜色盲模式
enum ColorBlindMode {
  /// 无
  none('无'),

  /// 红色盲
  protanopia('红色盲'),

  /// 绿色盲
  deuteranopia('绿色盲'),

  /// 蓝色盲
  tritanopia('蓝色盲'),

  /// 单色视觉
  achromatopsia('单色视觉');

  final String displayName;

  const ColorBlindMode(this.displayName);
}

/// 计算辅助功能颜色
class AccessibilityColors {
  final AccessibilitySettings settings;

  const AccessibilityColors(this.settings);

  /// 获取调整后的颜色（考虑色盲模式）
  Color adjust(Color color) {
    switch (settings.colorBlindMode) {
      case ColorBlindMode.none:
        return color;
      case ColorBlindMode.protanopia:
        return _simulateProtanopia(color);
      case ColorBlindMode.deuteranopia:
        return _simulateDeuteranopia(color);
      case ColorBlindMode.tritanopia:
        return _simulateTritanopia(color);
      case ColorBlindMode.achromatopsia:
        return _simulateAchromatopsia(color);
    }
  }

  Color _simulateProtanopia(Color c) {
    // 红色盲色彩变换矩阵
    final r = c.r;
    final g = c.g;
    final b = c.b;

    final newR = 0.567 * r + 0.433 * g;
    final newG = 0.558 * r + 0.442 * g;
    final newB = 0.242 * g + 0.758 * b;

    return Color.from(
      alpha: c.a,
      red: newR.clamp(0, 1),
      green: newG.clamp(0, 1),
      blue: newB.clamp(0, 1),
    );
  }

  Color _simulateDeuteranopia(Color c) {
    final r = c.r;
    final g = c.g;
    final b = c.b;

    final newR = 0.625 * r + 0.375 * g;
    final newG = 0.7 * r + 0.3 * g;
    final newB = 0.3 * g + 0.7 * b;

    return Color.from(
      alpha: c.a,
      red: newR.clamp(0, 1),
      green: newG.clamp(0, 1),
      blue: newB.clamp(0, 1),
    );
  }

  Color _simulateTritanopia(Color c) {
    final r = c.r;
    final g = c.g;
    final b = c.b;

    final newR = 0.95 * r + 0.05 * g;
    final newG = 0.433 * g + 0.567 * b;
    final newB = 0.475 * g + 0.525 * b;

    return Color.from(
      alpha: c.a,
      red: newR.clamp(0, 1),
      green: newG.clamp(0, 1),
      blue: newB.clamp(0, 1),
    );
  }

  Color _simulateAchromatopsia(Color c) {
    // 转为灰度
    final gray = c.r * 0.299 + c.g * 0.587 + c.b * 0.114;
    return Color.from(alpha: c.a, red: gray, green: gray, blue: gray);
  }

  /// 确保颜色对比度满足 WCAG 要求
  Color ensureContrast(Color foreground, Color background,
      {double minRatio = 4.5}) {
    var adjustedForeground = foreground;
    var ratio = _calculateContrastRatio(adjustedForeground, background);

    if (ratio >= minRatio) return adjustedForeground;

    // 尝试加深或变浅前景色以达到对比度要求
    final foregroundLuminance = _relativeLuminance(adjustedForeground);
    final backgroundLuminance = _relativeLuminance(background);

    if (foregroundLuminance > backgroundLuminance) {
      // 前景较亮，尝试更亮
      adjustedForeground = _lighten(foreground, 0.3);
    } else {
      // 前景较暗，尝试更暗
      adjustedForeground = _darken(foreground, 0.3);
    }

    return adjustedForeground;
  }

  double _calculateContrastRatio(Color c1, Color c2) {
    final l1 = _relativeLuminance(c1);
    final l2 = _relativeLuminance(c2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  double _relativeLuminance(Color c) {
    double transform(double value) {
      return value <= 0.03928
          ? value / 12.92
          : ((value + 0.055) / 1.055).pow(2.4);
    }

    return 0.2126 * transform(c.r) +
        0.7152 * transform(c.g) +
        0.0722 * transform(c.b);
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

extension DoubleExt on double {
  double pow(double exponent) => this < 0
      ? 0
      : this == 0
          ? 0
          : this * this;
}
