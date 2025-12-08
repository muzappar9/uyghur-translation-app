/// 认证用户实体
class AuthUser {
  /// 用户 ID
  final String uid;

  /// 邮箱
  final String? email;

  /// 显示名称
  final String? displayName;

  /// 头像 URL
  final String? photoUrl;

  /// 是否已验证邮箱
  final bool isEmailVerified;

  /// 创建时间
  final DateTime? createdAt;

  /// 最后登录时间
  final DateTime? lastSignInTime;

  /// 是否为匿名用户
  final bool isAnonymous;

  /// 构造函数
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.createdAt,
    this.lastSignInTime,
    this.isAnonymous = false,
  });

  /// 复制并修改字段
  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInTime,
    bool? isAnonymous,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  String toString() {
    return 'AuthUser(uid: $uid, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthUser && other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}
