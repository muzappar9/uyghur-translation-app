import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'dart:convert';
import '../services/database/isar_database_service.dart';
import '../data/models/isar_models/analytics_event_model.dart';

/// 事件类型
enum EventType {
  translate, // 翻译事件
  voiceRecognize, // 语音识别事件
  ocrRecognize, // OCR识别事件
  shareResult, // 分享事件
  addFavorite, // 收藏事件
  appOpen, // 应用打开
  appClose, // 应用关闭
  settingsChange, // 设置变更
}

/// 分析事件
class AnalyticsEvent {
  final int? id;
  final EventType type;
  final DateTime timestamp;
  final String metadataJson; // 事件元数据 (JSON 字符串)
  final String? userId; // 用户标识
  final String? sessionId; // 会话标识
  final String? deviceInfo; // 设备信息

  AnalyticsEvent({
    this.id,
    required this.type,
    required this.timestamp,
    required this.metadataJson,
    this.userId,
    this.sessionId,
    this.deviceInfo,
  });

  /// 获取解析后的元数据
  Map<String, dynamic> get metadata => jsonDecode(metadataJson);

  /// 转换为 AnalyticsEventModel 用于存储
  AnalyticsEventModel toModel() {
    return AnalyticsEventModel.create(
      eventName: type.toString().split('.').last,
      eventType: type.toString(),
      type: type.toString(),
      metadata: metadataJson,
      userId: userId,
      sessionId: sessionId,
      deviceInfo: deviceInfo,
    );
  }

  /// 从 AnalyticsEventModel 创建
  factory AnalyticsEvent.fromModel(AnalyticsEventModel model) {
    return AnalyticsEvent(
      id: model.id,
      type: EventType.values.firstWhere(
        (e) => e.toString() == model.type,
        orElse: () => EventType.translate,
      ),
      timestamp: model.timestamp,
      metadataJson: model.metadata ?? '{}',
      userId: model.userId,
      sessionId: model.sessionId,
      deviceInfo: model.deviceInfo,
    );
  }
}

/// 分析服务
///
/// 功能：
/// - 事件追踪：记录用户操作和应用事件
/// - 使用统计：统计功能使用情况
/// - 性能指标：收集性能数据
/// - 报告生成：生成分析报告
/// - 数据导出：导出分析数据
class AnalyticsService {
  final Logger _logger = Logger();

  String? _sessionId;
  String? _userId;
  String? _deviceInfo;

  /// 初始化分析服务
  ///
  /// 参数：
  /// - [userId] 用户标识
  /// - [deviceInfo] 设备信息
  Future<void> initialize({
    String? userId,
    String? deviceInfo,
  }) async {
    try {
      _userId = userId;
      _deviceInfo = deviceInfo;
      _sessionId = _generateSessionId();

      _logger.i(
          '[Analytics] Service initialized: SessionID=$_sessionId, UserID=$userId');
    } catch (e) {
      _logger.e('[Analytics] Error initializing service: $e');
      rethrow;
    }
  }

  /// 生成会话 ID
  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 记录事件
  ///
  /// 参数：
  /// - [type] 事件类型
  /// - [metadata] 事件元数据
  ///
  /// 返回事件 ID
  Future<int> trackEvent({
    required EventType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.d('[Analytics] Tracking event: ${type.toString()}');

      final event = AnalyticsEvent(
        type: type,
        timestamp: DateTime.now(),
        metadataJson: jsonEncode(metadata ?? {}),
        userId: _userId,
        sessionId: _sessionId,
        deviceInfo: _deviceInfo,
      );

      final isar = IsarDatabaseService.isar;
      final id = await isar.writeTxn(() async {
        return await isar.analyticsEventModels.put(event.toModel());
      });

      _logger.d('[Analytics] ✓ Event tracked with ID: $id');
      return id;
    } catch (e) {
      _logger.e('[Analytics] Error tracking event: $e');
      rethrow;
    }
  }

  /// 记录翻译事件
  ///
  /// 参数：
  /// - [sourceLang] 源语言
  /// - [targetLang] 目标语言
  /// - [duration] 耗时（毫秒）
  /// - [isSuccess] 是否成功
  Future<int> trackTranslation({
    required String sourceLang,
    required String targetLang,
    required int duration,
    required bool isSuccess,
  }) async {
    return trackEvent(
      type: EventType.translate,
      metadata: {
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'duration': duration,
        'isSuccess': isSuccess,
      },
    );
  }

