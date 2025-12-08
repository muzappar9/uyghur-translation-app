import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../exceptions/app_exceptions.dart';

/// 网络请求拦截器，处理所有 Dio 异常
class NetworkErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapDioException(err);
    _logger.e(
      'Network Error: ${appException.message}',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.reject(err.copyWith(error: appException));
  }

  /// 将 Dio 异常映射到应用异常
  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('请求超时，请稍后重试');

      case DioExceptionType.badResponse:
        return ApiException(
          '服务器错误 (${error.response?.statusCode})',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return NetworkException('请求已取消');

      case DioExceptionType.badCertificate:
        return NetworkException('证书错误，无法建立安全连接');

      case DioExceptionType.connectionError:
        return NetworkException('网络连接失败，请检查网络设置');

      case DioExceptionType.unknown:
        return NetworkException(
          error.message ?? '网络请求失败',
        );
    }
  }
}

/// HTTP 响应拦截器，处理业务级错误
class HttpResponseInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查响应状态
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final error = ApiException(
        '服务器返回错误 (${response.statusCode})',
        statusCode: response.statusCode,
      );
      _logger.w('Bad HTTP Response: ${response.statusCode}');
      handler.reject(DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: error,
      ));
      return;
    }

    // 检查业务级响应结构
    if (response.data is Map) {
      final data = response.data as Map;
      final success = data['success'] ?? data['code'] == 0;

      if (!success) {
        final message = data['message'] ?? data['error'] ?? '操作失败';
        final error = ApiException(message, statusCode: response.statusCode);
        _logger.w('Business Error: $message');
        handler.reject(DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: error,
        ));
        return;
      }
    }

    handler.next(response);
  }
}

/// 请求日志拦截器
class RequestLoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '''
╔═══════════════════════════════════════════════════════════════
║ 📤 REQUEST: ${options.method.toUpperCase()} ${options.path}
├───────────────────────────────────────────────────────────────
║ Headers: ${options.headers}
║ Query Params: ${options.queryParameters}
║ Body: ${options.data}
╚═══════════════════════════════════════════════════════════════
''',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '''
╔═══════════════════════════════════════════════════════════════
║ 📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}
├───────────────────────────────────────────────────────────────
║ Data: ${response.data}
╚═══════════════════════════════════════════════════════════════
''',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '''
╔═══════════════════════════════════════════════════════════════
║ ❌ ERROR: ${err.type} ${err.requestOptions.path}
├───────────────────────────────────────────────────────────────
║ Message: ${err.message}
║ Status Code: ${err.response?.statusCode}
║ Response: ${err.response?.data}
╚═══════════════════════════════════════════════════════════════
''',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }
}
