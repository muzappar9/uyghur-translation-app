import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_models.dart';
import 'package:uuid/uuid.dart';

/// 本地认证服务 - 用于离线模式或备选认证
class LocalAuthService implements AuthRepository {
  final SharedPreferences _prefs;
  final _authStateController = StreamController<AuthUser?>.broadcast();

  /// 存储键
  // _authUserKey 未直接使用，但保留作为文档注释
  static const String _usersKey = 'users_data';
  static const String _currentUserIdKey = 'current_user_id';

  /// 构造函数
  LocalAuthService({required SharedPreferences prefs}) : _prefs = prefs;

  /// 邮箱注册
  @override
  Future<AuthResponse> registerWithEmail(RegisterRequest request) async {
    try {
      // 验证输入
      final validationError = request.getValidationError();
      if (validationError != null) {
        return AuthResponse.failure(error: validationError);
      }

      // 检查邮箱是否已存在
      final existingUser = await _findUserByEmail(request.email);
      if (existingUser != null) {
        return const AuthResponse.failure(error: '该邮箱已被注册');
      }

      // 创建新用户
      final userId = const Uuid().v4();
      final newUser = AuthUser(
        uid: userId,
        email: request.email,
        displayName: request.displayName ?? '用户',
        isEmailVerified: false,
        createdAt: DateTime.now(),
        isAnonymous: false,
      );

      // 保存用户数据
      await _saveUser(newUser, request.password);
      await _setCurrentUser(newUser);

      appLogger.i('✅ 本地用户注册成功: ${request.email}');
      _authStateController.add(newUser);
      return const AuthResponse.success();
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

      // 查找用户
      final user = await _findUserByEmail(request.email);
      if (user == null) {
        return const AuthResponse.failure(error: '用户不存在');
      }

      // 验证密码
      final storedPassword = _prefs.getString('pwd_${user.uid}');
      if (storedPassword != request.password) {
        return const AuthResponse.failure(error: '密码错误');
      }

      // 更新登录时间
      final updatedUser = user.copyWith(
        lastSignInTime: DateTime.now(),
      );
      await _updateUser(updatedUser);
      await _setCurrentUser(updatedUser);

      appLogger.i('✅ 本地用户登录成功: ${request.email}');
      _authStateController.add(updatedUser);
      return const AuthResponse.success();
    } catch (e) {
      return AuthResponse.failure(error: '登录失败: $e');
    }
  }

  /// 匿名登录
  @override
  Future<AuthResponse> loginAnonymously() async {
    try {
      final userId = const Uuid().v4();
      final anonymousUser = AuthUser(
        uid: userId,
        email: null,
        displayName: '游客用户',
        createdAt: DateTime.now(),
        isAnonymous: true,
      );

      await _setCurrentUser(anonymousUser);
      appLogger.i('✅ 本地匿名登录成功');
      _authStateController.add(anonymousUser);
      return const AuthResponse.success();
    } catch (e) {
      return AuthResponse.failure(error: '匿名登录失败: $e');
    }
  }

  /// 登出
  @override
  Future<void> logout() async {
    try {
      await _prefs.remove(_currentUserIdKey);
      appLogger.i('✅ 本地用户已登出');
      _authStateController.add(null);
    } catch (e) {
      appLogger.e('❌ 登出失败: $e');
      throw Exception('登出失败: $e');
    }
  }

  /// 获取当前用户
  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final userId = _prefs.getString(_currentUserIdKey);
      if (userId == null) return null;

      final userJson = _prefs.getString('user_$userId');
      if (userJson == null) return null;

