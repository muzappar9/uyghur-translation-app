import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/local_auth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../data/models/auth_models.dart';

/// 认证服务提供者（选择 Firebase 或本地实现）
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  // 优先使用 Firebase，如果不可用则使用本地认证
  try {
    final firebaseAuth = FirebaseAuth.instance;
    return FirebaseAuthService(firebaseAuth: firebaseAuth);
  } catch (e) {
    // 降级到本地认证
    appLogger.w('⚠️ Firebase Auth 不可用，使用本地认证服务');
    final prefs = await SharedPreferences.getInstance();
    return LocalAuthService(prefs: prefs);
  }
});

/// 获取认证仓库（简化访问）
final authService = Provider<AuthRepository>((ref) {
  // 这个需要在应用启动时异步初始化
  throw UnsupportedError(
    '请使用 authRepositoryProvider 或在应用启动时初始化',
  );
});

/// 当前登录用户
final currentUserProvider = StreamProvider<AuthUser?>((ref) async* {
  final authRepo = await ref.watch(authRepositoryProvider.future);
  yield* authRepo.authStateChanges();
});

/// 用户是否已登录
final isUserLoggedInProvider = FutureProvider<bool>((ref) async {
  final authRepo = await ref.watch(authRepositoryProvider.future);
  return authRepo.isUserLoggedIn();
});

/// 用户认证状态
final userAuthStateProvider =
    StateNotifierProvider<UserAuthStateNotifier, AsyncValue<AuthUser?>>(
  (ref) {
    final authRepositoryAsync = ref.watch(authRepositoryProvider);
    return UserAuthStateNotifier(authRepositoryAsync);
  },
);

/// 用户认证状态通知器
class UserAuthStateNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  final AsyncValue<AuthRepository>? _authRepositoryAsync;

  UserAuthStateNotifier(AsyncValue<AuthRepository> authRepositoryAsync)
      : _authRepositoryAsync = authRepositoryAsync,
        super(const AsyncValue.loading()) {
    _initialize(authRepositoryAsync);
  }

  Future<void> _initialize(
      AsyncValue<AuthRepository> authRepositoryAsync) async {
    await authRepositoryAsync.when(
      data: (authRepo) async {
        final user = await authRepo.getCurrentUser();
        state = AsyncValue.data(user);

        // 监听认证状态变化
        authRepo.authStateChanges().listen((user) {
          state = AsyncValue.data(user);
        });
      },
      loading: () {},
      error: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  /// 邮箱注册
  Future<AuthResponse> registerWithEmail(RegisterRequest request) async {
    final authRepo = _authRepositoryAsync?.when(
      data: (repo) => repo,
      loading: () => null,
      error: (_, __) => null,
    );

    if (authRepo == null) {
      return const AuthResponse.failure(error: '认证服务未初始化');
    }

    final result = await authRepo.registerWithEmail(request);
    if (result.success) {
      final user = await authRepo.getCurrentUser();
      state = AsyncValue.data(user);
    }
    return result;
  }

  /// 邮箱登录
  Future<AuthResponse> loginWithEmail(LoginRequest request) async {
    final authRepo = _authRepositoryAsync?.when(
      data: (repo) => repo,
      loading: () => null,
      error: (_, __) => null,
    );

    if (authRepo == null) {
      return const AuthResponse.failure(error: '认证服务未初始化');
    }

    final result = await authRepo.loginWithEmail(request);
    if (result.success) {
      final user = await authRepo.getCurrentUser();
      state = AsyncValue.data(user);
    }
    return result;
  }

  /// 登出
  Future<void> logout() async {
    final authRepo = _authRepositoryAsync?.when(
      data: (repo) => repo,
      loading: () => null,
      error: (_, __) => null,
    );

    if (authRepo != null) {
      await authRepo.logout();
      state = const AsyncValue.data(null);
    }
  }
}

/// 独立的登录 Provider
final loginProvider = FutureProvider.family<AuthResponse, LoginRequest>(
  (ref, request) async {
    final authRepo = await ref.watch(authRepositoryProvider.future);
    return authRepo.loginWithEmail(request);
  },
);

/// 独立的注册 Provider
final registerProvider = FutureProvider.family<AuthResponse, RegisterRequest>(
  (ref, request) async {
    final authRepo = await ref.watch(authRepositoryProvider.future);
    return authRepo.registerWithEmail(request);
  },
);

/// 独立的密码重置 Provider
final resetPasswordProvider = FutureProvider.family<AuthResponse, String>(
  (ref, email) async {
    final authRepo = await ref.watch(authRepositoryProvider.future);
    return authRepo.resetPassword(email);
  },
);

/// 独立的匿名登录 Provider
final anonymousLoginProvider = FutureProvider<AuthResponse>((ref) async {
  final authRepo = await ref.watch(authRepositoryProvider.future);
  return authRepo.loginAnonymously();
});

/// 登出 Provider
final logoutProvider = FutureProvider<void>((ref) async {
  final authRepo = await ref.watch(authRepositoryProvider.future);
  return authRepo.logout();
});
