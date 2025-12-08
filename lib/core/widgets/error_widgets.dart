import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/app_exceptions.dart';

/// 错误显示卡片
class ErrorCard extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final VoidCallback? onRetry;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? textColor;

  const ErrorCard({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.red.shade50;
    final txtColor = textColor ?? Colors.red.shade700;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: txtColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: txtColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: txtColor,
                          fontSize: 14,
                        ),
                      ),
                    if (title != null) const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(color: txtColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: txtColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 异步值错误显示
class AsyncErrorWidget<T> extends StatelessWidget {
  final AsyncValue<T> state;
  final Widget Function(T data) onData;
  final Widget Function(String error)? onError;
  final Widget Function()? onLoading;
  final VoidCallback? onRetry;

  const AsyncErrorWidget({
    super.key,
    required this.state,
    required this.onData,
    this.onError,
    this.onLoading,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      data: onData,
      loading:
          onLoading ?? () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        final message =
            error is AppException ? error.message : error.toString();
        return onError?.call(message) ??
            ErrorCard(
              message: message,
              onRetry: onRetry,
            );
      },
    );
  }
}

/// 异步值加载和错误处理包装
class AsyncStateBuilder<T> extends ConsumerWidget {
  final AsyncValue<T> Function(WidgetRef ref) builder;
  final Widget Function(T data) onData;
  final Widget Function(String error)? onError;
  final Widget Function()? onLoading;
  final VoidCallback? onRetry;

  const AsyncStateBuilder({
    super.key,
    required this.builder,
    required this.onData,
    this.onError,
    this.onLoading,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = builder(ref);
    return AsyncErrorWidget(
      state: state,
      onData: onData,
      onError: onError,
      onLoading: onLoading,
      onRetry: onRetry,
    );
  }
}

/// 空状态显示
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载状态覆盖层
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage = '加载中...',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (loadingMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 重试按钮
class RetryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const RetryButton({
    super.key,
    required this.onPressed,
    this.label = '重试',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: Text(label),
    );
  }
}