      return _parseAuthUser(userJson);
    } catch (e) {
      appLogger.e('❌ 获取当前用户失败: $e');
      return null;
    }
  }

  /// 检查用户是否登录
  @override
  Future<bool> isUserLoggedIn() async {
    return _prefs.containsKey(_currentUserIdKey);
  }

  /// 监听认证状态变化
  @override
  Stream<AuthUser?> authStateChanges() {
    return _authStateController.stream;
  }

  /// 重新发送验证邮件（本地实现）
  @override
  Future<AuthResponse> resendVerificationEmail(String email) async {
    try {
      appLogger.i('✅ 本地验证邮件已标记为"已发送"');
      return const AuthResponse.success();
    } catch (e) {
      return AuthResponse.failure(error: '发送验证邮件失败: $e');
    }
  }

  /// 密码重置
  @override
  Future<AuthResponse> resetPassword(String email) async {
    try {
      final user = await _findUserByEmail(email);
      if (user == null) {
        return const AuthResponse.failure(error: '用户不存在');
      }

      // 在实际应用中，这里应该生成临时密码或重置令牌
      appLogger.i('✅ 本地密码重置请求已处理');
      return const AuthResponse.success();
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
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return const AuthResponse.failure(error: '用户未登录');
      }

      final updatedUser = currentUser.copyWith(
        displayName: displayName ?? currentUser.displayName,
        photoUrl: photoUrl ?? currentUser.photoUrl,
      );

      await _updateUser(updatedUser);
      _authStateController.add(updatedUser);

      appLogger.i('✅ 本地用户信息已更新');
      return const AuthResponse.success();
    } catch (e) {
      return AuthResponse.failure(error: '更新用户信息失败: $e');
    }
  }

  /// 删除账号
  @override
  Future<AuthResponse> deleteAccount() async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return const AuthResponse.failure(error: '用户未登录');
      }

      // 删除用户数据
      await _prefs.remove('user_${currentUser.uid}');
      await _prefs.remove('pwd_${currentUser.uid}');
      await _prefs.remove(_currentUserIdKey);

      appLogger.i('✅ 本地账号已删除');
      _authStateController.add(null);
      return const AuthResponse.success();
    } catch (e) {
      return AuthResponse.failure(error: '删除账号失败: $e');
    }
  }

  // === 私有方法 ===

  /// 按邮箱查找用户
  Future<AuthUser?> _findUserByEmail(String email) async {
    try {
      final userIds = _prefs.getStringList(_usersKey) ?? [];
      for (final userId in userIds) {
        final userJson = _prefs.getString('user_$userId');
        if (userJson != null) {
          final user = _parseAuthUser(userJson);
          if (user.email == email) {
            return user;
          }
        }
      }
      return null;
    } catch (e) {
      appLogger.e('❌ 查找用户失败: $e');
      return null;
    }
  }

  /// 保存用户数据
  Future<void> _saveUser(AuthUser user, String password) async {
    try {
      // 保存用户信息
      final userJson = _authUserToJson(user);
      await _prefs.setString('user_${user.uid}', userJson);

      // 保存密码（实际应用应该哈希）
      await _prefs.setString('pwd_${user.uid}', password);

      // 添加到用户列表
      final userIds = _prefs.getStringList(_usersKey) ?? [];
      if (!userIds.contains(user.uid)) {
        userIds.add(user.uid);
        await _prefs.setStringList(_usersKey, userIds);
      }
    } catch (e) {
      appLogger.e('❌ 保存用户失败: $e');
    }
  }

  /// 更新用户数据
  Future<void> _updateUser(AuthUser user) async {
    try {
      final userJson = _authUserToJson(user);
      await _prefs.setString('user_${user.uid}', userJson);
    } catch (e) {
      appLogger.e('❌ 更新用户失败: $e');
    }
  }

  /// 设置当前用户
  Future<void> _setCurrentUser(AuthUser user) async {
    try {
      await _prefs.setString(_currentUserIdKey, user.uid);
      await _updateUser(user);
    } catch (e) {
      appLogger.e('❌ 设置当前用户失败: $e');
    }
  }

  /// AuthUser 转 JSON 字符串
  String _authUserToJson(AuthUser user) {
    return '${user.uid}|${user.email}|${user.displayName}|${user.photoUrl}|${user.isEmailVerified}|${user.createdAt}|${user.lastSignInTime}|${user.isAnonymous}';
  }

  /// JSON 字符串转 AuthUser
  AuthUser _parseAuthUser(String json) {
    final parts = json.split('|');
    return AuthUser(
      uid: parts[0],
      email: parts[1].isEmpty ? null : parts[1],
      displayName: parts[2].isEmpty ? null : parts[2],
      photoUrl: parts[3].isEmpty ? null : parts[3],
      isEmailVerified: parts[4] == 'true',
      createdAt: DateTime.tryParse(parts[5]),
      lastSignInTime: DateTime.tryParse(parts[6]),
      isAnonymous: parts[7] == 'true',
    );
  }

  /// 销毁
  void dispose() {
    _authStateController.close();
  }
}
