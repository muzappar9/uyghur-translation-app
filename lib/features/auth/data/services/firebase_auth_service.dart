import 'package:firebase_auth/firebase_auth.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_models.dart';

/// Firebase 认证异常
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Firebase 认证服务实现
class FirebaseAuthService implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  /// 构造函数
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// 邮箱注册
  @override
  Future<AuthResponse> registerWithEmail(RegisterRequest request) async {
    try {
      // 验证输入
      final validationError = request.getValidationError();
      if (validationError != null) {
        return AuthResponse.failure(error: validationError);
      }

      // 创建账户
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      // 更新用户信息
      if (request.displayName != null && request.displayName!.isNotEmpty) {
        await userCredential.user?.updateDisplayName(request.displayName);
      }

      // 发送验证邮件
      await userCredential.user?.sendEmailVerification();

      appLogger.i('✅ 用户注册成功: ${request.email}');
      return const AuthResponse.success();
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResponse.failure(error: '注册失败: $e');
    }
  }

  /// 邮箱登录
  @override
  Future<AuthResponse> loginWithEmail(LoginRequest request) async {
    try {
      // 验证输入
      if (!request.isValid()) {
        return const AuthResponse.failure(error: '邮箱或密码格式不正确');
      }

      // 登录
      await _firebaseAuth.signInWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      appLogger.i('✅ 用户登录成功: ${request.email}');
      return const AuthResponse.success();
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResponse.failure(error: '登录失败: $e');
    }
  }

  /// 匿名登录
  @override
  Future<AuthResponse> loginAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
      appLogger.i('✅ 匿名登录成功');
      return const AuthResponse.success();
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResponse.failure(error: '匿名登录失败: $e');
    }
  }

  /// 登出
  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      appLogger.i('✅ 用户已登出');
    } catch (e) {
      appLogger.e('❌ 登出失败: $e');
      throw AuthException('登出失败: $e');
    }
  }

  /// 获取当前用户
  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return _firebaseUserToAuthUser(user);
    } catch (e) {
      appLogger.e('❌ 获取当前用户失败: $e');
      return null;
    }
  }

  /// 检查用户是否登录
  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      appLogger.e('❌ 检查登录状态失败: $e');
      return false;
    }
  }

  /// 监听认证状态变化
  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return _firebaseUserToAuthUser(firebaseUser);
    });
  }

  /// 重新发送验证邮件
  @override
  Future<AuthResponse> resendVerificationEmail(String email) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthResponse.failure(error: '用户未登录');
      }

      await user.sendEmailVerification();
      appLogger.i('✅ 验证邮件已重新发送');
      return const AuthResponse.success();
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResponse.failure(error: '发送验证邮件失败: $e');
    }
  }

  /// 密码重置
  @override
  Future<AuthResponse> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      appLogger.i('✅ 密码重置邮件已发送: $email');
      return const AuthResponse.success();
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResponse.failure(error: '发送重置邮件失败: $e');
    }
  }

  /// 更新用户信息
  @override
  Future<AuthResponse> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthResponse.failure(error: '用户未登录');
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);

      appLogger.i('✅ 用户信息已更新');
      return const AuthResponse.success();
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResponse.failure(error: '更新用户信息失败: $e');
    }
  }

  /// 删除账号
  @override
  Future<AuthResponse> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const AuthResponse.failure(error: '用户未登录');
      }

      await user.delete();
      appLogger.i('✅ 账号已删除');
      return const AuthResponse.success();
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return AuthResponse.failure(error: '删除账号失败: $e');
    }
  }

  // === 私有方法 ===

  /// 处理 Firebase 认证异常
  AuthResponse _handleFirebaseAuthException(FirebaseAuthException e) {
    String message = '认证出错';

    switch (e.code) {
      case 'weak-password':
        message = '密码过于简单，请使用至少6位密码';
        break;
      case 'email-already-in-use':
        message = '该邮箱已被注册';
        break;
      case 'invalid-email':
        message = '邮箱格式不正确';
        break;
      case 'user-disabled':
        message = '该用户账号已被禁用';
        break;
      case 'user-not-found':
        message = '用户不存在';
        break;
      case 'wrong-password':
        message = '密码错误';
        break;
      case 'too-many-requests':
        message = '尝试次数过多，请稍后再试';
        break;
      case 'operation-not-allowed':
        message = '该操作不被允许';
        break;
      case 'requires-recent-login':
        message = '请重新登录以继续该操作';
        break;
      default:
        message = '认证失败: ${e.message}';
    }

    return AuthResponse.failure(error: message, errorCode: e.code);
  }

  /// 将 Firebase User 转换为 AuthUser
  AuthUser _firebaseUserToAuthUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      isAnonymous: user.isAnonymous,
    );
  }
}
