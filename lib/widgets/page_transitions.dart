// 页面过渡动画组件
// 提供多种优美的页面切换动画效果

import 'package:flutter/material.dart';

/// 过渡动画类型
enum TransitionType {
  /// 淡入淡出
  fade,

  /// 从右侧滑入
  slideRight,

  /// 从下方滑入
  slideUp,

  /// 从底部弹出
  slideBottom,

  /// 缩放
  scale,

  /// 旋转
  rotation,

  /// 淡入 + 缩放
  fadeScale,

  /// 滑入 + 淡入
  slideRightFade,

  /// 共享元素动画
  sharedAxis,

  /// 容器变换
  containerTransform,
}

/// 自定义页面路由，支持多种过渡动画
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Duration duration;
  final Curve curve;

  CustomPageRoute({
    required this.page,
    this.transitionType = TransitionType.slideRightFade,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              transitionType,
              animation,
              secondaryAnimation,
              child,
              curve,
            );
          },
        );
}

/// 构建过渡动画
Widget _buildTransition(
  TransitionType type,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  Curve curve,
) {
  final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

  switch (type) {
    case TransitionType.fade:
      return FadeTransition(
        opacity: curvedAnimation,
        child: child,
      );

    case TransitionType.slideRight:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      );

    case TransitionType.slideUp:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      );

    case TransitionType.slideBottom:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );

    case TransitionType.scale:
      return ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
        child: child,
      );

    case TransitionType.rotation:
      return RotationTransition(
        turns: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );

    case TransitionType.fadeScale:
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );

    case TransitionType.slideRightFade:
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );

    case TransitionType.sharedAxis:
      // 共享轴动画：缩放+淡出离开页面，淡入+缩放进入新页面
      return Stack(
        children: [
          // 离开动画
          SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.3, 0.0),
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: curve,
            )),
            child: FadeTransition(
              opacity:
                  Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
                parent: secondaryAnimation,
                curve: curve,
              )),
              child: child,
            ),
          ),
          // 进入动画
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        ],
      );

    case TransitionType.containerTransform:
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
          alignment: Alignment.center,
          child: child,
        ),
      );
  }
}

/// Hero 动画包装器
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final String heroTag;
  final Duration duration;
  final Curve curve;

  HeroPageRoute({
    required this.page,
    required this.heroTag,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
}

/// 页面过渡扩展
extension NavigatorExtensions on NavigatorState {
  /// 使用自定义动画推入页面
  Future<T?> pushWithTransition<T>(
    Widget page, {
    TransitionType type = TransitionType.slideRightFade,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
  }) {
    return push<T>(
      CustomPageRoute<T>(
        page: page,
        transitionType: type,
        duration: duration ?? const Duration(milliseconds: 350),
        curve: curve ?? Curves.easeOutCubic,
        settings: settings,
      ),
    );
  }

  /// 使用自定义动画替换页面
  Future<T?> pushReplacementWithTransition<T, TO>(
    Widget page, {
    TransitionType type = TransitionType.fadeScale,
    Duration? duration,
    Curve? curve,
    RouteSettings? settings,
    TO? result,
  }) {
    return pushReplacement<T, TO>(
      CustomPageRoute<T>(
        page: page,
        transitionType: type,
        duration: duration ?? const Duration(milliseconds: 350),
        curve: curve ?? Curves.easeOutCubic,
        settings: settings,
      ),
      result: result,
    );
  }
}

/// 页面过渡动画 Widget
class AnimatedPageTransition extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final double fadeStart;

  const AnimatedPageTransition({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = const Offset(0, 30),
    this.fadeStart = 0.0,
  });

  @override
  State<AnimatedPageTransition> createState() => _AnimatedPageTransitionState();
}

class _AnimatedPageTransitionState extends State<AnimatedPageTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: widget.fadeStart,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // 延迟后开始动画
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 交错动画列表
class StaggeredAnimationList extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration itemDuration;
  final Curve curve;
  final Axis direction;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList> {
  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
        ? Column(
            children: _buildAnimatedChildren(),
          )
        : Row(
            children: _buildAnimatedChildren(),
          );
  }

  List<Widget> _buildAnimatedChildren() {
    return widget.children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;

      return AnimatedPageTransition(
        delay: Duration(
          milliseconds: widget.itemDelay.inMilliseconds * index,
        ),
        duration: widget.itemDuration,
        curve: widget.curve,
        slideOffset: widget.direction == Axis.vertical
            ? const Offset(0, 20)
            : const Offset(20, 0),
        child: child,
      );
    }).toList();
  }
}

/// 页面入场动画包装器
class PageEntranceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const PageEntranceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<PageEntranceAnimation> createState() => _PageEntranceAnimationState();
}

class _PageEntranceAnimationState extends State<PageEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 底部弹出页面路由（用于模态页面）
class ModalBottomSheetRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Color _barrierColorValue;
  final bool isDismissible;

  ModalBottomSheetRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 350),
    Color barrierColor = Colors.black54,
    this.isDismissible = true,
    super.settings,
  })  : _barrierColorValue = barrierColor,
        super(
          opaque: false,
          barrierDismissible: isDismissible,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
        );

  @override
  Color? get barrierColor => _barrierColorValue;
}

/// 透明背景页面（用于对话框样式）
class TransparentPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  TransparentPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          opaque: false,
          barrierDismissible: true,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}

/// 脉冲动画（用于加载或强调效果）
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// 抖动动画（用于错误提示）
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final VoidCallback? onComplete;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 10.0,
    this.onComplete,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: widget.offset), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: widget.offset, end: -widget.offset), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: -widget.offset, end: widget.offset), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: widget.offset, end: -widget.offset), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -widget.offset, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 弹跳动画
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double height;

  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.height = 10.0,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: widget.height).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
