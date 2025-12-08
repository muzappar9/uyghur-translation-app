/// 同步服务
/// 
/// 管理离线数据与服务器的同步
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_service.dart';

/// 同步状态
enum SyncStatus {
  /// 空闲
  idle,
  /// 同步中
  syncing,
  /// 同步成功
  success,
  /// 同步失败
  failed,
  /// 等待网络
  waitingForNetwork,
}

/// 同步项类型
enum SyncItemType {
  /// 翻译
  translation,
  /// 收藏
  favorite,
  /// 历史记录
  history,
  /// 设置
  settings,
  /// 用户数据
  userData,
}

/// 同步项
class SyncItem {
  final String id;
  final SyncItemType type;
  final String action; // create, update, delete
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  const SyncItem({
    required this.id,
    required this.type,
    required this.action,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  SyncItem copyWith({
    int? retryCount,
    String? lastError,
  }) {
    return SyncItem(
      id: id,
      type: type,
      action: action,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'action': action,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
    'lastError': lastError,
  };

  factory SyncItem.fromJson(Map<String, dynamic> json) => SyncItem(
    id: json['id'] as String,
    type: SyncItemType.values[json['type'] as int],
    action: json['action'] as String,
    data: json['data'] as Map<String, dynamic>,
    createdAt: DateTime.parse(json['createdAt'] as String),
    retryCount: json['retryCount'] as int? ?? 0,
    lastError: json['lastError'] as String?,
  );
}

/// 同步结果
class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final List<String> errors;
  final DateTime timestamp;

  const SyncResult({
    required this.success,
    required this.syncedCount,
    required this.failedCount,
    required this.errors,
    required this.timestamp,
  });

  factory SyncResult.success(int count) => SyncResult(
    success: true,
    syncedCount: count,
    failedCount: 0,
    errors: [],
    timestamp: DateTime.now(),
  );

  factory SyncResult.failed(List<String> errors) => SyncResult(
    success: false,
    syncedCount: 0,
    failedCount: errors.length,
    errors: errors,
    timestamp: DateTime.now(),
  );

  factory SyncResult.partial(int synced, int failed, List<String> errors) => SyncResult(
    success: false,
    syncedCount: synced,
    failedCount: failed,
    errors: errors,
    timestamp: DateTime.now(),
  );
}

/// 同步状态数据
class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final int pendingCount;
  final SyncResult? lastResult;
  final String? currentOperation;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.pendingCount = 0,
    this.lastResult,
    this.currentOperation,
  });

  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasPendingItems => pendingCount > 0;
  
  String get statusText {
    switch (status) {
      case SyncStatus.idle:
        return '已同步';
      case SyncStatus.syncing:
        return currentOperation ?? '同步中...';
      case SyncStatus.success:
        return '同步成功';
      case SyncStatus.failed:
        return '同步失败';
      case SyncStatus.waitingForNetwork:
        return '等待网络';
    }
  }

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    int? pendingCount,
    SyncResult? lastResult,
    String? currentOperation,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingCount: pendingCount ?? this.pendingCount,
      lastResult: lastResult ?? this.lastResult,
      currentOperation: currentOperation ?? this.currentOperation,
    );
  }
}

/// 同步配置
class SyncConfig {
  /// 自动同步间隔（分钟）
  final int autoSyncIntervalMinutes;
  
  /// 最大重试次数
  final int maxRetryCount;
  
  /// 重试延迟（秒）
  final int retryDelaySeconds;
  
  /// 仅在 WiFi 下同步
  final bool syncOnlyOnWifi;
  
  /// 后台同步
  final bool enableBackgroundSync;

  const SyncConfig({
    this.autoSyncIntervalMinutes = 15,
    this.maxRetryCount = 3,
    this.retryDelaySeconds = 30,
    this.syncOnlyOnWifi = false,
    this.enableBackgroundSync = true,
  });
}

/// 同步服务
class SyncService {
  final ConnectivityService _connectivityService;
  
  final List<SyncItem> _pendingItems = [];
  final _syncStatusController = StreamController<SyncState>.broadcast();
  
  SyncState _currentState = const SyncState();
  SyncConfig _config = const SyncConfig();
  Timer? _autoSyncTimer;
  StreamSubscription<ConnectivityInfo>? _networkSubscription;
  bool _isInitialized = false;

