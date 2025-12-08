import 'package:hive_flutter/hive_flutter.dart';

/// Hive 本地偏好设置服务
class PreferenceService {
  static const String _boxName = 'app_preferences';
  late Box _preferencesBox;

  /// 初始化 Hive
  Future<void> init() async {
    await Hive.initFlutter();
    _preferencesBox = await Hive.openBox(_boxName);
  }

  // ==================== 语言设置 ====================
  /// 获取当前语言，默认中文
  String getLanguage() => _preferencesBox.get('language', defaultValue: 'zh');

  /// 设置语言
  Future<void> setLanguage(String lang) =>
      _preferencesBox.put('language', lang);

  // ==================== 主题设置 ====================
  /// 获取是否为深色模式
  bool isDarkMode() => _preferencesBox.get('isDarkMode', defaultValue: false);

  /// 设置深色模式
  Future<void> setDarkMode(bool isDark) =>
      _preferencesBox.put('isDarkMode', isDark);

  // ==================== 初始化状态 ====================
  /// 获取是否为首次启动
  bool isFirstLaunch() =>
      _preferencesBox.get('isFirstLaunch', defaultValue: true);

  /// 标记首次启动已完成
  Future<void> setFirstLaunchDone() =>
      _preferencesBox.put('isFirstLaunch', false);

  // ==================== 其他设置 ====================
  /// 获取用户 ID
  String? getUserId() => _preferencesBox.get('userId');

  /// 设置用户 ID
  Future<void> setUserId(String? userId) =>
      _preferencesBox.put('userId', userId);

  /// 清空所有设置（用于登出）
  Future<void> clearAll() => _preferencesBox.clear();
}
