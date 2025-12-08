import '../../data/models/auth_models.dart';
import '../entities/auth_user.dart';

/// 认证服务接口
abstract class AuthRepository {
  /// 邮箱注册
  Future<AuthResponse> registerWithEmail(RegisterRequest request);

  /// 邮箱登录
  Future<AuthResponse> loginWithEmail(LoginRequest request);

  /// 匿名登录
  Future<AuthResponse> loginAnonymously();

  /// 登出
  Future<void> logout();

  /// 获取当前用户
  Future<AuthUser?> getCurrentUser();

  /// 检查用户是否登录
  Future<bool> isUserLoggedIn();

  /// 监听认证状态变化
  Stream<AuthUser?> authStateChanges();

  /// 重新发送验证邮件
  Future<AuthResponse> resendVerificationEmail(String email);

  /// 密码重置
  Future<AuthResponse> resetPassword(String email);

  /// 更新用户信息
  Future<AuthResponse> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  /// 删除账号
  Future<AuthResponse> deleteAccount();
}