  SyncService({
    required ConnectivityService connectivityService,
  }) : _connectivityService = connectivityService;

  /// 同步状态流
  Stream<SyncState> get stateStream => _syncStatusController.stream;

  /// 当前状态
  SyncState get currentState => _currentState;

  /// 配置
  SyncConfig get config => _config;

  /// 初始化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // 加载待同步项
    await _loadPendingItems();
    
    // 监听网络状态
    _networkSubscription = _connectivityService.statusStream.listen((status) {
      if (!status.isOffline && _pendingItems.isNotEmpty) {
        _updateState(_currentState.copyWith(
          status: SyncStatus.idle,
        ));
        // 网络恢复时自动同步
        syncNow();
      } else if (status.isOffline) {
        _updateState(_currentState.copyWith(
          status: SyncStatus.waitingForNetwork,
        ));
      }
    });
    
    // 启动自动同步
    _startAutoSync();
    
    _isInitialized = true;
  }

  /// 更新配置
  void updateConfig(SyncConfig config) {
    _config = config;
    _startAutoSync(); // 重启定时器
  }

  /// 添加同步项
  Future<void> addSyncItem(SyncItem item) async {
    _pendingItems.add(item);
    await _savePendingItems();
    
    _updateState(_currentState.copyWith(
      pendingCount: _pendingItems.length,
    ));

    // 如果在线，立即同步
    if (_connectivityService.isOnline) {
      syncNow();
    }
  }

  /// 批量添加同步项
  Future<void> addSyncItems(List<SyncItem> items) async {
    _pendingItems.addAll(items);
    await _savePendingItems();
    
    _updateState(_currentState.copyWith(
      pendingCount: _pendingItems.length,
    ));
  }

  /// 立即同步
  Future<SyncResult> syncNow() async {
    if (_currentState.isSyncing) {
      return SyncResult.failed(['同步正在进行中']);
    }

    if (_connectivityService.isOffline) {
      _updateState(_currentState.copyWith(
        status: SyncStatus.waitingForNetwork,
      ));
      return SyncResult.failed(['无网络连接']);
    }

    // 检查 WiFi 限制
    if (_config.syncOnlyOnWifi && !_connectivityService.currentInfo.isWifi) {
      return SyncResult.failed(['仅在 WiFi 下同步']);
    }

    _updateState(_currentState.copyWith(
      status: SyncStatus.syncing,
      currentOperation: '正在同步...',
    ));

    try {
      // 同步待处理项
      final result = await _syncPendingItems();
      
      _updateState(_currentState.copyWith(
        status: result.success ? SyncStatus.success : SyncStatus.failed,
        lastSyncTime: DateTime.now(),
        lastResult: result,
        pendingCount: _pendingItems.length,
        currentOperation: null,
      ));
      
      return result;
    } catch (e) {
      final result = SyncResult.failed([e.toString()]);
      _updateState(_currentState.copyWith(
        status: SyncStatus.failed,
        lastResult: result,
        currentOperation: null,
      ));
      return result;
    }
  }

  /// 同步待处理项
  Future<SyncResult> _syncPendingItems() async {
    if (_pendingItems.isEmpty) {
      return SyncResult.success(0);
    }

    int syncedCount = 0;
    final errors = <String>[];
    final itemsToRemove = <SyncItem>[];

    for (final item in _pendingItems) {
      _updateState(_currentState.copyWith(
        currentOperation: '同步 ${_getItemTypeName(item.type)}...',
      ));

      try {
        await _syncItem(item);
        syncedCount++;
        itemsToRemove.add(item);
      } catch (e) {
        if (item.retryCount >= _config.maxRetryCount) {
          errors.add('${_getItemTypeName(item.type)}: $e');
          itemsToRemove.add(item); // 超过重试次数，移除
        } else {
          // 增加重试计数
          final index = _pendingItems.indexOf(item);
          _pendingItems[index] = item.copyWith(
            retryCount: item.retryCount + 1,
            lastError: e.toString(),
          );
        }
      }
    }

    // 移除已同步和失败的项
    for (final item in itemsToRemove) {
      _pendingItems.remove(item);
    }
    await _savePendingItems();

    if (errors.isEmpty) {
      return SyncResult.success(syncedCount);
    } else if (syncedCount > 0) {
      return SyncResult.partial(syncedCount, errors.length, errors);
    } else {
      return SyncResult.failed(errors);
    }
  }

  /// 同步单个项目
  Future<void> _syncItem(SyncItem item) async {
    // 模拟同步延迟
    await Future.delayed(const Duration(milliseconds: 100));
    
    // TODO: 实现实际的同步逻辑
    switch (item.type) {
      case SyncItemType.translation:
        await _syncTranslation(item);
        break;
      case SyncItemType.favorite:
        await _syncFavorite(item);
        break;
      case SyncItemType.history:
        await _syncHistory(item);
        break;
      case SyncItemType.settings:
        await _syncSettings(item);
        break;
      case SyncItemType.userData:
        await _syncUserData(item);
        break;
    }
  }

  Future<void> _syncTranslation(SyncItem item) async {
    // 同步翻译记录到远程服务器
    // 实际实现时应该调用 API 将翻译数据上传
    debugPrint('Syncing translation: ${item.id}');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _syncFavorite(SyncItem item) async {
    // 同步收藏数据到远程服务器
    debugPrint('Syncing favorite: ${item.id}');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _syncHistory(SyncItem item) async {
    // 同步历史记录到远程服务器
    debugPrint('Syncing history: ${item.id}');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _syncSettings(SyncItem item) async {
    // 同步设置到远程服务器
    debugPrint('Syncing settings: ${item.id}');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _syncUserData(SyncItem item) async {
    // 同步用户数据到远程服务器
    debugPrint('Syncing user data: ${item.id}');
    await Future.delayed(const Duration(milliseconds: 50));
  }

  String _getItemTypeName(SyncItemType type) {
    switch (type) {
      case SyncItemType.translation:
        return '翻译';
      case SyncItemType.favorite:
        return '收藏';
      case SyncItemType.history:
        return '历史';
      case SyncItemType.settings:
        return '设置';
      case SyncItemType.userData:
        return '用户数据';
    }
  }

  /// 启动自动同步
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    
    if (_config.enableBackgroundSync && _config.autoSyncIntervalMinutes > 0) {
      _autoSyncTimer = Timer.periodic(
        Duration(minutes: _config.autoSyncIntervalMinutes),
        (_) => syncNow(),
      );
    }
  }

  /// 加载待同步项
  Future<void> _loadPendingItems() async {
    // 从内存缓存加载（实际应用中应使用 SharedPreferences 或数据库）
    // 当前实现使用内存存储，应用重启后数据会丢失
    // 生产环境应该使用持久化存储
    _updateState(_currentState.copyWith(
      pendingCount: _pendingItems.length,
    ));
  }

  /// 保存待同步项
  Future<void> _savePendingItems() async {
    // 当前实现使用内存存储
    // 生产环境应该序列化并存储到 SharedPreferences 或数据库
    // 示例：
    // final prefs = await SharedPreferences.getInstance();
    // final jsonList = _pendingItems.map((item) => jsonEncode(item.toJson())).toList();
    // await prefs.setStringList('pending_sync_items', jsonList);
  }

  void _updateState(SyncState newState) {
    _currentState = newState;
    _syncStatusController.add(newState);
  }

  /// 清除所有待同步项
  Future<void> clearPendingItems() async {
    _pendingItems.clear();
    await _savePendingItems();
    
    _updateState(_currentState.copyWith(
      pendingCount: 0,
    ));
  }

  /// 获取待同步项列表
  List<SyncItem> get pendingItems => List.unmodifiable(_pendingItems);

  /// 释放资源
  void dispose() {
    _autoSyncTimer?.cancel();
    _networkSubscription?.cancel();
    _syncStatusController.close();
  }
}

/// 同步服务提供者
final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  final service = SyncService(
    connectivityService: connectivityService,
  );
  
  ref.onDispose(() => service.dispose());
  
  return service;
});

/// 同步状态提供者
final syncStateProvider = StreamProvider<SyncState>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.stateStream;
});

/// 待同步数量提供者
final pendingSyncCountProvider = Provider<int>((ref) {
  final state = ref.watch(syncStateProvider);
  return state.when(
    data: (data) => data.pendingCount,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// 是否正在同步提供者
final isSyncingProvider = Provider<bool>((ref) {
  final state = ref.watch(syncStateProvider);
  return state.when(
    data: (data) => data.isSyncing,
    loading: () => false,
    error: (_, __) => false,
  );
});
