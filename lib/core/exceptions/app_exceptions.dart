/// 基础异常类
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// 网络异常
class NetworkException extends AppException {
  NetworkException(String message) : super('🌐 Network Error: $message');
}

/// API 异常
class ApiException extends AppException {
  final int? statusCode;
  final dynamic originalException;

  ApiException(
    String message, {
    this.statusCode,
    this.originalException,
  }) : super(
            '🔌 API Error: $message${statusCode != null ? ' (Status: $statusCode)' : ''}');
}

/// 认证异常
class AuthException extends AppException {
  final String? code;

  AuthException(String message, {this.code}) : super('🔐 Auth Error: $message');
}

/// 数据库异常
class DatabaseException extends AppException {
  DatabaseException(String message) : super('💾 Database Error: $message');
}

/// 文件系统异常
class FileSystemException extends AppException {
  FileSystemException(String message) : super('📁 File Error: $message');
}

/// 数据验证异常
class ValidationException extends AppException {
  final String field;

  ValidationException(this.field, String message)
      : super('❌ Validation Error ($field): $message');
}

/// 缺失资源异常
class ResourceNotFoundException extends AppException {
  ResourceNotFoundException(String resource) : super('❌ Not Found: $resource');
}

/// 超时异常
class TimeoutException extends AppException {
  TimeoutException(String message) : super('⏱️ Timeout: $message');
}

/// 缓存异常
class CacheException extends AppException {
  CacheException(String message) : super('💿 Cache Error: $message');
}
