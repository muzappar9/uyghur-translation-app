import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'dart:async';
import 'dart:convert';
import '../services/database/isar_database_service.dart';
import '../data/models/isar_models/pending_sync_model.dart';

/// 挂起的同步操作类型
enum SyncOperationType {
  translation, // 翻译操作
  voiceRecognition, // 语音识别
  ocrRecognition, // OCR识别
}

/// 挂起的同步项目
class PendingSyncItem {
  final int? id;
  final SyncOperationType type;
  final String dataJson; // JSON 字符串格式
  final DateTime createdAt;
  final int retryCount;
  final bool isCompleted;

  PendingSyncItem({
    this.id,
    required this.type,
    required this.dataJson,
    required this.createdAt,
    this.retryCount = 0,
    this.isCompleted = false,
  });

  /// 获取解析后的数据
  Map<String, dynamic> get data => jsonDecode(dataJson);

  /// 转换为 PendingSyncModel 用于存储
  PendingSyncModel toModel() {
    return PendingSyncModel.create(
      entityType: type.toString(),
      entityId:
          id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      action: 'create',
      jsonData: dataJson,
      type: type.toString(),
      data: dataJson,
      createdAt: createdAt,
      retryCount: retryCount,
      isCompleted: isCompleted,
    );
  }

  /// 从 PendingSyncModel 创建
  factory PendingSyncItem.fromModel(PendingSyncModel model) {
    return PendingSyncItem(
      id: model.id,
      type: SyncOperationType.values.firstWhere(
        (e) => e.toString() == model.type,
        orElse: () => SyncOperationType.translation,
      ),
      dataJson: model.data ?? model.jsonData,
      createdAt: model.createdAt ?? model.timestamp,
      retryCount: model.retryCount,
      isCompleted: model.isCompleted,
    );
  }
}

/// 离线同步队列管理器
///
/// 功能：
/// - 队列管理：添加、删除、查询待同步项目
/// - 离线支持：设备离线时缓存操作
/// - 自动同步：网络恢复时自动重试
/// - 重试机制：指数退避重试策略
/// - 持久化：使用 Isar 数据库存储
class PendingSyncQueue {
  final Logger _logger = Logger();

  // 最大重试次数
  static const int maxRetries = 3;

  // 初始延迟（毫秒）
  static const int initialRetryDelayMs = 1000;

  // 最大延迟（毫秒）
  static const int maxRetryDelayMs = 30000;

  /// 向队列添加待同步项目
  ///
  /// 参数：
  /// - [type] 操作类型
  /// - [data] 操作数据
  ///
  /// 返回项目 ID
  Future<int> addPendingItem({
    required SyncOperationType type,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.i('[PendingSync] Adding pending item: ${type.toString()}');

      final item = PendingSyncItem(
        type: type,
        dataJson: jsonEncode(data),
        createdAt: DateTime.now(),
      );

      final isar = IsarDatabaseService.isar;
      final id = await isar.writeTxn(() async {
        return await isar.pendingSyncModels.put(item.toModel());
      });

      _logger.i('[PendingSync] ✓ Item added with ID: $id');
      return id;
    } catch (e) {
      _logger.e('[PendingSync] Error adding pending item: $e');
      rethrow;
    }
  }

  /// 获取所有待同步的项目
  ///
  /// 返回未完成的项目列表
  Future<List<PendingSyncItem>> getPendingItems() async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.pendingSyncModels
          .filter()
          .isCompletedEqualTo(false)
          .sortByTimestamp()
          .findAll();

