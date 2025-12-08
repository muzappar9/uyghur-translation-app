import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// ============================================
/// Stage 20: 增强错误处理系统
/// ============================================

/// 错误类型枚举
enum ErrorType {
  network,
  timeout,
  server,
  validation,
  auth,
  notFound,
  permission,
  unknown,
}

/// 增强的应用错误类
class EnhancedAppError {
  final ErrorType type;
  final String message;
  final String? technicalDetails;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  EnhancedAppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.code,
    this.originalException,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  /// 从异常创建错误
  factory EnhancedAppError.fromException(dynamic e, [StackTrace? st]) {
    if (e is EnhancedAppError) return e;

    final errorString = e.toString().toLowerCase();

    // 网络错误
    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('unreachable')) {
      return EnhancedAppError(
        type: ErrorType.network,
        message: '网络连接失败，请检查您的网络设置',
        originalException: e,
        stackTrace: st,
      );
    }

    // 超时错误
    if (errorString.contains('timeout') || e is TimeoutException) {
      return EnhancedAppError(
        type: ErrorType.timeout,
        message: '请求超时，请稍后重试',
        originalException: e,
        stackTrace: st,
      );
    }

    // 认证错误
    if (errorString.contains('401') ||
        errorString.contains('unauthorized') ||
        errorString.contains('unauthenticated')) {
      return EnhancedAppError(
        type: ErrorType.auth,
        message: '身份验证失败，请重新登录',
        code: '401',
        originalException: e,
        stackTrace: st,
      );
    }

    // 权限错误
    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return EnhancedAppError(
        type: ErrorType.permission,
        message: '没有权限执行此操作',
        code: '403',
        originalException: e,
        stackTrace: st,
      );
    }

    // 404错误
    if (errorString.contains('404') || errorString.contains('not found')) {
      return EnhancedAppError(
        type: ErrorType.notFound,
        message: '请求的资源不存在',
        code: '404',
        originalException: e,
        stackTrace: st,
      );
    }

    // 服务器错误
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('server')) {
      return EnhancedAppError(
        type: ErrorType.server,
        message: '服务器繁忙，请稍后重试',
        originalException: e,
        stackTrace: st,
      );
    }

    // 验证错误
    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        e is FormatException) {
      return EnhancedAppError(
        type: ErrorType.validation,
        message: '输入数据格式不正确',
        originalException: e,
        stackTrace: st,
      );
    }

    // 未知错误
    return EnhancedAppError(
      type: ErrorType.unknown,
      message: '发生未知错误，请稍后重试',
      technicalDetails: e.toString(),
      originalException: e,
      stackTrace: st,
    );
  }

  /// 获取错误图标
  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.validation:
        return Icons.warning_amber;
      case ErrorType.auth:
        return Icons.lock_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  /// 是否可重试
  bool get isRetryable {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.server:
        return true;
      case ErrorType.validation:
      case ErrorType.auth:
      case ErrorType.notFound:
      case ErrorType.permission:
      case ErrorType.unknown:
        return false;
    }
  }

  @override
  String toString() => 'EnhancedAppError(type: $type, message: $message)';
}

/// 重试配置
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool Function(dynamic error)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.shouldRetry,
  });

  static const standard = RetryConfig();

  static const aggressive = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
  );

  static const conservative = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
  );
}

/// 带重试机制的操作执行器
class RetryExecutor {
  static final Logger _logger = Logger();

  /// 执行带重试的异步操作
  static Future<T> execute<T>({
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.standard,
    void Function(int attempt, Duration delay)? onRetry,
    void Function(dynamic error)? onError,
  }) async {
    int attempts = 0;
    Duration delay = config.initialDelay;

    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e, st) {
        _logger.w('Attempt $attempts failed: $e');

        // 检查是否应该重试
        final shouldRetry =
            config.shouldRetry?.call(e) ?? _defaultShouldRetry(e);

        if (!shouldRetry || attempts >= config.maxAttempts) {
          onError?.call(e);
          _logger.e('All $attempts attempts failed', stackTrace: st);
          rethrow;
        }

        // 通知重试
        onRetry?.call(attempts, delay);

        // 等待后重试
        await Future.delayed(delay);

        // 计算下一次延迟（指数退避）
        delay = Duration(
          milliseconds: (delay.inMilliseconds * config.backoffMultiplier)
              .toInt()
              .clamp(0, config.maxDelay.inMilliseconds),
        );
      }
    }
  }

  /// 默认的重试判断逻辑
  static bool _defaultShouldRetry(dynamic error) {
    final appError = EnhancedAppError.fromException(error);
    return appError.isRetryable;
  }
}

/// 错误状态
class ErrorState {
  final EnhancedAppError? error;
  final bool isError;

  const ErrorState({
    this.error,
    this.isError = false,
  });

  const ErrorState.none()
      : error = null,
        isError = false;

  ErrorState.fromError(EnhancedAppError this.error) : isError = true;

  ErrorState copyWith({
    EnhancedAppError? error,
    bool? isError,
  }) {
    return ErrorState(
      error: error ?? this.error,
      isError: isError ?? this.isError,
    );
  }
}

