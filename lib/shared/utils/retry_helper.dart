import 'dart:async';
import 'dart:math';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../core/exceptions/app_exceptions.dart';

/// 重试策略助手
/// 提供自动重试和指数退避功能
class RetryHelper {
  /// 执行带重试的操作
  ///
  /// [operation]: 要执行的操作
  /// [maxAttempts]: 最大尝试次数 (默认 3)
  /// [delayMs]: 重试延迟时间，单位毫秒 (默认 1000ms)
  /// [exponentialBackoff]: 是否使用指数退避 (默认 true)
  /// [onRetry]: 重试时的回调函数
  /// [retryableException]: 异常过滤函数，只有满足条件的异常才会重试
  ///
  /// 返回操作的结果
  /// 如果所有重试都失败，会抛出最后一个异常
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    int delayMs = 1000,
    bool exponentialBackoff = true,
    Function(int attemptNumber, dynamic error)? onRetry,
    bool Function(dynamic exception)? retryableException,
  }) async {
    int attempts = 0;
    late dynamic lastException;

    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        lastException = e;
        attempts++;

        // 检查是否应该重试
        if (retryableException != null && !retryableException(e)) {
          rethrow;
        }

        // 如果是最后一次尝试，抛出异常
        if (attempts >= maxAttempts) {
          rethrow;
        }

        // 计算等待时间
        final waitTime = _calculateDelay(
          delayMs,
          attempts,
          exponentialBackoff,
        );

        // 调用回调函数
        onRetry?.call(attempts, e);

        // 等待后重试
        await Future.delayed(Duration(milliseconds: waitTime));
      }
    }

    throw lastException;
  }

  /// 计算延迟时间
  static int _calculateDelay(
    int baseDelayMs,
    int attemptNumber,
    bool exponentialBackoff,
  ) {
    if (!exponentialBackoff) {
      return baseDelayMs;
    }

    // 指数退避：baseDelay * (2 ^ (attempt - 1))
    // 添加随机抖动以避免雷群效应
    final exponent = attemptNumber - 1;
    final exponentialDelay = baseDelayMs * (pow(2, exponent).toInt());

    // 添加最多 10% 的随机抖动
    final jitter = (exponentialDelay * (Random().nextDouble() * 0.1)).toInt();

    return exponentialDelay + jitter;
  }

  /// 检查异常是否可重试
  static bool isRetryable(dynamic exception) {
    return exception is NetworkException ||
        exception is TimeoutException ||
        (exception is ApiException &&
            exception.statusCode != null &&
            (exception.statusCode! >= 500 || exception.statusCode == 429));
  }

  /// 使用条件重试
  ///
  /// [operation]: 要执行的操作
  /// [maxAttempts]: 最大尝试次数
  /// [delayMs]: 初始延迟时间
  ///
  /// 只重试网络相关异常和 5xx 错误
  static Future<T> retryOnNetworkError<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    int delayMs = 1000,
  }) {
    return retry<T>(
      operation,
      maxAttempts: maxAttempts,
      delayMs: delayMs,
      retryableException: isRetryable,
      onRetry: (attempt, error) {
        appLogger.w(
          '⚠️ Retry attempt $attempt: ${error.runtimeType} - ${error.toString()}',
        );
      },
    );
  }

  /// 检查响应状态码是否需要重试
  static bool shouldRetryStatusCode(int statusCode) {
    // 重试 5xx 错误（服务器错误）
    // 重试 429 错误（请求过多）
    // 重试 408 错误（请求超时）
    return statusCode >= 500 || statusCode == 429 || statusCode == 408;
  }
}

/// 重试配置
class RetryConfig {
  final int maxAttempts;
  final int initialDelayMs;
  final bool exponentialBackoff;
  final double jitterFraction;
  final int maxDelayMs;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelayMs = 1000,
    this.exponentialBackoff = true,
    this.jitterFraction = 0.1,
    this.maxDelayMs = 30000,
  });

  /// 开发配置（快速重试）
  factory RetryConfig.development() {
    return const RetryConfig(
      maxAttempts: 2,
      initialDelayMs: 500,
      exponentialBackoff: false,
    );
  }

  /// 生产配置（慢速重试）
  factory RetryConfig.production() {
    return const RetryConfig(
      maxAttempts: 5,
      initialDelayMs: 2000,
      exponentialBackoff: true,
      maxDelayMs: 60000,
    );
  }

  /// 关键操作配置（更多重试）
  factory RetryConfig.critical() {
    return const RetryConfig(
      maxAttempts: 8,
      initialDelayMs: 1000,
      exponentialBackoff: true,
      maxDelayMs: 120000,
    );
  }
}
