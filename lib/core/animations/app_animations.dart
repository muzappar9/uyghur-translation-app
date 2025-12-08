/// 应用动画配置
///
/// 提供统一的动画时长、曲线和转场效果配置
library;

import 'package:flutter/material.dart';

/// 动画时长配置
class AppAnimationDuration {
  AppAnimationDuration._();

  /// 极短动画 (100ms) - 用于微交互
  static const Duration fastest = Duration(milliseconds: 100);

  /// 快速动画 (200ms) - 用于按钮、图标变化
  static const Duration fast = Duration(milliseconds: 200);

  /// 标准动画 (300ms) - 用于页面转场、弹窗
  static const Duration normal = Duration(milliseconds: 300);

  /// 中等动画 (400ms) - 用于复杂转场
  static const Duration medium = Duration(milliseconds: 400);

  /// 慢速动画 (500ms) - 用于强调效果
  static const Duration slow = Duration(milliseconds: 500);

  /// 最慢动画 (700ms) - 用于特殊效果
  static const Duration slowest = Duration(milliseconds: 700);
}

/// 动画曲线配置
class AppAnimationCurve {
  AppAnimationCurve._();

  /// 标准曲线 - 用于大多数动画
  static const Curve standard = Curves.easeInOut;

  /// 减速曲线 - 用于进入动画
  static const Curve decelerate = Curves.decelerate;

  /// 加速曲线 - 用于退出动画
  static const Curve accelerate = Curves.easeIn;

  /// 弹性曲线 - 用于弹跳效果
  static const Curve bounce = Curves.bounceOut;

  /// 弹簧曲线 - 用于自然回弹
  static const Curve spring = Curves.elasticOut;

  /// 快速启动 - 用于快速响应
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// 平滑曲线 - 用于平滑过渡
  static const Curve smooth = Curves.easeOutCubic;

  /// 强调曲线 - 用于强调动画
  static const Curve emphasis = Curves.easeOutBack;
}

/// 页面转场动画类型
enum PageTransitionType {
  /// 淡入淡出
  fade,

  /// 从右滑入
  slideRight,

  /// 从左滑入
  slideLeft,

  /// 从下滑入
  slideUp,

  /// 从上滑入
  slideDown,

  /// 缩放
  scale,

  /// 旋转
  rotation,

  /// 淡入 + 缩放
  fadeScale,

  /// 淡入 + 从右滑入
  fadeSlideRight,

  /// 淡入 + 从下滑入
  fadeSlideUp,

  /// 淡入 + 滑动 (通用)
  fadeSlide,

  /// 缩放 + 旋转
  scaleRotate,

  /// Material 3 共享轴
  sharedAxis,

  /// 无动画
  none,
}

/// 页面转场动画构建器
class AppPageTransition {
  AppPageTransition._();

  /// 构建页面转场
  static Widget buildTransition({
    required Widget child,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    PageTransitionType type = PageTransitionType.fadeSlideRight,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return _buildFadeTransition(child, animation);
      case PageTransitionType.slideRight:
        return _buildSlideRightTransition(child, animation);
      case PageTransitionType.slideLeft:
        return _buildSlideLeftTransition(child, animation);
      case PageTransitionType.slideUp:
        return _buildSlideUpTransition(child, animation);
      case PageTransitionType.slideDown:
        return _buildSlideDownTransition(child, animation);
      case PageTransitionType.scale:
        return _buildScaleTransition(child, animation);
      case PageTransitionType.rotation:
        return _buildRotationTransition(child, animation);
      case PageTransitionType.fadeScale:
        return _buildFadeScaleTransition(child, animation);
      case PageTransitionType.fadeSlideRight:
        return _buildFadeSlideRightTransition(child, animation);
      case PageTransitionType.fadeSlideUp:
        return _buildFadeSlideUpTransition(child, animation);
      case PageTransitionType.fadeSlide:
        return _buildFadeSlideTransition(child, animation);
      case PageTransitionType.scaleRotate:
        return _buildScaleRotateTransition(child, animation);
      case PageTransitionType.sharedAxis:
        return _buildSharedAxisTransition(child, animation, secondaryAnimation);
      case PageTransitionType.none:
        return child;
    }
  }

