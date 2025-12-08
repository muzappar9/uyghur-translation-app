import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/core/exceptions/app_exceptions.dart';

void main() {
  group('App Exceptions Tests', () {
    group('NetworkException', () {
      test('should create with correct message format', () {
        final exception = NetworkException('Connection failed');
        expect(exception.message, contains('Network Error'));
        expect(exception.message, contains('Connection failed'));
        expect(exception.toString(), contains('Network Error'));
      });
    });

    group('ApiException', () {
      test('should create with message only', () {
        final exception = ApiException('Request failed');
        expect(exception.message, contains('API Error'));
        expect(exception.message, contains('Request failed'));
        expect(exception.statusCode, isNull);
      });

      test('should create with status code', () {
        final exception = ApiException('Not found', statusCode: 404);
        expect(exception.message, contains('API Error'));
        expect(exception.message, contains('Not found'));
        expect(exception.message, contains('404'));
        expect(exception.statusCode, 404);
      });

      test('should create with original exception', () {
        final originalError = Exception('Original error');
        final exception = ApiException(
          'Request failed',
          statusCode: 500,
          originalException: originalError,
        );
        expect(exception.originalException, originalError);
      });
    });

    group('AuthException', () {
      test('should create with message', () {
        final exception = AuthException('Unauthorized');
        expect(exception.message, contains('Auth Error'));
        expect(exception.message, contains('Unauthorized'));
      });

      test('should create with code', () {
        final exception = AuthException('Token expired', code: 'TOKEN_EXPIRED');
        expect(exception.code, 'TOKEN_EXPIRED');
      });
    });

    group('DatabaseException', () {
      test('should create with correct format', () {
        final exception = DatabaseException('Connection lost');
        expect(exception.message, contains('Database Error'));
        expect(exception.message, contains('Connection lost'));
      });
    });

    group('FileSystemException', () {
      test('should create with correct format', () {
        final exception = FileSystemException('File not found');
        expect(exception.message, contains('File Error'));
        expect(exception.message, contains('File not found'));
      });
    });

    group('ValidationException', () {
      test('should create with field and message', () {
        final exception = ValidationException('email', 'Invalid format');
        expect(exception.message, contains('Validation Error'));
        expect(exception.message, contains('email'));
        expect(exception.message, contains('Invalid format'));
        expect(exception.field, 'email');
      });
    });

    group('ResourceNotFoundException', () {
      test('should create with resource name', () {
        final exception = ResourceNotFoundException('User');
        expect(exception.message, contains('Not Found'));
        expect(exception.message, contains('User'));
      });
    });

    group('TimeoutException', () {
      test('should create with correct format', () {
        final exception = TimeoutException('Request timed out');
        expect(exception.message, contains('Timeout'));
        expect(exception.message, contains('Request timed out'));
      });
    });

    group('CacheException', () {
      test('should create with correct format', () {
        final exception = CacheException('Cache expired');
        expect(exception.message, contains('Cache Error'));
        expect(exception.message, contains('Cache expired'));
      });
    });
  });
}
