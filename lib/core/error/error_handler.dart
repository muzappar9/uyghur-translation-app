import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../exceptions/app_exceptions.dart';

/// 错误处理和显示管理器
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();

  final Logger _logger = Logger();

  ErrorHandler._internal();

  factory ErrorHandler() {
    return _instance;
  }

  /// 处理异常并返回用户友好的错误消息
  String handleException(dynamic exception, [StackTrace? stackTrace]) {
    if (exception is AppException) {
      _logError(exception, stackTrace);
      return exception.toString();
    } else if (exception is FlutterError) {
      _logError(exception, stackTrace);
      return '应用程序错误，请稍后重试';
    } else if (exception is FormatException) {
      _logError(exception, stackTrace);
      return '数据格式错误';
    } else if (exception is TimeoutException) {
      _logError(exception, stackTrace);
      return '请求超时，请检查网络连接';
    } else if (exception is Exception) {
      _logError(exception, stackTrace);
      return exception.toString();
    } else {
      _logError(exception, stackTrace);
      return '发生未知错误，请稍后重试';
    }
  }

  /// 记录错误
  void _logError(dynamic exception, [StackTrace? stackTrace]) {
    _logger.e(
      'Error: $exception',
      stackTrace: stackTrace,
    );
  }
}

/// 显示错误对话框
void showErrorDialog(
  BuildContext context,
  String message, {
  String title = '出错了',
  VoidCallback? onRetry,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('重试'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

/// 显示错误 SnackBar
void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade600,
      action: action,
    ),
  );
}

/// 显示成功 SnackBar
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green.shade600,
    ),
  );
}

/// 显示警告 SnackBar
void showWarningSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.orange.shade600,
    ),
  );
}

/// 显示信息 SnackBar
void showInfoSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.blue.shade600,
    ),
  );
}

/// 扩展 Error Handling
extension ErrorHandlingExt on Exception {
  /// 获取用户友好的错误消息
  String toUserMessage() {
    final handler = ErrorHandler();
    return handler.handleException(this);
  }
}