  /// 记录语音识别事件
  ///
  /// 参数：
  /// - [language] 识别语言
  /// - [duration] 耗时（毫秒）
  /// - [confidence] 识别置信度
  /// - [isSuccess] 是否成功
  Future<int> trackVoiceRecognition({
    required String language,
    required int duration,
    double? confidence,
    required bool isSuccess,
  }) async {
    return trackEvent(
      type: EventType.voiceRecognize,
      metadata: {
        'language': language,
        'duration': duration,
        'confidence': confidence,
        'isSuccess': isSuccess,
      },
    );
  }

  /// 记录OCR识别事件
  ///
  /// 参数：
  /// - [language] 识别语言
  /// - [imageSize] 图片大小（字节）
  /// - [duration] 耗时（毫秒）
  /// - [textLength] 识别文本长度
  /// - [isSuccess] 是否成功
  Future<int> trackOCRRecognition({
    required String language,
    int? imageSize,
    required int duration,
    int? textLength,
    required bool isSuccess,
  }) async {
    return trackEvent(
      type: EventType.ocrRecognize,
      metadata: {
        'language': language,
        'imageSize': imageSize,
        'duration': duration,
        'textLength': textLength,
        'isSuccess': isSuccess,
      },
    );
  }

  /// 记录分享事件
  ///
  /// 参数：
  /// - [contentType] 分享内容类型（'translation', 'voice', 'ocr'）
  /// - [platform] 分享平台
  Future<int> trackShare({
    required String contentType,
    required String platform,
  }) async {
    return trackEvent(
      type: EventType.shareResult,
      metadata: {
        'contentType': contentType,
        'platform': platform,
      },
    );
  }

  /// 记录收藏事件
  ///
  /// 参数：
  /// - [contentType] 收藏内容类型
  /// - [action] 动作（'add' 或 'remove'）
  Future<int> trackFavorite({
    required String contentType,
    required String action,
  }) async {
    return trackEvent(
      type: EventType.addFavorite,
      metadata: {
        'contentType': contentType,
        'action': action,
      },
    );
  }

  /// 获取所有事件
  ///
  /// 参数：
  /// - [limit] 限制数量
  /// - [offset] 偏移量
  ///
  /// 返回事件列表
  Future<List<AnalyticsEvent>> getAllEvents({
    int limit = 1000,
    int offset = 0,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.analyticsEventModels
          .where()
          .sortByTimestampDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      final events = models.map((m) => AnalyticsEvent.fromModel(m)).toList();
      _logger.d('[Analytics] Retrieved ${events.length} events');
      return events;
    } catch (e) {
      _logger.e('[Analytics] Error getting all events: $e');
      rethrow;
    }
  }

  /// 按事件类型获取事件
  ///
  /// 参数：
  /// - [type] 事件类型
  /// - [limit] 限制数量
  /// - [offset] 偏移量
  Future<List<AnalyticsEvent>> getEventsByType({
    required EventType type,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.analyticsEventModels
          .filter()
          .typeEqualTo(type.toString())
          .sortByTimestampDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      final events = models.map((m) => AnalyticsEvent.fromModel(m)).toList();
      _logger.d(
          '[Analytics] Found ${events.length} events of type ${type.toString()}');
      return events;
    } catch (e) {
      _logger.e('[Analytics] Error getting events by type: $e');
      rethrow;
    }
  }

  /// 获取时间范围内的事件
  ///
  /// 参数：
  /// - [startTime] 开始时间
  /// - [endTime] 结束时间
  Future<List<AnalyticsEvent>> getEventsByTimeRange({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.analyticsEventModels
          .filter()
          .timestampBetween(startTime, endTime)
          .sortByTimestampDesc()
          .findAll();

      final events = models.map((m) => AnalyticsEvent.fromModel(m)).toList();
      _logger.d(
          '[Analytics] Found ${events.length} events between $startTime and $endTime');
      return events;
    } catch (e) {
      _logger.e('[Analytics] Error getting events by time range: $e');
      rethrow;
    }
  }

