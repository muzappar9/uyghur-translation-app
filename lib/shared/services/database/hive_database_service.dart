import 'package:hive_flutter/hive_flutter.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';

/// Hive 数据库服务 - 替代 Isar
/// 提供简单的键值存储和对象存储
class HiveDatabaseService {
  static const String _translationHistoryBox = 'translation_history';
  static const String _favoritesBox = 'favorites';
  static const String _userPreferencesBox = 'user_preferences';
  static const String _pendingSyncBox = 'pending_sync';
  static const String _ocrResultsBox = 'ocr_results';
  static const String _analyticsBox = 'analytics_events';

  static bool _isInitialized = false;

  /// 初始化 Hive 数据库
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      
      // 打开所有需要的 Box
      await Hive.openBox<Map>(_translationHistoryBox);
      await Hive.openBox<Map>(_favoritesBox);
      await Hive.openBox<Map>(_userPreferencesBox);
      await Hive.openBox<Map>(_pendingSyncBox);
      await Hive.openBox<Map>(_ocrResultsBox);
      await Hive.openBox<Map>(_analyticsBox);
      
      _isInitialized = true;
      appLogger.i('Hive database initialized successfully');
    } catch (e) {
      appLogger.e('Failed to initialize Hive: $e');
      rethrow;
    }
  }

  /// 检查是否已初始化
  static bool get isInitialized => _isInitialized;

  // ========== 翻译历史操作 ==========
  
  static Box<Map> get _historyBox => Hive.box<Map>(_translationHistoryBox);

  /// 保存翻译历史
  static Future<int> saveTranslationHistory(Map<String, dynamic> data) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    data['id'] = id;
    data['createdAt'] = DateTime.now().toIso8601String();
    await _historyBox.put(id.toString(), data);
    return id;
  }

  /// 获取所有翻译历史
  static List<Map<String, dynamic>> getAllTranslationHistory() {
    return _historyBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
  }

  /// 获取单条翻译历史
  static Map<String, dynamic>? getTranslationHistory(int id) {
    final data = _historyBox.get(id.toString());
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// 删除翻译历史
  static Future<void> deleteTranslationHistory(int id) async {
    await _historyBox.delete(id.toString());
  }

  /// 清空翻译历史
  static Future<void> clearTranslationHistory() async {
    await _historyBox.clear();
  }

  /// 按来源语言获取翻译历史
  static List<Map<String, dynamic>> getHistoryBySourceLanguage(String lang) {
    return getAllTranslationHistory()
        .where((item) => item['sourceLanguage'] == lang)
        .toList();
  }

  // ========== 收藏操作 ==========
  
  static Box<Map> get _favBox => Hive.box<Map>(_favoritesBox);

  /// 添加到收藏
  static Future<int> addFavorite(Map<String, dynamic> data) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    data['id'] = id;
    data['createdAt'] = DateTime.now().toIso8601String();
    await _favBox.put(id.toString(), data);
    return id;
  }

  /// 获取所有收藏
  static List<Map<String, dynamic>> getAllFavorites() {
    return _favBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
  }

  /// 移除收藏
  static Future<void> removeFavorite(int id) async {
    await _favBox.delete(id.toString());
  }

  /// 检查是否已收藏
  static bool isFavorite(String sourceText, String targetText) {
    return getAllFavorites().any((item) =>
        item['sourceText'] == sourceText && item['targetText'] == targetText);
  }

  // ========== 用户偏好设置 ==========
  
  static Box<Map> get _prefBox => Hive.box<Map>(_userPreferencesBox);

  /// 保存用户偏好设置
  static Future<void> saveUserPreferences(Map<String, dynamic> prefs) async {
    await _prefBox.put('user_prefs', prefs);
  }

  /// 获取用户偏好设置
  static Map<String, dynamic>? getUserPreferences() {
    final data = _prefBox.get('user_prefs');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // ========== OCR 结果操作 ==========
  
  static Box<Map> get _ocrBox => Hive.box<Map>(_ocrResultsBox);

  /// 保存 OCR 结果
  static Future<int> saveOcrResult(Map<String, dynamic> data) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    data['id'] = id;
    data['createdAt'] = DateTime.now().toIso8601String();
    await _ocrBox.put(id.toString(), data);
    return id;
  }

  /// 获取所有 OCR 结果
  static List<Map<String, dynamic>> getAllOcrResults() {
    return _ocrBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
  }

  /// 删除 OCR 结果
  static Future<void> deleteOcrResult(int id) async {
    await _ocrBox.delete(id.toString());
  }

  // ========== 待同步队列操作 ==========
  
  static Box<Map> get _syncBox => Hive.box<Map>(_pendingSyncBox);

  /// 添加待同步项
  static Future<int> addPendingSync(Map<String, dynamic> data) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    data['id'] = id;
    data['createdAt'] = DateTime.now().toIso8601String();
    await _syncBox.put(id.toString(), data);
    return id;
  }

  /// 获取所有待同步项
  static List<Map<String, dynamic>> getAllPendingSync() {
    return _syncBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// 移除待同步项
  static Future<void> removePendingSync(int id) async {
    await _syncBox.delete(id.toString());
  }

  /// 清空待同步队列
  static Future<void> clearPendingSync() async {
    await _syncBox.clear();
  }

  // ========== 分析事件操作 ==========
  
  static Box<Map> get _analyticsBoxInstance => Hive.box<Map>(_analyticsBox);

  /// 保存分析事件
  static Future<void> saveAnalyticsEvent(Map<String, dynamic> event) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    event['id'] = id;
    event['timestamp'] = DateTime.now().toIso8601String();
    await _analyticsBoxInstance.put(id, event);
  }

  /// 获取所有分析事件
  static List<Map<String, dynamic>> getAllAnalyticsEvents() {
    return _analyticsBoxInstance.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// 清空分析事件
  static Future<void> clearAnalyticsEvents() async {
    await _analyticsBoxInstance.clear();
  }

  // ========== 通用工具方法 ==========

  /// 关闭所有 Box
  static Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// 清空所有数据
  static Future<void> clearAll() async {
    await _historyBox.clear();
    await _favBox.clear();
    await _prefBox.clear();
    await _ocrBox.clear();
    await _syncBox.clear();
    await _analyticsBoxInstance.clear();
  }
}
