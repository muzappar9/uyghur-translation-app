/// 翻译缓存服务 - 集成 Stage 21 缓存系统
///
/// 提供翻译缓存层，结合内存缓存和持久化存储
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../core/cache/memory_cache.dart';
import '../../core/cache/persistent_cache.dart';
import '../../core/performance/performance_monitor.dart';
import '../../core/utils/debounce_throttle.dart';
import 'translation/translation_manager.dart';
import 'translation/translation_engine.dart';

/// 带缓存的翻译服务
///
/// 集成:
/// - 内存缓存 (快速访问)
/// - 持久化缓存 (离线支持)
/// - 性能监控
class CachedTranslationService {
  final TranslationManager _translationManager;
  final TranslationCache _memoryCache;
  final OfflineStorage _offlineStorage;
  final Logger _logger = Logger();

  // 用于防抖搜索建议
  late final SearchDebouncer _suggestionDebouncer;

  // 异步缓存 - 避免重复请求
  late final AsyncMemoize<String, String> _translationMemoizer;

  CachedTranslationService({
    required TranslationManager translationManager,
    required TranslationCache memoryCache,
    required OfflineStorage offlineStorage,
  })  : _translationManager = translationManager,
        _memoryCache = memoryCache,
        _offlineStorage = offlineStorage {
    // 初始化建议防抖器
    _suggestionDebouncer = SearchDebouncer(
      delay: const Duration(milliseconds: 300),
    );

    // 初始化异步缓存
    _translationMemoizer = AsyncMemoize((String key) async {
      final parts = key.split('|');
      return await _translationManager.translate(parts[0], parts[1], parts[2]);
    }, maxSize: 100);
  }

  /// 翻译文本 (带缓存)
  ///
  /// 缓存策略:
  /// 1. 先查内存缓存
  /// 2. 再查持久化缓存
  /// 3. 最后调用翻译 API
  /// 4. 结果写入两级缓存
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    final timerName = 'translation_${sourceLang}_$targetLang';
    PerformanceMonitor().startTimer(timerName);

    try {
      // 1. 检查内存缓存
      final memoryCached =
          _memoryCache.getTranslation(text, sourceLang, targetLang);

      if (memoryCached != null) {
        _logger.d('Memory cache hit for: $text');
        PerformanceMonitor().record(
          MetricType.cacheHitRate,
          1.0,
          label: 'memory',
        );
        PerformanceMonitor().endTimer(timerName);
        return memoryCached;
      }

      // 2. 检查持久化缓存 (离线翻译历史)
      final historyItems = _offlineStorage.getTranslationHistory();
      for (final item in historyItems) {
        if (item['sourceText'] == text &&
            item['sourceLang'] == sourceLang &&
            item['targetLang'] == targetLang) {
          final targetText = item['targetText'] as String;

          // 写入内存缓存
          _memoryCache.cacheTranslation(
              text, targetText, sourceLang, targetLang);

          _logger.d('Persistent cache hit for: $text');
          PerformanceMonitor().record(
            MetricType.cacheHitRate,
            1.0,
            label: 'persistent',
          );
          PerformanceMonitor().endTimer(timerName);
          return targetText;
        }
      }

      // 3. 调用翻译 API (使用 memoizer 避免重复请求)
      final cacheKey = '$text|$sourceLang|$targetLang';
      final result = await _translationMemoizer(cacheKey);

      // 4. 写入缓存
      _memoryCache.cacheTranslation(text, result, sourceLang, targetLang);

      await _offlineStorage.saveTranslation({
        'sourceText': text,
        'targetText': result,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _logger.i('Translation completed (API): $text → $result');
      PerformanceMonitor().record(
        MetricType.cacheHitRate,
        0.0,
        label: 'api',
      );
      PerformanceMonitor().endTimer(timerName);

      return result;
    } catch (e) {
      PerformanceMonitor().endTimer(timerName);
      _logger.e('Translation failed: $e');
      rethrow;
    }
  }

  /// 批量翻译 (优化性能)
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String sourceLang,
    String targetLang,
  ) async {
    final results = <String, String>{};
    final toTranslate = <String>[];

    // 先检查缓存
    for (final text in texts) {
      final cached = _memoryCache.getTranslation(text, sourceLang, targetLang);
      if (cached != null) {
        results[text] = cached;
      } else {
        toTranslate.add(text);
      }
    }

    // 并行翻译未缓存的文本
    if (toTranslate.isNotEmpty) {
      final futures = toTranslate.map((text) async {
        try {
          final result = await translate(text, sourceLang, targetLang);
          return MapEntry(text, result);
        } catch (e) {
          _logger.w('Failed to translate: $text - $e');
          return MapEntry(text, '[$e]');
        }
      });

      final translatedEntries = await Future.wait(futures);
      results.addEntries(translatedEntries);
    }

    return results;
  }

  /// 获取翻译建议 (带防抖)
  void getSuggestions({
    required String query,
    required void Function(String query) onSearch,
  }) {
    _suggestionDebouncer.search(query, onSearch);
  }

  /// 获取缓存统计
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCache': _memoryCache.stats,
      'memoizerSize': _translationMemoizer.size,
    };
  }

  /// 清空所有缓存
  Future<void> clearAllCaches() async {
    _memoryCache.clear();
    _translationMemoizer.clear();
    await _offlineStorage.clearAll();
    _logger.i('All translation caches cleared');
  }

  /// 释放资源
  void dispose() {
    _suggestionDebouncer.dispose();
  }
}

/// 持久化缓存 Provider (需要异步初始化)
final persistentCacheProvider = FutureProvider<PersistentCache>((ref) async {
  return await PersistentCache.initialize();
});

/// 离线存储 Provider
final offlineStorageProvider = Provider<OfflineStorage>((ref) {
  final cacheAsync = ref.watch(persistentCacheProvider);
  return cacheAsync.when(
    data: (cache) => OfflineStorage(cache),
    loading: () => throw StateError('PersistentCache not initialized'),
    error: (e, _) => throw StateError('PersistentCache failed: $e'),
  );
});

/// 缓存翻译服务 Provider
final cachedTranslationServiceProvider =
    Provider<CachedTranslationService>((ref) {
  final translationManager = ref.watch(_translationManagerProvider);
  final memoryCache = ref.watch(translationCacheProvider);
  final offlineStorage = ref.watch(offlineStorageProvider);

  final service = CachedTranslationService(
    translationManager: translationManager,
    memoryCache: memoryCache,
    offlineStorage: offlineStorage,
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// 内部翻译管理器 Provider
final _translationManagerProvider = Provider<TranslationManager>((ref) {
  // 使用 LocalMockTranslationEngine 作为后备
  return TranslationManager(engines: [LocalMockTranslationEngine()]);
});
