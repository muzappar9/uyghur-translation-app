/// 语义包装器
///
/// 为 Widget 添加语义信息的包装器组件
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'accessibility_provider.dart';
import 'accessibility_settings.dart';

/// 可访问的按钮包装器
class AccessibleButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String label;
  final String? hint;
  final bool excludeChildSemantics;
  final double? minWidth;
  final double? minHeight;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.label,
    this.hint,
    this.excludeChildSemantics = false,
    this.minWidth,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);
    final minSize = settings.minTouchTargetSize;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: hint,
      excludeSemantics: excludeChildSemantics,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? minSize,
          minHeight: minHeight ?? minSize,
        ),
        child: child,
      ),
    );
  }
}

/// 可访问的文本字段包装器
class AccessibleTextField extends ConsumerWidget {
  final Widget child;
  final String label;
  final String? hint;
  final String? value;
  final bool isMultiline;
  final bool isObscured;

  const AccessibleTextField({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.value,
    this.isMultiline = false,
    this.isObscured = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      value: value,
      multiline: isMultiline,
      obscured: isObscured,
      child: child,
    );
  }
}

/// 可访问的图像包装器
class AccessibleImage extends StatelessWidget {
  final Widget child;
  final String description;
  final bool isDecorative;

  const AccessibleImage({
    super.key,
    required this.child,
    required this.description,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDecorative) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      image: true,
      label: description,
      child: child,
    );
  }
}

/// 可访问的开关包装器
class AccessibleSwitch extends ConsumerWidget {
  final Widget child;
  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AccessibleSwitch({
    super.key,
    required this.child,
    required this.label,
    required this.value,
    this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);
    final minSize = settings.minTouchTargetSize;

    return Semantics(
      toggled: value,
      label: label,
      hint: hint,
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: child,
      ),
    );
  }
}

/// 可访问的滑块包装器
class AccessibleSlider extends ConsumerWidget {
  final Widget child;
  final String label;
  final String? hint;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const AccessibleSlider({
    super.key,
    required this.child,
    required this.label,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      slider: true,
      label: label,
      hint: hint,
      value: '${(value * 100).round()}%',
      increasedValue: value < max
          ? '${((value + 0.1) * 100).round().clamp(0, 100)}%'
          : null,
      decreasedValue: value > min
          ? '${((value - 0.1) * 100).round().clamp(0, 100)}%'
          : null,
      onIncrease: onChanged != null && value < max
          ? () => onChanged!((value + 0.1).clamp(min, max))
          : null,
      onDecrease: onChanged != null && value > min
          ? () => onChanged!((value - 0.1).clamp(min, max))
          : null,
      child: child,
    );
  }
}

/// 可访问的列表项包装器
class AccessibleListItem extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final int? index;
  final int? total;
  final VoidCallback? onTap;

  const AccessibleListItem({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.index,
    this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final positionHint =
        index != null && total != null ? '第 ${index! + 1} 项，共 $total 项' : null;

    return Semantics(
      label: label,
      hint: [hint, positionHint].whereType<String>().join('. '),
      onTap: onTap,
      sortKey: index != null ? OrdinalSortKey(index!.toDouble()) : null,
      child: child,
    );
  }
}

/// 可访问的标题包装器
class AccessibleHeading extends StatelessWidget {
  final Widget child;
  final String label;
  final int level;

  const AccessibleHeading({
    super.key,
    required this.child,
    required this.label,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: label,
      sortKey: OrdinalSortKey(level.toDouble()),
      child: child,
    );
  }
}

/// 可访问的链接包装器
class AccessibleLink extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onTap;

  const AccessibleLink({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: label,
      hint: hint ?? '轻点两下打开链接',
      onTap: onTap,
      child: child,
    );
  }
}

/// 实时区域 - 用于动态更新的内容
class LiveRegion extends StatelessWidget {
  final Widget child;
  final String label;
  final bool polite; // true: 等待当前播报完成, false: 立即播报

  const LiveRegion({
    super.key,
    required this.child,
    required this.label,
    this.polite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: child,
    );
  }
}

/// 焦点高亮装饰器
class FocusHighlight extends ConsumerWidget {
  final Widget child;
  final bool hasFocus;
  final Color? focusColor;
  final double borderWidth;

  const FocusHighlight({
    super.key,
    required this.child,
    required this.hasFocus,
    this.focusColor,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);

    if (!settings.highlightFocus || !hasFocus) {
      return child;
    }

    final theme = Theme.of(context);
    final color = focusColor ?? theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

/// 辅助功能包装器 - 应用全局辅助功能设置
class AccessibilityWrapper extends ConsumerWidget {
  final Widget child;

  const AccessibilityWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(settings.fontSize.scaleFactor),
        boldText: settings.boldText,
        highContrast: settings.contrast != ContrastPreset.normal,
        disableAnimations: settings.disableAnimations,
      ),
      child: child,
    );
  }
}
