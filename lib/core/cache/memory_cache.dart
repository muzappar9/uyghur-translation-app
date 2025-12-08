import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================
/// Stage 21: 内存缓存系统
/// ============================================

/// 缓存条目
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration? ttl;
  int accessCount;
  DateTime lastAccessedAt;

  CacheEntry({
    required this.value,
    this.ttl,
  })  : createdAt = DateTime.now(),
        accessCount = 0,
        lastAccessedAt = DateTime.now();

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(createdAt) > ttl!;
  }

  void recordAccess() {
    accessCount++;
    lastAccessedAt = DateTime.now();
  }
}

/// LRU缓存策略
enum CacheEvictionPolicy {
  lru, // 最近最少使用
  lfu, // 最少频率使用
  fifo, // 先进先出
  ttl, // 基于过期时间
}

/// 通用内存缓存
class MemoryCache<K, V> {
  final int maxSize;
  final Duration? defaultTtl;
  final CacheEvictionPolicy evictionPolicy;
  final LinkedHashMap<K, CacheEntry<V>> _cache = LinkedHashMap();

  // 统计信息
  int _hits = 0;
  int _misses = 0;

  MemoryCache({
    this.maxSize = 100,
    this.defaultTtl,
    this.evictionPolicy = CacheEvictionPolicy.lru,
  });

  /// 获取缓存值
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) {
      _misses++;
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      _misses++;
      return null;
    }

    entry.recordAccess();
    _hits++;

    // LRU: 移到最后
    if (evictionPolicy == CacheEvictionPolicy.lru) {
      _cache.remove(key);
      _cache[key] = entry;
    }

    return entry.value;
  }

  /// 设置缓存值
  void set(K key, V value, {Duration? ttl}) {
    // 如果达到最大容量，先清理
    while (_cache.length >= maxSize) {
      _evict();
    }

    _cache[key] = CacheEntry(
      value: value,
      ttl: ttl ?? defaultTtl,
    );
  }

  /// 检查是否存在
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// 删除缓存
  void remove(K key) {
    _cache.remove(key);
  }

  /// 清空所有缓存
  void clear() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
  }

  /// 清理过期条目
  void cleanExpired() {
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// 根据策略驱逐条目
  void _evict() {
    if (_cache.isEmpty) return;

    K? keyToRemove;

    switch (evictionPolicy) {
      case CacheEvictionPolicy.lru:
      case CacheEvictionPolicy.fifo:
        // 移除第一个（最旧的）
        keyToRemove = _cache.keys.first;
        break;

      case CacheEvictionPolicy.lfu:
        // 移除访问次数最少的
        int minAccess = -1;
        for (final entry in _cache.entries) {
          if (minAccess == -1 || entry.value.accessCount < minAccess) {
            minAccess = entry.value.accessCount;
            keyToRemove = entry.key;
          }
        }
        break;

      case CacheEvictionPolicy.ttl:
        // 移除最快过期的
        DateTime? earliestExpiry;
        for (final entry in _cache.entries) {
          if (entry.value.ttl != null) {
            final expiry = entry.value.createdAt.add(entry.value.ttl!);
            if (earliestExpiry == null || expiry.isBefore(earliestExpiry)) {
              earliestExpiry = expiry;
              keyToRemove = entry.key;
            }
          }
        }
        // 如果没有带TTL的，使用FIFO
        keyToRemove ??= _cache.keys.first;
        break;
    }

    if (keyToRemove != null) {
      _cache.remove(keyToRemove);
    }
  }

  /// 缓存大小
  int get size => _cache.length;

  /// 命中率
  double get hitRate {
    final total = _hits + _misses;
    if (total == 0) return 0;
    return _hits / total;
  }

  /// 统计信息
  Map<String, dynamic> get stats => {
        'size': size,
        'maxSize': maxSize,
        'hits': _hits,
        'misses': _misses,
        'hitRate': '${(hitRate * 100).toStringAsFixed(1)}%',
        'evictionPolicy': evictionPolicy.name,
      };
}

/// 翻译缓存
class TranslationCache {
  final MemoryCache<String, String> _cache;

  TranslationCache({
    int maxSize = 500,
    Duration? ttl,
  }) : _cache = MemoryCache(
          maxSize: maxSize,
          defaultTtl: ttl ?? const Duration(hours: 24),
          evictionPolicy: CacheEvictionPolicy.lru,
        );

  /// 生成缓存键
  String _generateKey(String text, String sourceLang, String targetLang) {
    return '${sourceLang}_${targetLang}_${text.hashCode}';
  }