      final items = models.map((m) => PendingSyncItem.fromModel(m)).toList();
      _logger.d('[PendingSync] Retrieved ${items.length} pending items');
      return items;
    } catch (e) {
      _logger.e('[PendingSync] Error getting pending items: $e');
      rethrow;
    }
  }

  /// 获取特定类型的待同步项目
  ///
  /// 参数：
  /// - [type] 操作类型
  Future<List<PendingSyncItem>> getPendingItemsByType(
      SyncOperationType type) async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.pendingSyncModels
          .filter()
          .isCompletedEqualTo(false)
          .and()
          .typeEqualTo(type.toString())
          .sortByTimestamp()
          .findAll();

      final items = models.map((m) => PendingSyncItem.fromModel(m)).toList();
      _logger.d(
          '[PendingSync] Found ${items.length} pending items of type ${type.toString()}');
      return items;
    } catch (e) {
      _logger.e('[PendingSync] Error getting pending items by type: $e');
      rethrow;
    }
  }

  /// 标记项目为已完成
  ///
  /// 参数：
  /// - [id] 项目 ID
  Future<void> markAsCompleted(int id) async {
    try {
      final isar = IsarDatabaseService.isar;

      final model = await isar.pendingSyncModels.get(id);
      if (model == null) {
        _logger.w('[PendingSync] Item not found: $id');
        return;
      }

      model.isCompleted = true;

      await isar.writeTxn(() async {
        await isar.pendingSyncModels.put(model);
      });

      _logger.i('[PendingSync] ✓ Item marked as completed: $id');
    } catch (e) {
      _logger.e('[PendingSync] Error marking item as completed: $e');
      rethrow;
    }
  }

  /// 增加重试次数
  ///
  /// 参数：
  /// - [id] 项目 ID
  ///
  /// 返回新的重试次数
  Future<int> incrementRetryCount(int id) async {
    try {
      final isar = IsarDatabaseService.isar;

      final model = await isar.pendingSyncModels.get(id);
      if (model == null) {
        _logger.w('[PendingSync] Item not found: $id');
        return 0;
      }

      model.retryCount++;

      // 达到最大重试次数时标记为已完成
      if (model.retryCount >= maxRetries) {
        model.isCompleted = true;
        _logger.w('[PendingSync] Max retries reached for item: $id');
      }

      await isar.writeTxn(() async {
        await isar.pendingSyncModels.put(model);
      });

      return model.retryCount;
    } catch (e) {
      _logger.e('[PendingSync] Error incrementing retry count: $e');
      rethrow;
    }
  }

  /// 删除待同步项目
  ///
  /// 参数：
  /// - [id] 项目 ID
  ///
  /// 返回是否删除成功
  Future<bool> removePendingItem(int id) async {
    try {
      final isar = IsarDatabaseService.isar;

      final success = await isar.writeTxn(() async {
        return await isar.pendingSyncModels.delete(id);
      });

      _logger.i('[PendingSync] ✓ Item removed: $id');
      return success;
    } catch (e) {
      _logger.e('[PendingSync] Error removing pending item: $e');
      rethrow;
    }
  }

  /// 清空所有已完成的项目
  ///
  /// 返回删除的项目数
  Future<int> clearCompletedItems() async {
    try {
      final isar = IsarDatabaseService.isar;

      final toDelete = await isar.pendingSyncModels
          .filter()
          .isCompletedEqualTo(true)
          .findAll();

      final count = await isar.writeTxn(() async {
        await isar.pendingSyncModels
            .deleteAll(toDelete.map((m) => m.id).toList());
        return toDelete.length;
      });

      _logger.i('[PendingSync] ✓ Cleared $count completed items');
      return count;
    } catch (e) {
      _logger.e('[PendingSync] Error clearing completed items: $e');
      rethrow;
    }
  }

  /// 清空所有待同步项目
  ///
  /// 返回删除的项目数
  Future<int> clearAllPendingItems() async {
    try {
      final isar = IsarDatabaseService.isar;

      final count = await isar.writeTxn(() async {
        return await isar.pendingSyncModels.where().deleteAll();
      });

      _logger.i('[PendingSync] ✓ Cleared all pending items: $count items');
      return count;
    } catch (e) {
      _logger.e('[PendingSync] Error clearing all items: $e');
      rethrow;
    }
  }

  /// 获取待同步项目总数
  Future<int> getPendingCount() async {
    try {
      final isar = IsarDatabaseService.isar;
      final count = await isar.pendingSyncModels
          .filter()
          .isCompletedEqualTo(false)
          .count();
      return count;
    } catch (e) {
      _logger.e('[PendingSync] Error getting pending count: $e');
      rethrow;
    }
  }

  /// 获取已完成项目总数
  Future<int> getCompletedCount() async {
    try {
      final isar = IsarDatabaseService.isar;
      final count = await isar.pendingSyncModels
          .filter()
          .isCompletedEqualTo(true)
          .count();
      return count;
    } catch (e) {
      _logger.e('[PendingSync] Error getting completed count: $e');
      rethrow;
    }
  }

  /// 计算指数退避重试延迟
  ///
  /// 参数：
  /// - [retryCount] 重试次数
  ///
  /// 返回延迟时间（毫秒）
  static int calculateRetryDelay(int retryCount) {
    final baseDelay = initialRetryDelayMs * (1 << retryCount); // 2^retryCount
    return baseDelay > maxRetryDelayMs ? maxRetryDelayMs : baseDelay;
  }

  /// 同步待处理项目（需外部调用）
  ///
  /// 这个方法应该由应用程序在网络可用时调用，
  /// 实际的同步逻辑应在调用者中实现
  ///
  /// 参数：
  /// - [onSyncItem] 同步单个项目的回调函数
  ///
  /// 返回成功同步的项目数
  Future<int> syncPendingItems({
    required Future<bool> Function(PendingSyncItem) onSyncItem,
  }) async {
    try {
      _logger.i('[PendingSync] Starting sync of pending items');

      final items = await getPendingItems();
      int syncedCount = 0;

      for (final item in items) {
        try {
          final success = await onSyncItem(item);

          if (success) {
            await markAsCompleted(item.id!);
            syncedCount++;
            _logger.i('[PendingSync] ✓ Item synced: ${item.id}');
          } else {
            final newRetryCount = await incrementRetryCount(item.id!);
            if (newRetryCount < maxRetries) {
              _logger.w(
                  '[PendingSync] Sync failed for item ${item.id}, retry $newRetryCount/$maxRetries');
            }
          }
        } catch (e) {
          _logger.e('[PendingSync] Error syncing item ${item.id}: $e');
          await incrementRetryCount(item.id!);
        }
      }

      _logger.i(
          '[PendingSync] ✓ Sync completed: $syncedCount/${items.length} items');
      return syncedCount;
    } catch (e) {
      _logger.e('[PendingSync] Error in sync process: $e');
      rethrow;
    }
  }
}

/// 待同步队列 Provider
final pendingSyncQueueProvider = Provider<PendingSyncQueue>((ref) {
  return PendingSyncQueue();
});

/// 待同步项目列表 Provider（异步）
final pendingItemsProvider = FutureProvider<List<PendingSyncItem>>((ref) async {
  final queue = ref.watch(pendingSyncQueueProvider);
  return queue.getPendingItems();
});

/// 待同步项目数 Provider（异步）
final pendingCountProvider = FutureProvider<int>((ref) async {
  final queue = ref.watch(pendingSyncQueueProvider);
  return queue.getPendingCount();
});

/// 已完成项目数 Provider（异步）
final completedCountProvider = FutureProvider<int>((ref) async {
  final queue = ref.watch(pendingSyncQueueProvider);
  return queue.getCompletedCount();
});
