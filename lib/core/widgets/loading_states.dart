import 'package:flutter/material.dart';
import '../animations/animations.dart';

/// ============================================
/// Stage 20: 增强加载状态组件库
/// ============================================

/// 通用加载状态枚举
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// 带状态的加载容器
class StatefulLoadingContainer extends StatelessWidget {
  final LoadingState state;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? successWidget;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Duration transitionDuration;

  const StatefulLoadingContainer({
    super.key,
    required this.state,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.successWidget,
    this.errorMessage,
    this.onRetry,
    this.transitionDuration = AppAnimationDuration.fast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: transitionDuration,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (state) {
      case LoadingState.idle:
        return child;
      case LoadingState.loading:
        return loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            );
      case LoadingState.success:
        return successWidget ?? child;
      case LoadingState.error:
        return errorWidget ??
            InlineErrorWidget(
              message: errorMessage ?? '加载失败',
              onRetry: onRetry,
            );
    }
  }
}

/// 内联错误组件（小型）
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final double iconSize;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 全屏错误页面
class FullScreenErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final IconData icon;

  const FullScreenErrorWidget({
    super.key,
    this.title = '出错了',
    required this.message,
    this.details,
    this.onRetry,
    this.onGoBack,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (details != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      details!,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onGoBack != null)
                      OutlinedButton.icon(
                        onPressed: onGoBack,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('返回'),
                      ),
                    if (onGoBack != null && onRetry != null)
                      const SizedBox(width: 16),
                    if (onRetry != null)
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 网络错误组件
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool isOffline;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return InlineErrorWidget(
      icon: isOffline ? Icons.wifi_off : Icons.cloud_off,
      message: isOffline ? '您当前处于离线状态' : '网络连接失败，请检查网络设置',
      onRetry: onRetry,
    );
  }
}

/// 空状态组件
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.iconSize = 64,
  });

  /// 搜索无结果
  factory EmptyStateWidget.noResults({
    String query = '',
    VoidCallback? onClear,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: '未找到结果',
      message: query.isNotEmpty ? '没有与"$query"匹配的结果' : null,
      action: onClear != null
          ? TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('清除搜索'),
            )
          : null,
    );
  }

  /// 历史记录为空
  factory EmptyStateWidget.noHistory({VoidCallback? onStartTranslation}) {
    return EmptyStateWidget(
      icon: Icons.history,
      title: '暂无翻译历史',
      message: '您的翻译记录将显示在这里',
      action: onStartTranslation != null
          ? FilledButton.icon(
              onPressed: onStartTranslation,
              icon: const Icon(Icons.translate),
              label: const Text('开始翻译'),
            )
          : null,
    );
  }

  /// 收藏为空
  factory EmptyStateWidget.noFavorites({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: '暂无收藏',
      message: '收藏的翻译将显示在这里',
      action: onBrowse != null
          ? TextButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.explore),
              label: const Text('浏览词典'),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 带动画的加载指示器
class AnimatedLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AnimatedLoadingIndicator({
    super.key,
    this.message,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 翻译加载状态（带打字动画）
class TranslationLoadingWidget extends StatelessWidget {
  final String? sourceText;
  final String? sourceLanguage;
  final String? targetLanguage;

  const TranslationLoadingWidget({
    super.key,
    this.sourceText,
    this.sourceLanguage,
    this.targetLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sourceText != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sourceLanguage != null)
                  Text(
                    sourceLanguage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  sourceText!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (targetLanguage != null)
                Text(
                  targetLanguage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const TypingIndicator(),
                  const SizedBox(width: 8),
                  Text(
                    '翻译中...',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 进度加载器（带百分比）
class ProgressLoadingWidget extends StatelessWidget {
  final double progress;
  final String? message;
  final Color? color;

  const ProgressLoadingWidget({
    super.key,
    required this.progress,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;
    final percent = (progress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

/// 带超时的加载组件
class TimeoutLoadingWidget extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  final Widget Function()? onTimeout;
  final VoidCallback? onRetry;

  const TimeoutLoadingWidget({
    super.key,
    required this.child,
    this.timeout = const Duration(seconds: 30),
    this.onTimeout,
    this.onRetry,
  });

  @override
  State<TimeoutLoadingWidget> createState() => _TimeoutLoadingWidgetState();
}

class _TimeoutLoadingWidgetState extends State<TimeoutLoadingWidget> {
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _startTimeout();
  }

  void _startTimeout() {
    Future.delayed(widget.timeout, () {
      if (mounted) {
        setState(() => _timedOut = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_timedOut) {
      return widget.onTimeout?.call() ??
          InlineErrorWidget(
            icon: Icons.timer_off,
            message: '加载超时，请重试',
            onRetry: () {
              setState(() => _timedOut = false);
              _startTimeout();
              widget.onRetry?.call();
            },
          );
    }
    return widget.child;
  }
}
