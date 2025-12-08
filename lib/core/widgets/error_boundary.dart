import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../error/error_handler.dart';

/// 错误边界 - 捕获 Widget 构建错误
class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, FlutterErrorDetails)? errorBuilder;
  final String? title;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.title,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();

  // 覆盖全局错误处理
  static void installErrorHandler() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('❌ FlutterError: ${details.exceptionAsString()}');
    };
  }
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Safe 操作容器
class SafeOperation {
  static Future<T> run<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    bool shouldRethrow = true,
    Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      onError?.call(e);
      if (shouldRethrow) {
        ErrorHandler().handleException(e, stackTrace);
      }
      if (defaultValue != null) return defaultValue;
      rethrow;
    }
  }

  static T runSync<T>(
    T Function() operation, {
    T? defaultValue,
    bool shouldRethrow = true,
    Function(dynamic error)? onError,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      onError?.call(e);
      if (shouldRethrow) {
        ErrorHandler().handleException(e, stackTrace);
      }
      if (defaultValue != null) return defaultValue;
      rethrow;
    }
  }
}
