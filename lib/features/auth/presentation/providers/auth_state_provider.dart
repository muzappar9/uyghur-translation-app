import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_initializer.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../data/models/auth_models.dart';

/// 认证仓库提供者
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthInitializer.instance;
});

/// 当前用户 Stream 提供者
final currentUserStreamProvider = StreamProvider<AuthUser?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges();
});

/// 当前用户（最新值）
final currentUserProvider = FutureProvider<AuthUser?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentUser();
});

/// 用户登录状态
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.isUserLoggedIn();
});

/// 登录状态（Stream，实时更新）
final isLoggedInStreamProvider = StreamProvider<bool>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges().map((user) => user != null);
});

// === 认证操作 Providers ===

/// 用户邮箱登录
final emailLoginProvider = FutureProvider.family<AuthResponse, LoginRequest>(
  (ref, request) async {
    final authRepo = ref.watch(authRepositoryProvider);
    final response = await authRepo.loginWithEmail(request);
    return response;
  },
);

/// 用户邮箱注册
final emailRegisterProvider =
    FutureProvider.family<AuthResponse, RegisterRequest>(
  (ref, request) async {
    final authRepo = ref.watch(authRepositoryProvider);
    final response = await authRepo.registerWithEmail(request);
    return response;
  },
);

/// 匿名登录
final anonymousLoginProvider = FutureProvider<AuthResponse>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.loginAnonymously();
});

/// 登出
final logoutProvider = FutureProvider<void>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  await authRepo.logout();
});

/// 密码重置
final passwordResetProvider =
    FutureProvider.family<AuthResponse, String>((ref, email) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.resetPassword(email);
});

/// 更新用户信息
final updateUserProfileProvider =
    FutureProvider.family<AuthResponse, Map<String, String?>>(
        (ref, data) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.updateUserProfile(
    displayName: data['displayName'],
    photoUrl: data['photoUrl'],
  );
});

/// 删除账号
final deleteAccountProvider = FutureProvider<AuthResponse>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.deleteAccount();
});

/// 重新发送验证邮件
final resendVerificationEmailProvider =
    FutureProvider.family<AuthResponse, String>((ref, email) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.resendVerificationEmail(email);
});
