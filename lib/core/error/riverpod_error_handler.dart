import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/app_exceptions.dart';
import 'error_handler.dart';

/// 异步操作状态检查工具
class AsyncValueUtils {
  /// 检查是否为错误状态
  static bool isError<T>(AsyncValue<T> state) {
    return state.maybeWhen(
      error: (_, __) => true,
      orElse: () => false,
    );
  }

  /// 检查是否为加载状态
  static bool isLoading<T>(AsyncValue<T> state) {
    return state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
  }

  /// 检查是否有数据
  static bool hasData<T>(AsyncValue<T> state) {
    return state.maybeWhen(
      data: (_) => true,
      orElse: () => false,
    );
  }

  /// 获取错误消息
  static String? getErrorMessage<T>(AsyncValue<T> state) {
    return state.maybeWhen(
      error: (error, _) {
        if (error is AppException) return error.toString();
        return error.toString();
      },
      orElse: () => null,
    );
  }

  /// 获取错误异常
  static dynamic getError<T>(AsyncValue<T> state) {
    return state.maybeWhen(
      error: (error, _) => error,
      orElse: () => null,
    );
  }
}

/// 扩展方法：AsyncValue
extension AsyncValueExt<T> on AsyncValue<T> {
  /// 是否为错误状态
  bool get isError => AsyncValueUtils.isError(this);

  /// 是否为加载状态
  bool get isLoading => AsyncValueUtils.isLoading(this);

  /// 是否有数据
  bool get hasData => AsyncValueUtils.hasData(this);

  /// 获取错误消息
  String? get errorMessage => AsyncValueUtils.getErrorMessage(this);

  /// 获取错误对象
  dynamic get error => AsyncValueUtils.getError(this);

  /// 转换为 Future
  Future<T> toFuture() async {
    return when(
      data: (data) => Future.value(data),
      error: (error, stackTrace) => Future.error(error, stackTrace),
      loading: () => Future.error(Exception('Still loading')),
    );
  }
}

/// Riverpod 提供者错误包装
class ProviderErrorHandler {
  /// 执行异步操作并处理错误
  static Future<T> handleAsync<T>(
    Future<T> Function() operation, {
    String? debugLabel,
  }) async {
    try {
      return await operation();
    } on AppException {
      rethrow;
    } on Exception catch (e, _) {
      final handler = ErrorHandler();
      final message = handler.handleException(e);
      throw NetworkException(message);
    } catch (e, _) {
      throw NetworkException('发生未知错误');
    }
  }
}

/// 重试机制
class RetryConfig {
  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟（毫秒）
  final int delayMs;

  /// 延迟倍数
  final double backoffMultiplier;

  /// 最大延迟（毫秒）
  final int maxDelayMs;

  const RetryConfig({
    this.maxRetries = 3,
    this.delayMs = 1000,
    this.backoffMultiplier = 2.0,
    this.maxDelayMs = 10000,
  });

  /// 获取第 n 次重试的延迟时间
  int getDelayForAttempt(int attemptNumber) {
    final delay = (delayMs * (backoffMultiplier * attemptNumber)).toInt();
    return delay > maxDelayMs ? maxDelayMs : delay;
  }
}

/// 带重试的异步操作
Future<T> retryAsync<T>(
  Future<T> Function() operation, {
  RetryConfig config = const RetryConfig(),
  bool Function(Exception error)? retryIf,
}) async {
  Exception? lastException;

  for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
    try {
      return await operation();
    } on Exception catch (e) {
      lastException = e;

      // 检查是否应该重试
      if (retryIf != null && !retryIf(e)) {
        rethrow;
      }

      if (attempt < config.maxRetries) {
        final delay = config.getDelayForAttempt(attempt);
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  throw lastException ?? NetworkException('操作失败，已达最大重试次数');
}
