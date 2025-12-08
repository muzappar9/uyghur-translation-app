import 'package:flutter/material.dart';

/// 空状态类型枚举
enum EmptyStateType {
  /// 无翻译历史
  noHistory,

  /// 无收藏
  noFavorites,

  /// 无搜索结果
  noSearchResults,

  /// 无网络连接
  noConnection,

  /// 加载失败
  loadError,

  /// 通用空状态
  generic,
}

/// 空状态配置类
class EmptyStateConfig {
  /// 图标
  final IconData icon;

  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 操作按钮文字（可选）
  final String? actionText;

  /// 图标颜色（可选）
  final Color? iconColor;

  const EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.iconColor,
  });

  /// 根据类型获取预设配置
  factory EmptyStateConfig.fromType(
    EmptyStateType type, {
    String? customTitle,
    String? customDescription,
    String? customActionText,
  }) {
    switch (type) {
      case EmptyStateType.noHistory:
        return EmptyStateConfig(
          icon: Icons.history,
          title: customTitle ?? '暂无翻译历史',
          description: customDescription ?? '您的翻译历史将显示在这里',
          actionText: customActionText ?? '开始翻译',
        );
      case EmptyStateType.noFavorites:
        return EmptyStateConfig(
          icon: Icons.favorite_outline,
          title: customTitle ?? '暂无收藏',
          description: customDescription ?? '收藏的翻译将显示在这里',
          actionText: customActionText ?? '去翻译',
          iconColor: Colors.red.shade300,
        );
      case EmptyStateType.noSearchResults:
        return EmptyStateConfig(
          icon: Icons.search_off,
          title: customTitle ?? '无搜索结果',
          description: customDescription ?? '尝试使用其他关键词搜索',
        );
      case EmptyStateType.noConnection:
        return EmptyStateConfig(
          icon: Icons.wifi_off,
          title: customTitle ?? '无网络连接',
          description: customDescription ?? '请检查您的网络设置',
          actionText: customActionText ?? '重试',
          iconColor: Colors.orange,
        );
      case EmptyStateType.loadError:
        return EmptyStateConfig(
          icon: Icons.error_outline,
          title: customTitle ?? '加载失败',
          description: customDescription ?? '数据加载出错，请稍后重试',
          actionText: customActionText ?? '重新加载',
          iconColor: Colors.red,
        );
      case EmptyStateType.generic:
        return EmptyStateConfig(
          icon: Icons.inbox_outlined,
          title: customTitle ?? '暂无数据',
          description: customDescription ?? '这里还没有任何内容',
        );
    }
  }
}

/// 空状态组件
///
/// 用于显示列表为空、无数据、无搜索结果等情况
///
/// 示例用法：
/// ```dart
/// EmptyStateWidget(
///   type: EmptyStateType.noHistory,
///   onAction: () => Navigator.pushNamed(context, '/translate'),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  /// 空状态类型
  final EmptyStateType type;

  /// 自定义配置（优先级高于type）
  final EmptyStateConfig? config;

  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 图标大小
  final double iconSize;

  /// 是否紧凑模式
  final bool compact;

  /// 自定义内边距
  final EdgeInsetsGeometry? padding;

  /// 是否居中显示
  final bool center;

  const EmptyStateWidget({
    super.key,
    this.type = EmptyStateType.generic,
    this.config,
    this.onAction,
    this.iconSize = 80,
    this.compact = false,
    this.padding,
    this.center = true,
  });

  /// 无历史记录
  const EmptyStateWidget.noHistory({
    super.key,
    this.onAction,
    this.iconSize = 80,
    this.compact = false,
    this.padding,
    this.center = true,
  })  : type = EmptyStateType.noHistory,
        config = null;

  /// 无收藏
  const EmptyStateWidget.noFavorites({
    super.key,
    this.onAction,
    this.iconSize = 80,
    this.compact = false,
    this.padding,
    this.center = true,
  })  : type = EmptyStateType.noFavorites,
        config = null;

  /// 无搜索结果
  const EmptyStateWidget.noSearchResults({
    super.key,
    this.onAction,
    this.iconSize = 80,
    this.compact = false,
    this.padding,
    this.center = true,
  })  : type = EmptyStateType.noSearchResults,
        config = null;

  /// 无网络连接
  const EmptyStateWidget.noConnection({
    super.key,
    this.onAction,
    this.iconSize = 80,
    this.compact = false,
    this.padding,
    this.center = true,
  })  : type = EmptyStateType.noConnection,
        config = null;

  /// 加载失败
  const EmptyStateWidget.loadError({
    super.key,
    this.onAction,
    this.iconSize = 80,
    this.compact = false,
    this.padding,
    this.center = true,
  })  : type = EmptyStateType.loadError,
        config = null;

  /// 自定义空状态
  const EmptyStateWidget.custom({
    super.key,
    required this.config,
    this.onAction,
    this.iconSize = 80,
    this.compact = false,
    this.padding,
    this.center = true,
  }) : type = EmptyStateType.generic;

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? EmptyStateConfig.fromType(type);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Padding(
      padding: padding ??
          EdgeInsets.all(compact ? 16 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          _buildIcon(effectiveConfig, colorScheme),

          SizedBox(height: compact ? 12 : 24),

          // 标题
          Text(
            effectiveConfig.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: compact ? 4 : 8),

          // 描述
          Text(
            effectiveConfig.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          // 操作按钮
          if (effectiveConfig.actionText != null && onAction != null) ...[
            SizedBox(height: compact ? 16 : 24),
            _buildActionButton(effectiveConfig, colorScheme),
          ],
        ],
      ),
    );

    if (center) {
      return Center(child: content);
    }

    return content;
  }

  /// 构建图标
  Widget _buildIcon(EmptyStateConfig config, ColorScheme colorScheme) {
    return Container(
      width: iconSize + 32,
      height: iconSize + 32,
      decoration: BoxDecoration(
        color: (config.iconColor ?? colorScheme.primary).withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(
        config.icon,
        size: iconSize,
        color: (config.iconColor ?? colorScheme.primary).withAlpha(178),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton(
    EmptyStateConfig config,
    ColorScheme colorScheme,
  ) {
    return FilledButton.tonal(
      onPressed: onAction,
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 8 : 12,
        ),
      ),
      child: Text(config.actionText!),
    );
  }
}

/// 带动画的空状态组件
class AnimatedEmptyStateWidget extends StatefulWidget {
  /// 空状态类型
  final EmptyStateType type;

  /// 自定义配置
  final EmptyStateConfig? config;

  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 图标大小
  final double iconSize;

  /// 动画时长
  final Duration animationDuration;

  /// 自定义内边距
  final EdgeInsetsGeometry? padding;

  const AnimatedEmptyStateWidget({
    super.key,
    this.type = EmptyStateType.generic,
    this.config,
    this.onAction,
    this.iconSize = 80,
    this.animationDuration = const Duration(milliseconds: 600),
    this.padding,
  });

  @override
  State<AnimatedEmptyStateWidget> createState() =>
      _AnimatedEmptyStateWidgetState();
}

class _AnimatedEmptyStateWidgetState extends State<AnimatedEmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: EmptyStateWidget(
            type: widget.type,
            config: widget.config,
            onAction: widget.onAction,
            iconSize: widget.iconSize,
            padding: widget.padding,
          ),
        ),
      ),
    );
  }
}

