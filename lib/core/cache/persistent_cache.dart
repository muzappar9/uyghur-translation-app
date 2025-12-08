import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================
/// Stage 21: 持久化缓存系统
/// ============================================

/// 持久化缓存条目
class PersistentCacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? tag;

  PersistentCacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
    this.tag,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson(dynamic Function(T) valueSerializer) {
    return {
      'value': valueSerializer(value),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'tag': tag,
    };
  }

  factory PersistentCacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) valueDeserializer,
  ) {
    return PersistentCacheEntry(
      value: valueDeserializer(json['value']),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      tag: json['tag'],
    );
  }
}

/// 持久化缓存存储
class PersistentCache {
  static const String _cachePrefix = 'app_cache_';
  static const String _indexKey = 'app_cache_index';

  final SharedPreferences _prefs;
  final Set<String> _keys = {};

  PersistentCache._(this._prefs) {
    _loadIndex();
  }

  static Future<PersistentCache> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return PersistentCache._(prefs);
  }

  void _loadIndex() {
    final indexJson = _prefs.getString(_indexKey);
    if (indexJson != null) {
      final List<dynamic> index = json.decode(indexJson);
      _keys.addAll(index.cast<String>());
    }
  }

  Future<void> _saveIndex() async {
    await _prefs.setString(_indexKey, json.encode(_keys.toList()));
  }

  String _prefixedKey(String key) => '$_cachePrefix$key';

  /// 存储字符串
  Future<void> setString(
    String key,
    String value, {
    Duration? ttl,
    String? tag,
  }) async {
    final entry = PersistentCacheEntry(
      value: value,
      createdAt: DateTime.now(),
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
      tag: tag,
    );

    final entryJson = json.encode(entry.toJson((v) => v));
    await _prefs.setString(_prefixedKey(key), entryJson);
    _keys.add(key);
    await _saveIndex();
  }

  /// 获取字符串
  String? getString(String key) {
    final entryJson = _prefs.getString(_prefixedKey(key));
    if (entryJson == null) return null;

    try {
      final entryMap = json.decode(entryJson) as Map<String, dynamic>;
      final entry = PersistentCacheEntry.fromJson(entryMap, (v) => v as String);

      if (entry.isExpired) {
        remove(key);
        return null;
      }

      return entry.value;
    } catch (e) {
      debugPrint('PersistentCache: Error reading key $key: $e');
      return null;
    }
  }

  /// 存储JSON对象
  Future<void> setJson(
    String key,
    Map<String, dynamic> value, {
    Duration? ttl,
    String? tag,
  }) async {
    await setString(key, json.encode(value), ttl: ttl, tag: tag);
  }

  /// 获取JSON对象
  Map<String, dynamic>? getJson(String key) {
    final str = getString(key);
    if (str == null) return null;

    try {
      return json.decode(str) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('PersistentCache: Error parsing JSON for key $key: $e');
      return null;
    }
  }

  /// 存储列表
  Future<void> setList(
    String key,
    List<dynamic> value, {
    Duration? ttl,
    String? tag,
  }) async {
    await setString(key, json.encode(value), ttl: ttl, tag: tag);
  }

  /// 获取列表
  List<dynamic>? getList(String key) {
    final str = getString(key);
    if (str == null) return null;

    try {
      return json.decode(str) as List<dynamic>;
    } catch (e) {
      debugPrint('PersistentCache: Error parsing list for key $key: $e');
      return null;
    }
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    if (!_keys.contains(key)) return false;

    // 检查是否过期
    final entryJson = _prefs.getString(_prefixedKey(key));
    if (entryJson == null) {
      _keys.remove(key);
      return false;
    }

    try {
      final entryMap = json.decode(entryJson) as Map<String, dynamic>;
      if (entryMap['expiresAt'] != null) {
        final expiresAt = DateTime.parse(entryMap['expiresAt']);
        if (DateTime.now().isAfter(expiresAt)) {
          remove(key);
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 移除缓存
  Future<void> remove(String key) async {
    await _prefs.remove(_prefixedKey(key));
    _keys.remove(key);
    await _saveIndex();
  }

  /// 清除所有缓存
  Future<void> clear() async {
    for (final key in _keys.toList()) {
      await _prefs.remove(_prefixedKey(key));
    }
    _keys.clear();
    await _saveIndex();
  }

  /// 清除带有特定标签的缓存
  Future<void> clearByTag(String tag) async {
    final keysToRemove = <String>[];

    for (final key in _keys) {
      final entryJson = _prefs.getString(_prefixedKey(key));
      if (entryJson != null) {
        try {
          final entryMap = json.decode(entryJson) as Map<String, dynamic>;
          if (entryMap['tag'] == tag) {
            keysToRemove.add(key);
          }
        } catch (_) {}
      }
    }

    for (final key in keysToRemove) {
      await remove(key);
    }
  }

  /// 清除过期缓存
  Future<int> cleanExpired() async {
    int removed = 0;
    final now = DateTime.now();

    for (final key in _keys.toList()) {
      final entryJson = _prefs.getString(_prefixedKey(key));
      if (entryJson != null) {
        try {
          final entryMap = json.decode(entryJson) as Map<String, dynamic>;
          if (entryMap['expiresAt'] != null) {
            final expiresAt = DateTime.parse(entryMap['expiresAt']);
            if (now.isAfter(expiresAt)) {
              await remove(key);
              removed++;
            }
          }
        } catch (_) {}
      }
    }

    return removed;
  }

  /// 获取所有键
  List<String> get keys => _keys.toList();

  /// 获取缓存大小（键数量）
  int get size => _keys.length;

  /// 获取估算的存储大小（字节）
  Future<int> getEstimatedSize() async {
    int totalSize = 0;
    for (final key in _keys) {
      final value = _prefs.getString(_prefixedKey(key));
      if (value != null) {
        totalSize += value.length * 2; // UTF-16 编码
      }
    }
    return totalSize;
  }

  /// 获取缓存统计
  Future<Map<String, dynamic>> getStats() async {
    return {
      'keyCount': size,
      'estimatedSize': await getEstimatedSize(),
      'keys': keys,
    };
  }
}

/// 离线数据存储
class OfflineStorage {
  final PersistentCache _cache;

  static const String _translationHistoryKey = 'offline_translation_history';
  static const String _pendingSyncKey = 'offline_pending_sync';
  static const String _lastSyncTimeKey = 'offline_last_sync';

  OfflineStorage(this._cache);

  /// 保存翻译到离线历史
  Future<void> saveTranslation(Map<String, dynamic> translation) async {
    final history = getTranslationHistory();
    history.insert(0, translation);

    // 保留最近500条
    if (history.length > 500) {
      history.removeRange(500, history.length);
    }

    await _cache.setList(
      _translationHistoryKey,
      history,
      tag: 'offline',
    );
  }

  /// 获取离线翻译历史
  List<Map<String, dynamic>> getTranslationHistory() {
    final list = _cache.getList(_translationHistoryKey);
    if (list == null) return [];
    return list.cast<Map<String, dynamic>>();
  }

  /// 添加待同步项
  Future<void> addPendingSync(Map<String, dynamic> item) async {
    final pending = getPendingSyncItems();
    pending.add({
      ...item,
      'pendingSince': DateTime.now().toIso8601String(),
    });

    await _cache.setList(
      _pendingSyncKey,
      pending,
      tag: 'sync',
    );
  }

  /// 获取待同步项
  List<Map<String, dynamic>> getPendingSyncItems() {
    final list = _cache.getList(_pendingSyncKey);
    if (list == null) return [];
    return list.cast<Map<String, dynamic>>();
  }

  /// 清除待同步项
  Future<void> clearPendingSync() async {
    await _cache.remove(_pendingSyncKey);
  }

  /// 记录最后同步时间
  Future<void> recordSync() async {
    await _cache.setString(
      _lastSyncTimeKey,
      DateTime.now().toIso8601String(),
      tag: 'sync',
    );
  }

  /// 获取最后同步时间
  DateTime? getLastSyncTime() {
    final str = _cache.getString(_lastSyncTimeKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  /// 需要同步
  bool get needsSync {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;

    // 超过1小时需要同步
    return DateTime.now().difference(lastSync) > const Duration(hours: 1);
  }

  /// 清除所有离线数据
  Future<void> clearAll() async {
    await _cache.clearByTag('offline');
    await _cache.clearByTag('sync');
  }
}

/// 搜索历史缓存
class SearchHistoryCache {
  final PersistentCache _cache;
  static const String _keyPrefix = 'search_history_';
  static const int maxHistorySize = 50;

  SearchHistoryCache(this._cache);

  String _getKey(String category) => '$_keyPrefix$category';

  /// 添加搜索历史
  Future<void> addSearch(String category, String query) async {
    final history = getHistory(category);

    // 移除已存在的相同查询
    history.remove(query);

    // 添加到开头
    history.insert(0, query);

    // 限制数量
    if (history.length > maxHistorySize) {
      history.removeRange(maxHistorySize, history.length);
    }

    await _cache.setList(
      _getKey(category),
      history,
      tag: 'search_history',
    );
  }

  /// 获取搜索历史
  List<String> getHistory(String category) {
    final list = _cache.getList(_getKey(category));
    if (list == null) return [];
    return list.cast<String>();
  }

  /// 清除特定类别的搜索历史
  Future<void> clearHistory(String category) async {
    await _cache.remove(_getKey(category));
  }

  /// 清除所有搜索历史
  Future<void> clearAll() async {
    await _cache.clearByTag('search_history');
  }

  /// 删除特定搜索记录
  Future<void> removeSearch(String category, String query) async {
    final history = getHistory(category);
    history.remove(query);
    await _cache.setList(
      _getKey(category),
      history,
      tag: 'search_history',
    );
  }
}
