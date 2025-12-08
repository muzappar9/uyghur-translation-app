/// 离线模式管理
///
/// 提供离线缓存、数据同步等功能
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'connectivity_service.dart';

/// 离线缓存条目
class OfflineCacheEntry {
  final String key;
  final String data;
  final DateTime cachedAt;
  final DateTime? expiresAt;
  final String? type;
  final Map<String, dynamic>? metadata;

  OfflineCacheEntry({
    required this.key,
    required this.data,
    required this.cachedAt,
    this.expiresAt,
    this.type,
    this.metadata,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'data': data,
        'cachedAt': cachedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'type': type,
        'metadata': metadata,
      };

  factory OfflineCacheEntry.fromJson(Map<String, dynamic> json) {
    return OfflineCacheEntry(
      key: json['key'] as String,
      data: json['data'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      type: json['type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// 待同步项
class PendingSyncItem {
  final String id;
  final String type;
  final String action; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  PendingSyncItem({
    required this.id,
    required this.type,
    required this.action,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  PendingSyncItem copyWith({
    String? id,
    String? type,
    String? action,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return PendingSyncItem(
      id: id ?? this.id,
      type: type ?? this.type,
      action: action ?? this.action,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'action': action,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory PendingSyncItem.fromJson(Map<String, dynamic> json) {
    return PendingSyncItem(
      id: json['id'] as String,
      type: json['type'] as String,
      action: json['action'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// 离线模式状态
class OfflineModeState {
  final bool isOfflineMode;
  final bool hasUnsyncedData;
  final int pendingSyncCount;
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final String? syncError;

  const OfflineModeState({
    this.isOfflineMode = false,
    this.hasUnsyncedData = false,
    this.pendingSyncCount = 0,
    this.lastSyncTime,
    this.isSyncing = false,
    this.syncError,
  });

  OfflineModeState copyWith({
    bool? isOfflineMode,
    bool? hasUnsyncedData,
    int? pendingSyncCount,
    DateTime? lastSyncTime,
    bool? isSyncing,
    String? syncError,
  }) {
    return OfflineModeState(
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      hasUnsyncedData: hasUnsyncedData ?? this.hasUnsyncedData,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
      syncError: syncError,
    );
  }
}

/// 离线缓存服务
class OfflineCacheService {
  static const String _cacheBoxName = 'offline_cache';
  static const String _syncQueueBoxName = 'sync_queue';
  static const String _metadataBoxName = 'offline_metadata';

  Box<String>? _cacheBox;
  Box<String>? _syncQueueBox;
  Box<String>? _metadataBox;

  bool _isInitialized = false;

  /// 初始化缓存
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cacheBox = await Hive.openBox<String>(_cacheBoxName);
      _syncQueueBox = await Hive.openBox<String>(_syncQueueBoxName);
      _metadataBox = await Hive.openBox<String>(_metadataBoxName);
      _isInitialized = true;
      debugPrint('OfflineCacheService initialized');
    } catch (e) {
      debugPrint('Failed to initialize OfflineCacheService: $e');
      rethrow;
    }
  }

  /// 缓存数据
  Future<void> cache({
    required String key,
    required String data,
    Duration? ttl,
    String? type,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();

    final entry = OfflineCacheEntry(
      key: key,
      data: data,
      cachedAt: DateTime.now(),
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
      type: type,
      metadata: metadata,
    );

    await _cacheBox!.put(key, jsonEncode(entry.toJson()));
  }

  /// 获取缓存
  Future<String?> get(String key) async {
    await _ensureInitialized();

    final json = _cacheBox!.get(key);
    if (json == null) return null;

    try {
      final entry = OfflineCacheEntry.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      if (entry.isExpired) {
        await remove(key);
        return null;
      }

      return entry.data;
    } catch (e) {
      debugPrint('Failed to parse cache entry: $e');
      await remove(key);
      return null;
    }
  }

  /// 获取缓存条目
  Future<OfflineCacheEntry?> getEntry(String key) async {
    await _ensureInitialized();

    final json = _cacheBox!.get(key);
    if (json == null) return null;

    try {
      final entry = OfflineCacheEntry.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );

      if (entry.isExpired) {
        await remove(key);
        return null;
      }

      return entry;
    } catch (e) {
      debugPrint('Failed to parse cache entry: $e');
      return null;
    }
  }

  /// 检查是否有缓存
  Future<bool> has(String key) async {
    await _ensureInitialized();
    return _cacheBox!.containsKey(key);
  }

  /// 删除缓存
  Future<void> remove(String key) async {
    await _ensureInitialized();
    await _cacheBox!.delete(key);
  }

  /// 清空所有缓存
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _cacheBox!.clear();
  }

  /// 清理过期缓存
  Future<int> cleanExpired() async {
    await _ensureInitialized();
    int cleaned = 0;

    for (final key in _cacheBox!.keys.toList()) {
      final json = _cacheBox!.get(key);
      if (json != null) {
        try {
          final entry = OfflineCacheEntry.fromJson(
            jsonDecode(json) as Map<String, dynamic>,
          );
          if (entry.isExpired) {
            await _cacheBox!.delete(key);
            cleaned++;
          }
        } catch (e) {
          await _cacheBox!.delete(key);
          cleaned++;
        }
      }
    }

    debugPrint('Cleaned $cleaned expired cache entries');
    return cleaned;
  }

  /// 添加待同步项
  Future<void> addSyncItem(PendingSyncItem item) async {
    await _ensureInitialized();
    await _syncQueueBox!.put(item.id, jsonEncode(item.toJson()));
  }

  /// 获取所有待同步项
  Future<List<PendingSyncItem>> getPendingSyncItems() async {
    await _ensureInitialized();

    final items = <PendingSyncItem>[];
    for (final json in _syncQueueBox!.values) {
      try {
        items.add(PendingSyncItem.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        ));
      } catch (e) {
        debugPrint('Failed to parse sync item: $e');
      }
    }

    // 按创建时间排序
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  /// 删除已同步项
  Future<void> removeSyncItem(String id) async {
    await _ensureInitialized();
    await _syncQueueBox!.delete(id);
  }

  /// 更新同步项重试次数
  Future<void> incrementSyncRetry(String id) async {
    await _ensureInitialized();
    final json = _syncQueueBox!.get(id);
    if (json != null) {
      final item = PendingSyncItem.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
      final updated = item.copyWith(retryCount: item.retryCount + 1);
      await _syncQueueBox!.put(id, jsonEncode(updated.toJson()));
    }
  }

  /// 获取待同步数量
  Future<int> getPendingSyncCount() async {
    await _ensureInitialized();
    return _syncQueueBox!.length;
  }

  /// 保存元数据
  Future<void> setMetadata(String key, String value) async {
    await _ensureInitialized();
    await _metadataBox!.put(key, value);
  }

  /// 获取元数据
  Future<String?> getMetadata(String key) async {
    await _ensureInitialized();
    return _metadataBox!.get(key);
  }

  /// 获取最后同步时间
  Future<DateTime?> getLastSyncTime() async {
    final value = await getMetadata('lastSyncTime');
    if (value != null) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// 保存最后同步时间
  Future<void> setLastSyncTime(DateTime time) async {
    await setMetadata('lastSyncTime', time.toIso8601String());
  }

  /// 获取缓存统计
  Future<Map<String, dynamic>> getStats() async {
    await _ensureInitialized();

    int totalEntries = _cacheBox!.length;
    int pendingSync = _syncQueueBox!.length;

    return {
      'totalEntries': totalEntries,
      'pendingSync': pendingSync,
      'lastSyncTime': await getLastSyncTime(),
    };
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _cacheBox?.close();
    await _syncQueueBox?.close();
    await _metadataBox?.close();
  }
}

/// 离线缓存服务提供者
final offlineCacheServiceProvider = Provider<OfflineCacheService>((ref) {
  final service = OfflineCacheService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 离线模式状态管理器
class OfflineModeNotifier extends AsyncNotifier<OfflineModeState> {
  @override
  Future<OfflineModeState> build() async {
    final cacheService = ref.watch(offlineCacheServiceProvider);
    await cacheService.initialize();

    final connectivity = ref.watch(connectivityInfoProvider);
    final isOffline = connectivity.when(
      data: (info) => info.isOffline,
      loading: () => false,
      error: (_, __) => true,
    );

    final pendingCount = await cacheService.getPendingSyncCount();
    final lastSync = await cacheService.getLastSyncTime();

    return OfflineModeState(
      isOfflineMode: isOffline,
      hasUnsyncedData: pendingCount > 0,
      pendingSyncCount: pendingCount,
      lastSyncTime: lastSync,
    );
  }

  /// 刷新状态
  Future<void> refresh() async {
    final cacheService = ref.read(offlineCacheServiceProvider);
    final current = state.valueOrNull ?? const OfflineModeState();

    final pendingCount = await cacheService.getPendingSyncCount();
    final lastSync = await cacheService.getLastSyncTime();

    state = AsyncValue.data(current.copyWith(
      pendingSyncCount: pendingCount,
      hasUnsyncedData: pendingCount > 0,
      lastSyncTime: lastSync,
    ));
  }

  /// 手动触发同步
  Future<void> sync() async {
    final current = state.valueOrNull ?? const OfflineModeState();

    if (current.isOfflineMode) {
      state = AsyncValue.data(current.copyWith(
        syncError: 'Cannot sync while offline',
      ));
      return;
    }

    state = AsyncValue.data(current.copyWith(
      isSyncing: true,
      syncError: null,
    ));

    try {
      final cacheService = ref.read(offlineCacheServiceProvider);
      final items = await cacheService.getPendingSyncItems();

      // TODO: 实现实际的同步逻辑
      for (final item in items) {
        // 这里应该调用实际的API同步数据
        debugPrint('Syncing item: ${item.id} - ${item.type}');
        await cacheService.removeSyncItem(item.id);
      }

      await cacheService.setLastSyncTime(DateTime.now());

      state = AsyncValue.data(current.copyWith(
        isSyncing: false,
        hasUnsyncedData: false,
        pendingSyncCount: 0,
        lastSyncTime: DateTime.now(),
      ));
    } catch (e) {
      state = AsyncValue.data(current.copyWith(
        isSyncing: false,
        syncError: e.toString(),
      ));
    }
  }

  /// 添加待同步数据
  Future<void> addPendingSync({
    required String id,
    required String type,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    final cacheService = ref.read(offlineCacheServiceProvider);

    await cacheService.addSyncItem(PendingSyncItem(
      id: id,
      type: type,
      action: action,
      data: data,
      createdAt: DateTime.now(),
    ));

    await refresh();
  }
}

/// 离线模式状态提供者
final offlineModeProvider =
    AsyncNotifierProvider<OfflineModeNotifier, OfflineModeState>(
  () => OfflineModeNotifier(),
);
