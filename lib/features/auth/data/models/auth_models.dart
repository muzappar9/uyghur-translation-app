/// 登录请求模型
class LoginRequest {
  /// 邮箱地址
  final String email;

  /// 密码
  final String password;

  /// 构造函数
  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// 验证输入
  bool isValid() {
    return email.isNotEmpty && email.contains('@') && password.length >= 6;
  }
}

/// 注册请求模型
class RegisterRequest {
  /// 邮箱地址
  final String email;

  /// 密码
  final String password;

  /// 确认密码
  final String passwordConfirm;

  /// 显示名称（可选）
  final String? displayName;

  /// 构造函数
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.passwordConfirm,
    this.displayName,
  });

  /// 验证输入
  bool isValid() {
    final emailValid = email.isNotEmpty && email.contains('@');
    final passwordValid = password.length >= 6 && password == passwordConfirm;
    return emailValid && passwordValid;
  }

  /// 获取验证错误消息
  String? getValidationError() {
    if (email.isEmpty) return '邮箱不能为空';
    if (!email.contains('@')) return '邮箱格式不正确';
    if (password.isEmpty) return '密码不能为空';
    if (password.length < 6) return '密码长度至少 6 位';
    if (password != passwordConfirm) return '两次密码输入不一致';
    return null;
  }
}

/// 认证响应模型
class AuthResponse {
  /// 是否成功
  final bool success;

  /// 错误消息
  final String? error;

  /// 错误代码
  final String? errorCode;

  /// 构造函数 - 成功
  const AuthResponse.success()
      : success = true,
        error = null,
        errorCode = null;

  /// 构造函数 - 失败
  const AuthResponse.failure({
    required this.error,
    this.errorCode,
  }) : success = false;

  /// 工厂方法 - 从错误代码
  factory AuthResponse.fromErrorCode(String code, String message) {
    return AuthResponse.failure(error: message, errorCode: code);
  }

  @override
  String toString() {
    if (success) {
      return 'AuthResponse(success: true)';
    }
    return 'AuthResponse(success: false, error: $error, code: $errorCode)';
  }
}