/// 全局错误状态Provider
final globalErrorProvider =
    StateNotifierProvider<GlobalErrorNotifier, ErrorState>(
  (ref) => GlobalErrorNotifier(),
);

/// 全局错误状态管理器
class GlobalErrorNotifier extends StateNotifier<ErrorState> {
  GlobalErrorNotifier() : super(const ErrorState.none());

  final Logger _logger = Logger();

  /// 设置错误
  void setError(dynamic error, [StackTrace? stackTrace]) {
    final appError = EnhancedAppError.fromException(error, stackTrace);
    _logger.e('Global error: ${appError.message}', stackTrace: stackTrace);
    state = ErrorState.fromError(appError);
  }

  /// 清除错误
  void clearError() {
    state = const ErrorState.none();
  }

  /// 处理错误并显示
  void handleAndShow(
    BuildContext context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    final appError = EnhancedAppError.fromException(error, stackTrace);
    setError(appError);
    _showErrorUI(context, appError);
  }

  /// 显示错误UI
  void _showErrorUI(BuildContext context, EnhancedAppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(error.icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(error.message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _getErrorColor(error.type),
        duration: const Duration(seconds: 4),
        action: error.isRetryable
            ? SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: () {
                  // 触发重试逻辑（需要外部处理）
                },
              )
            : null,
      ),
    );
  }

  /// 获取错误颜色
  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return Colors.orange.shade700;
      case ErrorType.server:
        return Colors.red.shade700;
      case ErrorType.validation:
        return Colors.amber.shade700;
      case ErrorType.auth:
      case ErrorType.permission:
        return Colors.deepOrange.shade700;
      case ErrorType.notFound:
        return Colors.grey.shade700;
      case ErrorType.unknown:
        return Colors.red.shade600;
    }
  }
}

/// 错误边界Widget（增强版）
class EnhancedErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(EnhancedAppError error, VoidCallback retry)?
      errorBuilder;
  final void Function(EnhancedAppError error)? onError;

  const EnhancedErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  ConsumerState<EnhancedErrorBoundary> createState() =>
      _EnhancedErrorBoundaryState();
}

class _EnhancedErrorBoundaryState extends ConsumerState<EnhancedErrorBoundary> {
  EnhancedAppError? _error;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    final error = EnhancedAppError.fromException(
      details.exception,
      details.stack,
    );
    setState(() {
      _error = error;
      _hasError = true;
    });
    widget.onError?.call(error);
  }

  void _retry() {
    setState(() {
      _error = null;
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      return widget.errorBuilder?.call(_error!, _retry) ??
          _DefaultErrorWidget(error: _error!, onRetry: _retry);
    }
    return widget.child;
  }
}

/// 默认错误显示Widget
class _DefaultErrorWidget extends StatelessWidget {
  final EnhancedAppError error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                error.icon,
                size: 48,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (error.technicalDetails != null) ...[
              const SizedBox(height: 8),
              Text(
                error.technicalDetails!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (error.isRetryable)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
          ],
        ),
      ),
    );
  }
}

/// 安全执行器
class SafeExecutor {
  static final Logger _logger = Logger();

  /// 安全执行异步操作
  static Future<T?> runAsync<T>({
    required Future<T> Function() operation,
    T? defaultValue,
    void Function(EnhancedAppError error)? onError,
    bool rethrowError = false,
  }) async {
    try {
      return await operation();
    } catch (e, st) {
      final error = EnhancedAppError.fromException(e, st);
      _logger.e('SafeExecutor error: ${error.message}', stackTrace: st);
      onError?.call(error);
      if (rethrowError) rethrow;
      return defaultValue;
    }
  }

  /// 安全执行同步操作
  static T? runSync<T>({
    required T Function() operation,
    T? defaultValue,
    void Function(EnhancedAppError error)? onError,
    bool rethrowError = false,
  }) {
    try {
      return operation();
    } catch (e, st) {
      final error = EnhancedAppError.fromException(e, st);
      _logger.e('SafeExecutor error: ${error.message}', stackTrace: st);
      onError?.call(error);
      if (rethrowError) rethrow;
      return defaultValue;
    }
  }

  /// 带重试的安全执行
  static Future<T?> runWithRetry<T>({
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.standard,
    T? defaultValue,
    void Function(EnhancedAppError error)? onError,
    void Function(int attempt, Duration delay)? onRetry,
  }) async {
    try {
      return await RetryExecutor.execute(
        operation: operation,
        config: config,
        onRetry: onRetry,
      );
    } catch (e, st) {
      final error = EnhancedAppError.fromException(e, st);
      _logger.e('SafeExecutor with retry failed: ${error.message}',
          stackTrace: st);
      onError?.call(error);
      return defaultValue;
    }
  }
}

/// AsyncValue 错误扩展
extension AsyncValueErrorExtension<T> on AsyncValue<T> {
  /// 获取错误信息
  EnhancedAppError? get appError {
    return whenOrNull(
      error: (error, st) => EnhancedAppError.fromException(error, st),
    );
  }

  /// 是否是可重试的错误
  bool get isRetryableError {
    return appError?.isRetryable ?? false;
  }
}
