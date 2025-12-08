import 'package:flutter/material.dart';
import 'app_animations.dart';

/// ============================================
/// Stage 19: 页面路由转场动画
/// ============================================

/// AppPageRoute: 自定义页面路由动画
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PageTransitionType transitionType;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;

  AppPageRoute({
    required this.page,
    this.transitionType = PageTransitionType.fadeSlide,
    this.duration = AppAnimationDuration.normal,
    this.reverseDuration = AppAnimationDuration.normal,
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              transitionType,
              curve,
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
        );

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    PageTransitionType type,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case PageTransitionType.fadeSlide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case PageTransitionType.scaleRotate:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: RotationTransition(
            turns: Tween<double>(begin: 0.1, end: 0.0).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        );

      case PageTransitionType.sharedAxis:
        // Material 3 Shared Axis transition
        return _SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );

      // Handle additional transition types from app_animations.dart
      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.5, end: 0.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case PageTransitionType.fadeScale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case PageTransitionType.fadeSlideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case PageTransitionType.fadeSlideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.2),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );

      case PageTransitionType.none:
        return child;
    }
  }
}

/// SharedAxisTransition: Material 3 共享轴转场
class _SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (context, animation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      reverseBuilder: (context, animation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.3, 0.0),
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInCubic,
            )),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// ModalPageRoute: 模态页面路由（从底部滑入）
class ModalPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool _barrierDismissible;
  final Color _barrierColor;

  ModalPageRoute({
    required this.page,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
    super.settings,
  })  : _barrierDismissible = barrierDismissible,
        _barrierColor = barrierColor,
        super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: AppAnimationDuration.normal,
          reverseTransitionDuration: AppAnimationDuration.fast,
          opaque: false,
        );

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color get barrierColor => _barrierColor;
}

/// HeroPageRoute: Hero动画页面路由
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  HeroPageRoute({
    required this.page,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
          transitionDuration: AppAnimationDuration.medium,
          reverseTransitionDuration: AppAnimationDuration.fast,
        );
}

/// 导航扩展方法
extension NavigatorExtensions on NavigatorState {
  /// 使用自定义转场动画推送页面
  Future<T?> pushWithTransition<T>(
    Widget page, {
    PageTransitionType type = PageTransitionType.fadeSlide,
    Duration? duration,
    RouteSettings? settings,
  }) {
    return push<T>(AppPageRoute<T>(
      page: page,
      transitionType: type,
      duration: duration ?? AppAnimationDuration.normal,
      settings: settings,
    ));
  }

  /// 模态方式推送页面
  Future<T?> pushModal<T>(
    Widget page, {
    bool barrierDismissible = true,
    RouteSettings? settings,
  }) {
    return push<T>(ModalPageRoute<T>(
      page: page,
      barrierDismissible: barrierDismissible,
      settings: settings,
    ));
  }

  /// Hero动画推送页面
  Future<T?> pushHero<T>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return push<T>(HeroPageRoute<T>(
      page: page,
      settings: settings,
    ));
  }

  /// 替换当前页面（带动画）
  Future<T?> replaceWithTransition<T, TO>(
    Widget page, {
    PageTransitionType type = PageTransitionType.fadeSlide,
    TO? result,
    RouteSettings? settings,
  }) {
    return pushReplacement<T, TO>(
      AppPageRoute<T>(
        page: page,
        transitionType: type,
        settings: settings,
      ),
      result: result,
    );
  }
}

/// BuildContext 导航扩展
extension NavigatorContextExtensions on BuildContext {
  /// 使用自定义转场动画推送页面
  Future<T?> pushWithTransition<T>(
    Widget page, {
    PageTransitionType type = PageTransitionType.fadeSlide,
    Duration? duration,
  }) {
    return Navigator.of(this).pushWithTransition<T>(
      page,
      type: type,
      duration: duration,
    );
  }

  /// 模态方式推送页面
  Future<T?> pushModal<T>(
    Widget page, {
    bool barrierDismissible = true,
  }) {
    return Navigator.of(this).pushModal<T>(
      page,
      barrierDismissible: barrierDismissible,
    );
  }

  /// 返回上一页
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  /// 返回到根页面
  void popToRoot() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}

/// AnimatedIndexedStack: 带动画的IndexedStack
class AnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const AnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppAnimationDuration.fast,
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0).then((_) {
        setState(() {
          _currentIndex = widget.index;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: IndexedStack(
        index: _currentIndex,
        children: widget.children,
      ),
    );
  }
}

/// CrossFadeIndexedStack: 交叉淡入淡出的IndexedStack
class CrossFadeIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const CrossFadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppAnimationDuration.fast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(index),
        child: children[index],
      ),
    );
  }
}
