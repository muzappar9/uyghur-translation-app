import 'package:flutter/material.dart';

/// ============================================
/// Stage 20: 屏幕专用骨架屏加载器
/// ============================================

/// 翻译页面骨架屏
class TranslationSkeleton extends StatelessWidget {
  const TranslationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 语言选择器骨架
            _SkeletonBox(
              height: 56,
              borderRadius: 12,
              color: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 24),

            // 输入区域骨架
            _SkeletonBox(
              height: 160,
              borderRadius: 12,
              color: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 16),

            // 翻译按钮骨架
            Center(
              child: _SkeletonBox(
                width: 120,
                height: 48,
                borderRadius: 24,
                color: colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 24),

            // 结果区域骨架
            _SkeletonBox(
              height: 120,
              borderRadius: 12,
              color: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}

/// 翻译结果骨架屏
class TranslationResultSkeleton extends StatelessWidget {
  final bool showSourceText;

  const TranslationResultSkeleton({
    super.key,
    this.showSourceText = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSourceText) ...[
            // 原文区域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(
                    width: 60,
                    height: 12,
                    borderRadius: 6,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  _SkeletonBox(
                    width: double.infinity,
                    height: 20,
                    borderRadius: 4,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  _SkeletonBox(
                    width: 200,
                    height: 20,
                    borderRadius: 4,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 译文区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: 60,
                  height: 12,
                  borderRadius: 6,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                _SkeletonBox(
                  width: double.infinity,
                  height: 24,
                  borderRadius: 4,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                _SkeletonBox(
                  width: 180,
                  height: 24,
                  borderRadius: 4,
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 历史记录列表骨架屏
class HistoryListSkeleton extends StatelessWidget {
  final int itemCount;

  const HistoryListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const _HistoryItemSkeleton(),
      ),
    );
  }
}

class _HistoryItemSkeleton extends StatelessWidget {
  const _HistoryItemSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkeletonBox(
                width: 40,
                height: 16,
                borderRadius: 4,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              _SkeletonBox(
                width: 16,
                height: 16,
                borderRadius: 4,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              _SkeletonBox(
                width: 60,
                height: 16,
                borderRadius: 4,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              const Spacer(),
              _SkeletonBox(
                width: 80,
                height: 12,
                borderRadius: 4,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SkeletonBox(
            width: double.infinity,
            height: 18,
            borderRadius: 4,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          _SkeletonBox(
            width: 160,
            height: 16,
            borderRadius: 4,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

/// 词典搜索骨架屏
class DictionarySearchSkeleton extends StatelessWidget {
  const DictionarySearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索框骨架
            _SkeletonBox(
              height: 56,
              borderRadius: 28,
              color: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 24),

            // 搜索建议标题
            _SkeletonBox(
              width: 80,
              height: 14,
              borderRadius: 4,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),

            // 搜索建议列表
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _SkeletonBox(
                      width: 24,
                      height: 24,
                      borderRadius: 12,
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 12),
                    _SkeletonBox(
                      width: 100 + (index * 20).toDouble(),
                      height: 16,
                      borderRadius: 4,
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 词典详情骨架屏
class DictionaryDetailSkeleton extends StatelessWidget {
  const DictionaryDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 单词卡片
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(
                    width: 200,
                    height: 32,
                    borderRadius: 4,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  _SkeletonBox(
                    width: 120,
                    height: 16,
                    borderRadius: 4,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _SkeletonBox(
                        width: 36,
                        height: 36,
                        borderRadius: 18,
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 12),
                      _SkeletonBox(
                        width: 36,
                        height: 36,
                        borderRadius: 18,
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 释义部分
            _SkeletonBox(
              width: 60,
              height: 14,
              borderRadius: 4,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            _SkeletonBox(
              width: double.infinity,
              height: 18,
              borderRadius: 4,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            _SkeletonBox(
              width: 240,
              height: 18,
              borderRadius: 4,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),

            // 例句部分
            _SkeletonBox(
              width: 60,
              height: 14,
              borderRadius: 4,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      _SkeletonBox(
                        width: 180,
                        height: 14,
                        borderRadius: 4,
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ],
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

/// 设置页骨架屏
class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _SkeletonBox(
                    width: 60,
                    height: 60,
                    borderRadius: 30,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(
                          width: 120,
                          height: 18,
                          borderRadius: 4,
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        _SkeletonBox(
                          width: 80,
                          height: 14,
                          borderRadius: 4,
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 设置组
            ...List.generate(3, (groupIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(
                      width: 80,
                      height: 12,
                      borderRadius: 4,
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: List.generate(
                          3,
                          (itemIndex) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _SkeletonBox(
                                  width: 24,
                                  height: 24,
                                  borderRadius: 6,
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.3),
                                ),
                                const SizedBox(width: 12),
                                _SkeletonBox(
                                  width: 100,
                                  height: 16,
                                  borderRadius: 4,
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.3),
                                ),
                                const Spacer(),
                                _SkeletonBox(
                                  width: 16,
                                  height: 16,
                                  borderRadius: 4,
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 收藏列表骨架屏
class FavoritesListSkeleton extends StatelessWidget {
  final int itemCount;

  const FavoritesListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(
                      width: 120 + (index % 3 * 30).toDouble(),
                      height: 18,
                      borderRadius: 4,
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBox(
                      width: 180,
                      height: 14,
                      borderRadius: 4,
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
              _SkeletonBox(
                width: 32,
                height: 32,
                borderRadius: 16,
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 通用骨架框
class _SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color color;

  const _SkeletonBox({
    this.width,
    required this.height,
    this.borderRadius = 4,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 动画闪烁效果包装器
class AnimatedShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedShimmer> createState() => _AnimatedShimmerState();
}

class _AnimatedShimmerState extends State<AnimatedShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.transparent,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              transform: GradientRotation(_animation.value * 0.5),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
