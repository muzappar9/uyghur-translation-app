import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_animations.dart';

/// ============================================
/// Stage 19: 微交互动画组件
/// ============================================

/// 底部导航栏项目动画
class AnimatedBottomNavItem extends StatefulWidget {
  final IconData icon;
  final String? label;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedBottomNavItem({
    super.key,
    required this.icon,
    this.label,
    this.isActive = false,
    this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<AnimatedBottomNavItem> createState() => _AnimatedBottomNavItemState();
}

class _AnimatedBottomNavItemState extends State<AnimatedBottomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimationDuration.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Colors.white;
    final inactiveColor = widget.inactiveColor ?? Colors.white60;

    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppAnimationDuration.fast,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? activeColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isActive ? activeColor : inactiveColor,
                    size: 26,
                  ),
                ),
                if (widget.label != null) ...[
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: AppAnimationDuration.fast,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isActive ? activeColor : inactiveColor,
                      fontWeight:
                          widget.isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    child: Text(widget.label!),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 输入框聚焦动画容器
class AnimatedInputContainer extends StatefulWidget {
  final Widget child;
  final bool isFocused;
  final Color? focusColor;
  final double borderRadius;

  const AnimatedInputContainer({
    super.key,
    required this.child,
    this.isFocused = false,
    this.focusColor,
    this.borderRadius = 16.0,
  });

  @override
  State<AnimatedInputContainer> createState() => _AnimatedInputContainerState();
}

class _AnimatedInputContainerState extends State<AnimatedInputContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimationDuration.fast,
    );
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedInputContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocused != oldWidget.isFocused) {
      if (widget.isFocused) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: focusColor.withValues(
                alpha: widget.isFocused ? 0.5 : 0.1,
              ),
              width: _borderAnimation.value,
            ),
            boxShadow: widget.isFocused
                ? [
                    BoxShadow(
                      color: focusColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 卡片悬停/按压动画
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final double pressedElevation;
  final BorderRadius? borderRadius;
  final Color? shadowColor;
  final bool enableHaptic;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 4.0,
    this.pressedElevation = 8.0,
    this.borderRadius,
    this.shadowColor,
    this.enableHaptic = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.pressedElevation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final shadowColor = widget.shadowColor ?? Colors.black26;

    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: _elevationAnimation.value * 2,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 复制按钮动画（带确认反馈）
class AnimatedCopyButton extends StatefulWidget {
  final VoidCallback? onCopy;
  final Color? iconColor;
  final double size;

  const AnimatedCopyButton({
    super.key,
    this.onCopy,
    this.iconColor,
    this.size = 24,
  });

  @override
  State<AnimatedCopyButton> createState() => _AnimatedCopyButtonState();
}

class _AnimatedCopyButtonState extends State<AnimatedCopyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showCheck = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (_showCheck) return;

    HapticFeedback.mediumImpact();
    widget.onCopy?.call();

    setState(() => _showCheck = true);
    await _controller.forward();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      await _controller.reverse();
      setState(() => _showCheck = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          _showCheck ? Icons.check : Icons.copy,
          key: ValueKey(_showCheck),
          color: _showCheck ? Colors.green : color,
          size: widget.size,
        ),
      ),
    );
  }
}

/// 收藏按钮动画
class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;

  const AnimatedFavoriteButton({
    super.key,
    this.isFavorite = false,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.size = 24,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0.0);
    widget.onChanged?.call(!widget.isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Colors.red;
    final inactiveColor =
        widget.inactiveColor ?? Theme.of(context).colorScheme.outline;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? activeColor : inactiveColor,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

/// 开关动画（自定义样式）
class AnimatedToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double width;
  final double height;

  const AnimatedToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.width = 50,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? Theme.of(context).colorScheme.primary;
    final inactive = inactiveColor ?? Colors.grey.shade400;
    final thumbSize = height - 4;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged?.call(!value);
      },
      child: AnimatedContainer(
        duration: AppAnimationDuration.fast,
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: value ? active : inactive,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: AppAnimationDuration.fast,
              curve: Curves.easeInOut,
              left: value ? width - thumbSize - 2 : 2,
              top: 2,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
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

/// 模式切换动画指示器
class AnimatedSegmentIndicator extends StatelessWidget {
  final int selectedIndex;
  final int itemCount;
  final double itemWidth;
  final double height;
  final Color? color;
  final Duration duration;

  const AnimatedSegmentIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    required this.itemWidth,
    this.height = 36,
    this.color,
    this.duration = AppAnimationDuration.fast,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? Theme.of(context).colorScheme.primary;

    return AnimatedPositioned(
      duration: duration,
      curve: Curves.easeInOut,
      left: selectedIndex * itemWidth,
      child: Container(
        width: itemWidth,
        height: height,
        decoration: BoxDecoration(
          color: indicatorColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

/// 弹跳加载动画
class BounceLoadingIndicator extends StatefulWidget {
  final int dotCount;
  final double dotSize;
  final Color? color;
  final Duration duration;

  const BounceLoadingIndicator({
    super.key,
    this.dotCount = 3,
    this.dotSize = 10,
    this.color,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<BounceLoadingIndicator> createState() => _BounceLoadingIndicatorState();
}

class _BounceLoadingIndicatorState extends State<BounceLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.dotCount, (index) {
      return AnimationController(
        vsync: this,
        duration: widget.duration,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < widget.dotCount; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _controllers[i].repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// 文本淡入动画
class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    this.duration = AppAnimationDuration.normal,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.forward(from: 0.0);
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
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(widget.text, style: widget.style),
      ),
    );
  }
}
