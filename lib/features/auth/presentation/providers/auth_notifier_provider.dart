import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../data/services/auth_initializer.dart';
import '../../domain/entities/auth_user.dart';
import '../../data/models/auth_models.dart';

/// 认证相关操作的状态
class AuthOperationState {
  /// 是否正在加载
  final bool isLoading;

  /// 错误消息
  final String? error;

  /// 成功消息
  final String? successMessage;

  /// 构造函数
  const AuthOperationState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  /// 创建加载状态
  AuthOperationState copyWithLoading() {
    return const AuthOperationState(isLoading: true);
  }

  /// 创建成功状态
  AuthOperationState copyWithSuccess(String message) {
    return AuthOperationState(
      isLoading: false,
      successMessage: message,
    );
  }

  /// 创建错误状态
  AuthOperationState copyWithError(String error) {
    return AuthOperationState(
      isLoading: false,
      error: error,
    );
  }

  /// 清除消息
  AuthOperationState clearMessages() {
    return const AuthOperationState();
  }
}

/// 认证操作通知器
class AuthOperationNotifier extends StateNotifier<AuthOperationState> {
  AuthOperationNotifier() : super(const AuthOperationState());

  /// 执行登录
  Future<bool> login(LoginRequest request) async {
    state = state.copyWithLoading();
    try {
      final authRepo = AuthInitializer.instance;
      final response = await authRepo.loginWithEmail(request);

      if (response.success) {
        state = state.copyWithSuccess('登录成功');
        return true;
      } else {
        state = state.copyWithError(response.error ?? '登录失败');
        return false;
      }
    } catch (e) {
      state = state.copyWithError('登录异常: $e');
      return false;
    }
  }

  /// 执行注册
  Future<bool> register(RegisterRequest request) async {
    state = state.copyWithLoading();
    try {
      final authRepo = AuthInitializer.instance;
      final response = await authRepo.registerWithEmail(request);

      if (response.success) {
        state = state.copyWithSuccess('注册成功，请验证邮箱');
        return true;
      } else {
        state = state.copyWithError(response.error ?? '注册失败');
        return false;
      }
    } catch (e) {
      state = state.copyWithError('注册异常: $e');
      return false;
    }
  }

  /// 执行登出
  Future<bool> logout() async {
    state = state.copyWithLoading();
    try {
      final authRepo = AuthInitializer.instance;
      await authRepo.logout();
      state = state.copyWithSuccess('已登出');
      return true;
    } catch (e) {
      state = state.copyWithError('登出失败: $e');
      return false;
    }
  }

  /// 匿名登录
  Future<bool> loginAnonymously() async {
    state = state.copyWithLoading();
    try {
      final authRepo = AuthInitializer.instance;
      final response = await authRepo.loginAnonymously();

      if (response.success) {
        state = state.copyWithSuccess('匿名登录成功');
        return true;
      } else {
        state = state.copyWithError(response.error ?? '匿名登录失败');
        return false;
      }
    } catch (e) {
      state = state.copyWithError('匿名登录异常: $e');
      return false;
    }
  }

  /// 密码重置
  Future<bool> resetPassword(String email) async {
    state = state.copyWithLoading();
    try {
      final authRepo = AuthInitializer.instance;
      final response = await authRepo.resetPassword(email);

      if (response.success) {
        state = state.copyWithSuccess('密码重置邮件已发送');
        return true;
      } else {
        state = state.copyWithError(response.error ?? '发送失败');
        return false;
      }
    } catch (e) {
      state = state.copyWithError('发送异常: $e');
      return false;
    }
  }

  /// 清除消息
  void clearMessages() {
    state = state.clearMessages();
  }
}

/// 认证操作通知器提供者
final authOperationProvider =
    StateNotifierProvider<AuthOperationNotifier, AuthOperationState>((ref) {
  return AuthOperationNotifier();
});

/// 用户信息通知器
class CurrentUserNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  CurrentUserNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final authRepo = AuthInitializer.instance;
      final user = await authRepo.getCurrentUser();
      state = AsyncValue.data(user);

      // 订阅认证状态变化
      authRepo.authStateChanges().listen((user) {
        state = AsyncValue.data(user);
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 更新用户信息
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final authRepo = AuthInitializer.instance;
      final response = await authRepo.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return response.success;
    } catch (e) {
      appLogger.e('❌ Update profile failed: $e');
      return false;
    }
  }
}

/// 当前用户通知器提供者
final currentUserNotifierProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<AuthUser?>>((ref) {
  return CurrentUserNotifier();
});
