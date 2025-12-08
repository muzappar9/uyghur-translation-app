import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../exceptions/app_exceptions.dart';
import 'error_handler.dart';

/// 应用级错误状态
class AppErrorState {
  /// 错误消息
  final String? message;

  /// 错误代码
  final String? code;

  /// 是否有错误
  final bool hasError;

  /// 原始异常
  final dynamic error;

  /// 时间戳
  final DateTime? timestamp;

  const AppErrorState({
    this.message,
    this.code,
    this.hasError = false,
    this.error,
    this.timestamp,
  });

  factory AppErrorState.empty() {
    return const AppErrorState();
  }

  factory AppErrorState.fromException(dynamic exception) {
    String message = '发生错误';

    if (exception is AppException) {
      message = exception.toString();
    } else if (exception is Exception) {
      message = exception.toString();
    }

    return AppErrorState(
      message: message,
      hasError: true,
      error: exception,
      timestamp: DateTime.now(),
    );
  }

  /// 清除错误
  AppErrorState clearError() {
    return AppErrorState.empty();
  }

  @override
  String toString() => 'AppErrorState(message: $message, code: $code)';
}

/// 全局错误状态管理器
class AppErrorNotifier extends StateNotifier<AppErrorState> {
  final Logger _logger = Logger();

  AppErrorNotifier() : super(AppErrorState.empty());

  /// 显示错误
  void showError(dynamic exception) {
    final errorState = AppErrorState.fromException(exception);
    _logger.e(
      'Error: ${errorState.message}',
      error: exception,
    );
    state = errorState;
  }

  /// 显示自定义错误消息
  void showCustomError(String message, {String? code}) {
    state = AppErrorState(
      message: message,
      code: code,
      hasError: true,
      timestamp: DateTime.now(),
    );
    _logger.w('Custom Error: $message${code != null ? ' ($code)' : ''}');
  }

  /// 清除错误
  void clearError() {
    state = AppErrorState.empty();
  }

  /// 处理异常
  void handleException(dynamic exception, [StackTrace? stackTrace]) {
    final handler = ErrorHandler();
    final message = handler.handleException(exception, stackTrace);
    showCustomError(message);
  }
}

/// 全局错误提供者
final appErrorProvider =
    StateNotifierProvider<AppErrorNotifier, AppErrorState>((ref) {
  return AppErrorNotifier();
});

/// 应用级错误监听
final errorListenerProvider = FutureProvider<void>((ref) async {
  ref.watch(appErrorProvider);
  // 可以在这里添加全局错误处理逻辑，如上报到服务器
});

/// 特定功能的错误状态
class FeatureErrorState {
  final String featureName;
  final String? errorMessage;
  final bool isLoading;
  final bool hasError;

  const FeatureErrorState({
    required this.featureName,
    this.errorMessage,
    this.isLoading = false,
    this.hasError = false,
  });

  factory FeatureErrorState.loading(String featureName) {
    return FeatureErrorState(
      featureName: featureName,
      isLoading: true,
    );
  }

  factory FeatureErrorState.error(String featureName, String message) {
    return FeatureErrorState(
      featureName: featureName,
      errorMessage: message,
      hasError: true,
    );
  }

  factory FeatureErrorState.success(String featureName) {
    return FeatureErrorState(featureName: featureName);
  }
}

/// 特定功能的错误管理
class FeatureErrorNotifier extends StateNotifier<FeatureErrorState> {
  final String featureName;

  FeatureErrorNotifier(this.featureName)
      : super(FeatureErrorState(featureName: featureName));

  void setLoading() {
    state = FeatureErrorState.loading(featureName);
  }

  void setError(String message) {
    state = FeatureErrorState.error(featureName, message);
  }

  void setSuccess() {
    state = FeatureErrorState.success(featureName);
  }

  void clear() {
    state = FeatureErrorState(featureName: featureName);
  }
}

/// 创建特定功能的错误提供者
StateNotifierProvider<FeatureErrorNotifier, FeatureErrorState>
    createFeatureErrorProvider(String featureName) {
  return StateNotifierProvider<FeatureErrorNotifier, FeatureErrorState>((ref) {
    return FeatureErrorNotifier(featureName);
  });
}

/// 翻译功能错误提供者
final translationErrorProvider = createFeatureErrorProvider('translation');

/// OCR 功能错误提供者
final ocrErrorProvider = createFeatureErrorProvider('ocr');

/// 认证功能错误提供者
final authErrorProvider = createFeatureErrorProvider('auth');

/// 同步功能错误提供者
final syncErrorProvider = createFeatureErrorProvider('sync');
