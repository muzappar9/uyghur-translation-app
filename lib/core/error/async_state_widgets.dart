import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'enhanced_error_handler.dart';
import '../widgets/loading_states.dart';

/// ============================================
/// Stage 20: 异步状态管理组件
/// ============================================

/// 增强的异步状态构建器
class EnhancedAsyncBuilder<T> extends ConsumerWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) dataBuilder;
  final Widget Function()? loadingBuilder;
  final Widget Function(EnhancedAppError error, VoidCallback retry)?
      errorBuilder;
  final VoidCallback? onRetry;
  final Widget Function(T? data)? skipLoadingBuilder;
  final bool skipLoadingOnRefresh;

  const EnhancedAsyncBuilder({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
    this.skipLoadingBuilder,
    this.skipLoadingOnRefresh = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncValue.when(
      data: (data) => dataBuilder(data),
      loading: () {
        // 如果正在刷新且有之前的数据，显示带数据的加载状态
        if (skipLoadingOnRefresh && asyncValue.hasValue) {
          return skipLoadingBuilder?.call(asyncValue.valueOrNull) ??
              dataBuilder(asyncValue.value as T);
        }
        return loadingBuilder?.call() ??
            const AnimatedLoadingIndicator(message: '加载中...');
      },
      error: (error, st) {
        final appError = EnhancedAppError.fromException(error, st);
        return errorBuilder?.call(appError, onRetry ?? () {}) ??
            InlineErrorWidget(
              icon: appError.icon,
              message: appError.message,
              onRetry: appError.isRetryable ? onRetry : null,
            );
      },
    );
  }
}

/// 带骨架屏的异步构建器
class SkeletonAsyncBuilder<T> extends ConsumerWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) dataBuilder;
  final Widget skeleton;
  final Widget Function(EnhancedAppError error, VoidCallback retry)?
      errorBuilder;
  final VoidCallback? onRetry;

  const SkeletonAsyncBuilder({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    required this.skeleton,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: asyncValue.when(
        data: (data) => dataBuilder(data),
        loading: () => skeleton,
        error: (error, st) {
          final appError = EnhancedAppError.fromException(error, st);
          return errorBuilder?.call(appError, onRetry ?? () {}) ??
              InlineErrorWidget(
                icon: appError.icon,
                message: appError.message,
                onRetry: appError.isRetryable ? onRetry : null,
              );
        },
      ),
    );
  }
}

/// 加载状态包装器
class LoadingStateWrapper extends StatelessWidget {
  final LoadingState state;
  final Widget child;
  final Widget? loading;
  final Widget Function(String message)? error;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showLoadingOverlay;

  const LoadingStateWrapper({
    super.key,
    required this.state,
    required this.child,
    this.loading,
    this.error,
    this.errorMessage,
    this.onRetry,
    this.showLoadingOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showLoadingOverlay && state == LoadingState.loading) {
      return Stack(
        children: [
          child,
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: loading ?? const AnimatedLoadingIndicator(),
            ),
          ),
        ],
      );
    }

    return StatefulLoadingContainer(
      state: state,
      loadingWidget: loading,
      errorWidget: errorMessage != null
          ? error?.call(errorMessage!) ??
              InlineErrorWidget(
                message: errorMessage!,
                onRetry: onRetry,
              )
          : null,
      onRetry: onRetry,
      child: child,
    );
  }
}

/// 可刷新的异步内容
class RefreshableAsyncContent<T> extends ConsumerWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) dataBuilder;
  final Widget Function()? loadingBuilder;
  final Widget Function(EnhancedAppError error)? errorBuilder;
  final Future<void> Function() onRefresh;
  final bool enableRefresh;

  const RefreshableAsyncContent({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    required this.onRefresh,
    this.loadingBuilder,
    this.errorBuilder,
    this.enableRefresh = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget content = asyncValue.when(
      data: dataBuilder,
      loading: () =>
          loadingBuilder?.call() ??
          const Center(child: CircularProgressIndicator()),
      error: (error, st) {
        final appError = EnhancedAppError.fromException(error, st);
        return errorBuilder?.call(appError) ??
            InlineErrorWidget(
              icon: appError.icon,
              message: appError.message,
              onRetry: onRefresh,
            );
      },
    );

    if (enableRefresh) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: content,
      );
    }

    return content;
  }
}

/// 分页加载状态
enum PaginationState {
  idle,
  loading,
  loadingMore,
  error,
  noMore,
}

/// 分页列表构建器
class PaginatedListBuilder<T> extends StatelessWidget {
  final List<T> items;
  final PaginationState state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? loadingMoreWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Widget? noMoreWidget;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry padding;
  final double? itemExtent;
  final ScrollController? scrollController;

  const PaginatedListBuilder({
    super.key,
    required this.items,
    required this.state,
    required this.itemBuilder,
    this.loadingWidget,
    this.loadingMoreWidget,
    this.errorWidget,
    this.emptyWidget,
    this.noMoreWidget,
    this.onLoadMore,
    this.onRetry,
    this.padding = const EdgeInsets.all(16),
    this.itemExtent,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // 初始加载状态
    if (state == PaginationState.loading && items.isEmpty) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    // 初始错误状态
    if (state == PaginationState.error && items.isEmpty) {
      return errorWidget ??
          InlineErrorWidget(
            message: '加载失败',
            onRetry: onRetry,
          );
    }

    // 空状态
    if (items.isEmpty) {
      return emptyWidget ?? const EmptyStateWidget(title: '暂无数据');
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            if (state == PaginationState.idle && onLoadMore != null) {
              onLoadMore!();
            }
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        padding: padding,
        itemExtent: itemExtent,
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index < items.length) {
            return itemBuilder(context, items[index], index);
          }

          // 底部状态指示器
          return _buildFooter();
        },
      ),
    );
  }

  Widget _buildFooter() {
    switch (state) {
      case PaginationState.loadingMore:
        return loadingMoreWidget ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
      case PaginationState.error:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ),
        );
      case PaginationState.noMore:
        return noMoreWidget ??
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '已加载全部',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// 操作结果反馈
class OperationFeedback {
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
        duration: duration,
      ),
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange.shade600,
        duration: duration,
      ),
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue.shade600,
        duration: duration,
      ),
    );
  }

  /// 显示带进度的操作
  static void showProgress(
    BuildContext context, {
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1), // 持续显示直到手动关闭
      ),
    );
  }

  /// 隐藏当前SnackBar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

/// 确认对话框
class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