  /// 获取翻译缓存
  String? getTranslation(String text, String sourceLang, String targetLang) {
    final key = _generateKey(text, sourceLang, targetLang);
    return _cache.get(key);
  }

  /// 缓存翻译结果
  void cacheTranslation(
    String sourceText,
    String translatedText,
    String sourceLang,
    String targetLang,
  ) {
    final key = _generateKey(sourceText, sourceLang, targetLang);
    _cache.set(key, translatedText);
  }

  /// 清除特定语言对的缓存
  void clearLanguagePair(String sourceLang, String targetLang) {
    final prefix = '${sourceLang}_${targetLang}_';
    final keysToRemove = _cache._cache.keys
        .where((k) => k.toString().startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  void clear() => _cache.clear();
  Map<String, dynamic> get stats => _cache.stats;
}

/// 词典缓存
class DictionaryCache {
  final MemoryCache<String, Map<String, dynamic>> _wordCache;
  final MemoryCache<String, List<String>> _searchCache;

  DictionaryCache({
    int maxWordEntries = 1000,
    int maxSearchResults = 100,
  })  : _wordCache = MemoryCache(
          maxSize: maxWordEntries,
          defaultTtl: const Duration(hours: 48),
          evictionPolicy: CacheEvictionPolicy.lfu,
        ),
        _searchCache = MemoryCache(
          maxSize: maxSearchResults,
          defaultTtl: const Duration(minutes: 30),
          evictionPolicy: CacheEvictionPolicy.lru,
        );

  /// 获取单词详情缓存
  Map<String, dynamic>? getWord(String word, String language) {
    final key = '${language}_$word';
    return _wordCache.get(key);
  }

  /// 缓存单词详情
  void cacheWord(String word, String language, Map<String, dynamic> data) {
    final key = '${language}_$word';
    _wordCache.set(key, data);
  }

  /// 获取搜索结果缓存
  List<String>? getSearchResults(String query, String language) {
    final key = '${language}_search_$query';
    return _searchCache.get(key);
  }

  /// 缓存搜索结果
  void cacheSearchResults(String query, String language, List<String> results) {
    final key = '${language}_search_$query';
    _searchCache.set(key, results);
  }

  void clear() {
    _wordCache.clear();
    _searchCache.clear();
  }

  Map<String, dynamic> get stats => {
        'wordCache': _wordCache.stats,
        'searchCache': _searchCache.stats,
      };
}

/// 图片缓存管理
class ImageCacheManager {
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxCacheCount = 500;

  /// 配置图片缓存
  static void configure() {
    // Flutter的ImageCache配置
    PaintingBinding.instance.imageCache.maximumSize = maxCacheCount;
    PaintingBinding.instance.imageCache.maximumSizeBytes = maxCacheSize;
  }

  /// 清除图片缓存
  static void clear() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// 获取缓存统计
  static Map<String, dynamic> get stats => {
        'currentSize': PaintingBinding.instance.imageCache.currentSize,
        'currentSizeBytes':
            PaintingBinding.instance.imageCache.currentSizeBytes,
        'maximumSize': PaintingBinding.instance.imageCache.maximumSize,
        'maximumSizeBytes':
            PaintingBinding.instance.imageCache.maximumSizeBytes,
      };
}

/// 缓存管理器Provider
final translationCacheProvider = Provider<TranslationCache>((ref) {
  return TranslationCache();
});

final dictionaryCacheProvider = Provider<DictionaryCache>((ref) {
  return DictionaryCache();
});

/// 全局缓存管理器
class GlobalCacheManager {
  final TranslationCache translationCache;
  final DictionaryCache dictionaryCache;

  GlobalCacheManager({
    required this.translationCache,
    required this.dictionaryCache,
  });

  /// 清除所有缓存
  void clearAll() {
    translationCache.clear();
    dictionaryCache.clear();
    ImageCacheManager.clear();
  }

  /// 获取所有缓存统计
  Map<String, dynamic> get allStats => {
        'translation': translationCache.stats,
        'dictionary': dictionaryCache.stats,
        'image': ImageCacheManager.stats,
      };

  /// 估算缓存内存占用
  int get estimatedMemoryUsage {
    // 粗略估算
    return (translationCache._cache.size * 500) +
        (dictionaryCache._wordCache.size * 2000) +
        (dictionaryCache._searchCache.size * 500) +
        (ImageCacheManager.stats['currentSizeBytes'] as int? ?? 0);
  }
}

final globalCacheManagerProvider = Provider<GlobalCacheManager>((ref) {
  return GlobalCacheManager(
    translationCache: ref.watch(translationCacheProvider),
    dictionaryCache: ref.watch(dictionaryCacheProvider),
  );
});