  static Widget _buildFadeSlideTransition(
      Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimationCurve.fastOutSlowIn,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget _buildScaleRotateTransition(
      Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: AppAnimationCurve.fastOutSlowIn,
        ),
      ),
      child: RotationTransition(
        turns: Tween<double>(begin: 0.1, end: 0.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimationCurve.fastOutSlowIn,
          ),
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  static Widget _buildSharedAxisTransition(
      Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimationCurve.fastOutSlowIn,
        )),
        child: child,
      ),
    );
  }

  static Widget _buildFadeTransition(
      Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget _buildSlideRightTransition(
      Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimationCurve.fastOutSlowIn,
      )),
      child: child,
    );
  }

  static Widget _buildSlideLeftTransition(
      Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimationCurve.fastOutSlowIn,
      )),
      child: child,
    );
  }

  static Widget _buildSlideUpTransition(
      Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimationCurve.fastOutSlowIn,
      )),
      child: child,
    );
  }

  static Widget _buildSlideDownTransition(
      Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppAnimationCurve.fastOutSlowIn,
      )),
      child: child,
    );
  }

  static Widget _buildScaleTransition(
      Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: AppAnimationCurve.fastOutSlowIn,
        ),
      ),
      child: child,
    );
  }

  static Widget _buildRotationTransition(
      Widget child, Animation<double> animation) {
    return RotationTransition(
      turns: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: AppAnimationCurve.fastOutSlowIn,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  static Widget _buildFadeScaleTransition(
      Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: AppAnimationCurve.fastOutSlowIn,
          ),
        ),
        child: child,
      ),
    );
  }

  static Widget _buildFadeSlideRightTransition(
      Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimationCurve.fastOutSlowIn,
        )),
        child: child,
      ),
    );
  }

  static Widget _buildFadeSlideUpTransition(
      Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppAnimationCurve.fastOutSlowIn,
        )),
        child: child,
      ),
    );
  }
}

/// 自定义页面路由
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;

  AppPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.fadeSlideRight,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppAnimationDuration.normal,
          reverseTransitionDuration: AppAnimationDuration.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppPageTransition.buildTransition(
              child: child,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              type: transitionType,
            );
          },
        );
}

/// 动画 Widget 扩展
extension AnimatedWidgetExtension on Widget {
  /// 添加淡入动画
  Widget fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: this,
    );
  }

  /// 添加滑入动画
  Widget slideIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    Offset begin = const Offset(0.0, 0.1),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(offset: value * 100, child: child);
      },
      child: this,
    );
  }

  /// 添加缩放动画
  Widget scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    double begin = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: this,
    );
  }
}

/// 列表项动画 Widget
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + (delay * index),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// 脉冲动画 Widget
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 闪烁动画 Widget
class ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _controller.value * 2, 0.0),
              end: Alignment(1.0 + _controller.value * 2, 0.0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Convenience class for animation constants
/// Combines common duration and curve constants
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration fastest = AppAnimationDuration.fastest;
  static const Duration fast = AppAnimationDuration.fast;
  static const Duration normal = AppAnimationDuration.normal;
  static const Duration medium = AppAnimationDuration.medium;
  static const Duration slow = AppAnimationDuration.slow;
  static const Duration slowest = AppAnimationDuration.slowest;

  // Curves
  static const Curve standard = AppAnimationCurve.standard;
  static const Curve decelerate = AppAnimationCurve.decelerate;
  static const Curve accelerate = AppAnimationCurve.accelerate;
  static const Curve bounce = AppAnimationCurve.bounce;
  static const Curve spring = AppAnimationCurve.spring;
  static const Curve fastOutSlowIn = AppAnimationCurve.fastOutSlowIn;
  static const Curve smooth = AppAnimationCurve.smooth;
  static const Curve emphasis = AppAnimationCurve.emphasis;
}
