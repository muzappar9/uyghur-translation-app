import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../services/firebase_auth_service.dart';
import '../services/local_auth_service.dart';
import '../../domain/repositories/auth_repository.dart';

/// 认证初始化器
class AuthInitializer {
  static AuthRepository? _authRepository;

  /// 获取认证仓库实例
  static AuthRepository get instance {
    if (_authRepository == null) {
      throw Exception('AuthRepository 未初始化，请先调用 initialize()');
    }
    return _authRepository!;
  }

  /// 初始化认证系统
  static Future<AuthRepository> initialize({
    bool useLocalAuth = false,
  }) async {
    try {
      // 如果指定使用本地认证或 Firebase 初始化失败，则使用本地认证
      if (useLocalAuth) {
        return _initializeLocalAuth();
      }

      try {
        // 尝试初始化 Firebase
        await Firebase.initializeApp();
        _authRepository = FirebaseAuthService();
        appLogger.i('✅ Firebase 认证已初始化');
        return _authRepository!;
      } catch (e) {
        appLogger.w('⚠️ Firebase 初始化失败，降级到本地认证: $e');
        return _initializeLocalAuth();
      }
    } catch (e) {
      appLogger.e('❌ 认证初始化失败: $e');
      rethrow;
    }
  }

  /// 初始化本地认证
  static Future<AuthRepository> _initializeLocalAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authRepository = LocalAuthService(prefs: prefs);
      appLogger.i('✅ 本地认证已初始化');
      return _authRepository!;
    } catch (e) {
      appLogger.e('❌ 本地认证初始化失败: $e');
      rethrow;
    }
  }

  /// 检查是否已初始化
  static bool isInitialized() {
    return _authRepository != null;
  }

  /// 重置（用于测试）
  static void reset() {
    _authRepository = null;
  }

  /// 获取当前认证方式
  static String getAuthMethod() {
    if (_authRepository is FirebaseAuthService) {
      return 'Firebase';
    } else if (_authRepository is LocalAuthService) {
      return 'Local';
    }
    return 'Unknown';
  }
}
