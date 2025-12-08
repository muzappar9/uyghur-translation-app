/// Stage 21: 缓存系统单元测试
///
/// 测试内存缓存和持久化缓存的核心功能
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/core/cache/memory_cache.dart';

void main() {
  group('MemoryCache 单元测试', () {
    late MemoryCache<String, String> cache;

    setUp(() {
      cache = MemoryCache<String, String>(
        maxSize: 5,
        evictionPolicy: CacheEvictionPolicy.lru,
      );
    });

    test('应该能够存储和获取值', () {
      cache.set('key1', 'value1');
      expect(cache.get('key1'), equals('value1'));
    });

    test('不存在的键应返回 null', () {
      expect(cache.get('nonexistent'), isNull);
    });

    test('应该正确追踪缓存大小', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      expect(cache.size, equals(2));
    });

    test('超出最大容量时应淘汰旧条目 (LRU)', () {
      // 填满缓存
      for (int i = 0; i < 5; i++) {
        cache.set('key$i', 'value$i');
      }
      expect(cache.size, equals(5));

      // 添加新条目，应该淘汰 key0
      cache.set('key5', 'value5');
      expect(cache.size, equals(5));
      expect(cache.get('key0'), isNull); // 最老的应该被淘汰
      expect(cache.get('key5'), equals('value5'));
    });

    test('访问条目应更新 LRU 顺序', () {
      for (int i = 0; i < 5; i++) {
        cache.set('key$i', 'value$i');
      }

      // 访问 key0，使其成为最近使用的
      cache.get('key0');

      // 添加新条目，应该淘汰 key1 而不是 key0
      cache.set('key5', 'value5');
      expect(cache.get('key0'), equals('value0')); // key0 应该还在
      expect(cache.get('key1'), isNull); // key1 应该被淘汰
    });

    test('clear 应清空所有条目', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.clear();
      expect(cache.size, equals(0));
      expect(cache.get('key1'), isNull);
    });

    test('remove 应删除特定条目', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.remove('key1');
      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), equals('value2'));
    });

    test('containsKey 应正确返回', () {
      cache.set('key1', 'value1');
      expect(cache.containsKey('key1'), isTrue);
      expect(cache.containsKey('nonexistent'), isFalse);
    });

    test('应正确计算命中率', () {
      cache.set('key1', 'value1');

      // 1 次命中
      cache.get('key1');
      // 1 次未命中
      cache.get('nonexistent');

      expect(cache.hitRate, equals(0.5)); // 50% 命中率
    });

    test('stats 应返回正确的统计信息', () {
      cache.set('key1', 'value1');
      cache.get('key1'); // hit
      cache.get('key2'); // miss

      final stats = cache.stats;
      expect(stats['size'], equals(1));
      expect(stats['hits'], equals(1));
      expect(stats['misses'], equals(1));
    });
  });

  group('TranslationCache 单元测试', () {
    late TranslationCache translationCache;

    setUp(() {
      translationCache = TranslationCache(maxSize: 100);
    });

    test('应该缓存翻译结果', () {
      translationCache.cacheTranslation(
        'Hello',
        'ياخشىمۇسىز',
        'en',
        'ug',
      );

      final result = translationCache.getTranslation('Hello', 'en', 'ug');
      expect(result, equals('ياخشىمۇسىز'));
    });

    test('不同语言对应该分开缓存', () {
      translationCache.cacheTranslation('Hello', 'ياخشىمۇسىز', 'en', 'ug');
      translationCache.cacheTranslation('Hello', '你好', 'en', 'zh');

      expect(translationCache.getTranslation('Hello', 'en', 'ug'),
          equals('ياخشىمۇسىز'));
      expect(
          translationCache.getTranslation('Hello', 'en', 'zh'), equals('你好'));
    });

    test('不存在的翻译应返回 null', () {
      expect(translationCache.getTranslation('NonexistentText', 'en', 'ug'),
          isNull);
    });

    test('clear 应清空翻译缓存', () {
      translationCache.cacheTranslation('Hello', '你好', 'en', 'zh');
      translationCache.clear();
      expect(translationCache.getTranslation('Hello', 'en', 'zh'), isNull);
    });

    test('stats 应返回统计信息', () {
      translationCache.cacheTranslation('Hello', '你好', 'en', 'zh');
      final stats = translationCache.stats;
      expect(stats['size'], equals(1));
    });
  });

  group('DictionaryCache 单元测试', () {
    late DictionaryCache dictionaryCache;

    setUp(() {
      dictionaryCache = DictionaryCache();
    });

    test('应该缓存单词详情', () {
      final wordData = {
        'word': 'test',
        'definition': 'a trial',
        'examples': ['This is a test'],
      };

      dictionaryCache.cacheWord('test', 'en', wordData);

      final result = dictionaryCache.getWord('test', 'en');
      expect(result, equals(wordData));
    });

    test('应该缓存搜索结果', () {
      final searchResults = ['test', 'testing', 'tester'];
      dictionaryCache.cacheSearchResults('test', 'en', searchResults);

      final result = dictionaryCache.getSearchResults('test', 'en');
      expect(result, equals(searchResults));
    });

    test('不同语言的单词应分开缓存', () {
      final enData = {'word': 'test', 'lang': 'en'};
      final ugData = {'word': 'سىناق', 'lang': 'ug'};

      dictionaryCache.cacheWord('test', 'en', enData);
      dictionaryCache.cacheWord('test', 'ug', ugData);

      expect(dictionaryCache.getWord('test', 'en'), equals(enData));
      expect(dictionaryCache.getWord('test', 'ug'), equals(ugData));
    });
  });

  group('CacheEvictionPolicy 测试', () {
    test('FIFO 策略应按插入顺序淘汰', () {
      final cache = MemoryCache<String, String>(
        maxSize: 3,
        evictionPolicy: CacheEvictionPolicy.fifo,
      );

      cache.set('first', 'value1');
      cache.set('second', 'value2');
      cache.set('third', 'value3');

      // 访问 first 不应改变 FIFO 顺序
      cache.get('first');

      // 添加新条目
      cache.set('fourth', 'value4');

      // first 应该被淘汰（先进先出）
      expect(cache.get('first'), isNull);
      expect(cache.get('second'), isNotNull);
    });

    test('LFU 策略应淘汰最少使用的条目', () {
      final cache = MemoryCache<String, String>(
        maxSize: 3,
        evictionPolicy: CacheEvictionPolicy.lfu,
      );

      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');

      // 多次访问 key1 和 key2
      cache.get('key1');
      cache.get('key1');
      cache.get('key2');

      // 添加新条目，key3 应该被淘汰（使用频率最低）
      cache.set('key4', 'value4');

      expect(cache.get('key3'), isNull);
      expect(cache.get('key1'), isNotNull);
      expect(cache.get('key2'), isNotNull);
    });
  });

  group('TTL (Time To Live) 测试', () {
    test('过期条目应返回 null', () async {
      final cache = MemoryCache<String, String>(
        maxSize: 10,
        defaultTtl: const Duration(milliseconds: 50),
      );

      cache.set('key1', 'value1');

      // 等待过期
      await Future.delayed(const Duration(milliseconds: 100));

      expect(cache.get('key1'), isNull);
    });

    test('未过期条目应正常返回', () async {
      final cache = MemoryCache<String, String>(
        maxSize: 10,
        defaultTtl: const Duration(seconds: 10),
      );

      cache.set('key1', 'value1');

      // 不等待
      expect(cache.get('key1'), equals('value1'));
    });
  });
}
