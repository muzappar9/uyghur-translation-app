import 'package:flutter/material.dart';

/// 骨架屏加载器 - 用于模拟内容加载时的占位符
class SkeletonLoader extends StatefulWidget {
  final int lineCount;
  final double lineHeight;
  final double spacing;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const SkeletonLoader({
    super.key,
    this.lineCount = 3,
    this.lineHeight = 12,
    this.spacing = 8,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();

  /// 简单的文本骨架屏
  static Widget textLoader({
    int lines = 3,
    double spacing = 8,
  }) {
    return SkeletonLoader(
      lineCount: lines,
      spacing: spacing,
    );
  }

  /// 列表骨架屏
  static Widget listLoader({
    int itemCount = 5,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: padding,
        child: Column(
          children: List.generate(
            itemCount,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SkeletonLoader(
                lineCount: 2,
                spacing: 8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 卡片骨架屏
  static Widget cardLoader({
    double width = double.infinity,
    double height = 200,
  }) {
    return Card(
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        child: const SkeletonLoader(
          lineCount: 4,
          spacing: 12,
        ),
      ),
    );
  }
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey.shade300;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0, 1).toDouble()).toList(),
            ).createShader(bounds);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              widget.lineCount,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < widget.lineCount - 1 ? widget.spacing : 0,
                ),
                child: _buildSkeletonLine(
                  width: index == widget.lineCount - 1 ? 0.7 : 1.0,
                  height: widget.lineHeight,
                  baseColor: baseColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLine({
    required double width,
    required double height,
    required Color baseColor,
  }) {
    return Container(
      width: width == 1.0 ? double.infinity : null,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: width < 1.0 ? EdgeInsets.only(right: (1.0 - width) * 100) : null,
    );
  }
}
