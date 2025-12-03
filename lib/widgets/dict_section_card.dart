import 'package:flutter/material.dart';
import 'glass_card.dart';

/// DictSectionCard: 词典详情分区卡片
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Light/Dark | Content Type (Basic/Sense/Examples/Related)
/// - Import to Figma: Use Auto Layout (V:Top, gap:12),
///   title text frame + content frame (list or text),
///   RTL variant auto-adjusts text alignment via direction prop
class DictSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const DictSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Section Content
          child,
        ],
      ),
    );
  }

  /// 创建带列表内容的分区卡片
  static Widget withList({
    required String title,
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return DictSectionCard(
      title: title,
      padding: padding,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 创建带文本内容的分区卡片
  static Widget withText({
    required String title,
    required String text,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DictSectionCard(
          title: title,
          padding: padding,
          margin: margin,
          child: Text(
            text.isEmpty ? 'TODO' : text,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.5,
            ),
          ),
        );
      },
    );
  }
}