/// 空状态包装器
///
/// 根据数据状态自动显示内容或空状态
///
/// 示例用法：
/// ```dart
/// EmptyStateWrapper<List<TranslationRecord>>(
///   data: records,
///   emptyType: EmptyStateType.noHistory,
///   builder: (data) => ListView.builder(...),
/// )
/// ```
class EmptyStateWrapper<T> extends StatelessWidget {
  /// 数据
  final T? data;

  /// 空状态类型
  final EmptyStateType emptyType;

  /// 自定义空状态配置
  final EmptyStateConfig? emptyConfig;

  /// 数据存在时的构建器
  final Widget Function(T data) builder;

  /// 判断数据是否为空的函数
  final bool Function(T? data)? isEmpty;

  /// 空状态操作回调
  final VoidCallback? onEmptyAction;

  /// 是否使用动画
  final bool animated;

  const EmptyStateWrapper({
    super.key,
    required this.data,
    required this.builder,
    this.emptyType = EmptyStateType.generic,
    this.emptyConfig,
    this.isEmpty,
    this.onEmptyAction,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final checkEmpty = isEmpty ?? _defaultIsEmpty;

    if (checkEmpty(data)) {
      if (animated) {
        return AnimatedEmptyStateWidget(
          type: emptyType,
          config: emptyConfig,
          onAction: onEmptyAction,
        );
      }
      return EmptyStateWidget(
        type: emptyType,
        config: emptyConfig,
        onAction: onEmptyAction,
      );
    }

    return builder(data as T);
  }

  /// 默认空判断逻辑
  bool _defaultIsEmpty(T? data) {
    if (data == null) return true;
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is Set) return data.isEmpty;
    if (data is Iterable) return data.isEmpty;
    if (data is String) return data.isEmpty;
    return false;
  }
}

/// 异步数据空状态包装器
///
/// 处理 AsyncValue 类型的数据，自动显示加载、错误、空状态
class AsyncEmptyStateWrapper<T> extends StatelessWidget {
  /// 异步数据
  final AsyncSnapshot<T> snapshot;

  /// 空状态类型
  final EmptyStateType emptyType;

  /// 数据存在时的构建器
  final Widget Function(T data) builder;

  /// 判断数据是否为空的函数
  final bool Function(T? data)? isEmpty;

  /// 加载中组件
  final Widget? loading;

  /// 错误操作回调
  final VoidCallback? onErrorRetry;

  /// 空状态操作回调
  final VoidCallback? onEmptyAction;

  const AsyncEmptyStateWrapper({
    super.key,
    required this.snapshot,
    required this.builder,
    this.emptyType = EmptyStateType.generic,
    this.isEmpty,
    this.loading,
    this.onErrorRetry,
    this.onEmptyAction,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return loading ?? const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return AnimatedEmptyStateWidget(
        type: EmptyStateType.loadError,
        onAction: onErrorRetry,
        config: EmptyStateConfig(
          icon: Icons.error_outline,
          title: '加载失败',
          description: snapshot.error.toString(),
          actionText: onErrorRetry != null ? '重试' : null,
          iconColor: Colors.red,
        ),
      );
    }

    final data = snapshot.data;
    final checkEmpty = isEmpty ?? _defaultIsEmpty;

    if (checkEmpty(data)) {
      return AnimatedEmptyStateWidget(
        type: emptyType,
        onAction: onEmptyAction,
      );
    }

    return builder(data as T);
  }

  bool _defaultIsEmpty(T? data) {
    if (data == null) return true;
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is Set) return data.isEmpty;
    if (data is Iterable) return data.isEmpty;
    if (data is String) return data.isEmpty;
    return false;
  }
}