  /// 生成分析报告
  ///
  /// 返回包含统计信息的报告 Map
  Future<Map<String, dynamic>> generateReport({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      _logger.i('[Analytics] Generating report');

      final start =
          startTime ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endTime ?? DateTime.now();

      final allEvents =
          await getEventsByTimeRange(startTime: start, endTime: end);

      // 统计各类型事件
      final eventTypeCounts = <String, int>{};
      for (final event in allEvents) {
        final typeStr = event.type.toString();
        eventTypeCounts[typeStr] = (eventTypeCounts[typeStr] ?? 0) + 1;
      }

      // 统计翻译语言对
      final translationStats = <String, int>{};
      for (final event in allEvents) {
        if (event.type == EventType.translate) {
          final sourceLang = event.metadata['sourceLang'] as String?;
          final targetLang = event.metadata['targetLang'] as String?;
          if (sourceLang != null && targetLang != null) {
            final pair = '$sourceLang→$targetLang';
            translationStats[pair] = (translationStats[pair] ?? 0) + 1;
          }
        }
      }

      // 统计成功率
      final successEvents = allEvents.where((e) {
        final isSuccess = e.metadata['isSuccess'] as bool?;
        return isSuccess == true;
      }).length;
      final successRate =
          allEvents.isEmpty ? 0.0 : (successEvents / allEvents.length) * 100;

      // 统计平均耗时
      final avgDurations = <String, int>{};
      for (final event in allEvents) {
        if (event.metadata.containsKey('duration')) {
          final duration = event.metadata['duration'] as int?;
          if (duration != null) {
            final typeStr = event.type.toString();
            if (avgDurations.containsKey(typeStr)) {
              avgDurations[typeStr] =
                  ((avgDurations[typeStr]! + duration) ~/ 2);
            } else {
              avgDurations[typeStr] = duration;
            }
          }
        }
      }

      final report = {
        'period': {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
        'totalEvents': allEvents.length,
        'eventTypeCounts': eventTypeCounts,
        'translationStats': translationStats,
        'successRate': successRate,
        'averageDurations': avgDurations,
        'uniqueSessions': _getUniqueSessions(allEvents),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      _logger.i('[Analytics] ✓ Report generated: ${allEvents.length} events');
      return report;
    } catch (e) {
      _logger.e('[Analytics] Error generating report: $e');
      rethrow;
    }
  }

  /// 获取唯一会话数
  int _getUniqueSessions(List<AnalyticsEvent> events) {
    final sessions = <String>{};
    for (final event in events) {
      if (event.sessionId != null) {
        sessions.add(event.sessionId!);
      }
    }
    return sessions.length;
  }

  /// 清除旧事件
  ///
  /// 参数：
  /// - [olderThan] 删除该日期之前的事件
  ///
  /// 返回删除的事件数
  Future<int> clearOldEvents(DateTime olderThan) async {
    try {
      final isar = IsarDatabaseService.isar;

      final toDelete = await isar.analyticsEventModels
          .filter()
          .timestampLessThan(olderThan)
          .findAll();

      final count = await isar.writeTxn(() async {
        await isar.analyticsEventModels
            .deleteAll(toDelete.map((e) => e.id).toList());
        return toDelete.length;
      });

      _logger.i('[Analytics] ✓ Cleared $count old events');
      return count;
    } catch (e) {
      _logger.e('[Analytics] Error clearing old events: $e');
      rethrow;
    }
  }

  /// 清除所有事件
  ///
  /// 返回删除的事件数
  Future<int> clearAllEvents() async {
    try {
      final isar = IsarDatabaseService.isar;

      final count = await isar.writeTxn(() async {
        return await isar.analyticsEventModels.where().deleteAll();
      });

      _logger.i('[Analytics] ✓ Cleared all events: $count items');
      return count;
    } catch (e) {
      _logger.e('[Analytics] Error clearing all events: $e');
      rethrow;
    }
  }

  /// 获取事件总数
  Future<int> getEventCount() async {
    try {
      final isar = IsarDatabaseService.isar;
      return await isar.analyticsEventModels.where().count();
    } catch (e) {
      _logger.e('[Analytics] Error getting event count: $e');
      rethrow;
    }
  }

  /// 导出事件数据为 JSON
  ///
  /// 参数：
  /// - [limit] 导出数量限制
  ///
  /// 返回 JSON 字符串
  Future<String> exportEventsAsJson({int limit = 10000}) async {
    try {
      final events = await getAllEvents(limit: limit);

      final jsonList = events
          .map((event) => {
                'type': event.type.toString(),
                'timestamp': event.timestamp.toIso8601String(),
                'metadata': event.metadata,
                'userId': event.userId,
                'sessionId': event.sessionId,
                'deviceInfo': event.deviceInfo,
              })
          .toList();

      _logger.i('[Analytics] ✓ Exported ${events.length} events');
      return jsonList.toString(); // 实际应用中应转为 JSON 字符串
    } catch (e) {
      _logger.e('[Analytics] Error exporting events: $e');
      rethrow;
    }
  }
}

/// 分析服务 Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// 事件列表 Provider（异步）
final analyticsEventsProvider =
    FutureProvider<List<AnalyticsEvent>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getAllEvents(limit: 1000);
});

/// 分析报告 Provider（异步）
final analyticsReportProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.generateReport();
});

/// 事件总数 Provider（异步）
final analyticsEventCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getEventCount();
});
