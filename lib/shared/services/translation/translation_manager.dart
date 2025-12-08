import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'translation_engine.dart';

/// 翻译管理器 - 协调多个翻译引擎
///
/// 特性:
/// - 支持多个翻译引擎 (本地、远程、混合)
/// - 自动故障转移 (一个引擎失败，尝试下一个)
/// - 按优先级选择引擎
/// - 翻译结果缓存
class TranslationManager {
  final List<TranslationEngine> engines;
  final Logger _logger = Logger();

  // 简单的内存缓存 (生产环境由 Repository 处理)
  final Map<String, String> _cache = {};

  TranslationManager({
    required this.engines,
  }) {
    // 按优先级排序 (高优先级在前)
    engines.sort((a, b) => b.priority.compareTo(a.priority));
    _logger.i(
        'Translation engines initialized: ${engines.map((e) => e.name).join(", ")}');
  }

  /// 翻译文本
  ///
  /// 流程:
  /// 1. 检查缓存
  /// 2. 按优先级遍历引擎
  /// 3. 使用第一个可用的引擎进行翻译
  /// 4. 如果引擎失败，自动尝试下一个 (故障转移)
  /// 5. 缓存结果并返回
  ///
  /// 抛出 TranslationFailedException 如果所有引擎都失败
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    // 检查输入
    if (text.isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }

    // 生成缓存键
    final cacheKey = _generateCacheKey(text, sourceLang, targetLang);

    // 检查缓存
    if (_cache.containsKey(cacheKey)) {
      _logger.d('Cache hit for: $cacheKey');
      return _cache[cacheKey]!;
    }

    // 按优先级尝试每个引擎
    for (final engine in engines) {
      try {
        // 检查引擎是否可用
        final available = await engine.isAvailable();
        if (!available) {
          _logger.w('Engine ${engine.name} is not available');
          continue;
        }

        _logger.i('Using engine: ${engine.name}');
        final result = await engine.translate(text, sourceLang, targetLang);

        // 缓存结果
        _cache[cacheKey] = result;
        _logger.i(
            'Translation successful: "$text" ($sourceLang→$targetLang) = "$result"');

        return result;
      } catch (e) {
        _logger.e('Engine ${engine.name} failed: $e');
        // 继续尝试下一个引擎
        continue;
      }
    }

    // 所有引擎都失败了
    throw TranslationFailedException(
      'All translation engines failed for: "$text" ($sourceLang→$targetLang)',
    );
  }

  /// 清空缓存
  void clearCache() {
    _cache.clear();
    _logger.i('Translation cache cleared');
  }

  /// 生成缓存键
  String _generateCacheKey(String text, String sourceLang, String targetLang) {
    return '${text.toLowerCase().trim()}_${sourceLang}_$targetLang';
  }

  /// 获取当前可用的引擎列表
  Future<List<TranslationEngine>> getAvailableEngines() async {
    final available = <TranslationEngine>[];

    for (final engine in engines) {
      if (await engine.isAvailable()) {
        available.add(engine);
      }
    }

    return available;
  }

  /// 获取主引擎（最高优先级的可用引擎）
  Future<TranslationEngine?> getPrimaryEngine() async {
    for (final engine in engines) {
      if (await engine.isAvailable()) {
        return engine;
      }
    }
    return null;
  }

  /// 添加新的翻译引擎（动态添加）
  void addEngine(TranslationEngine engine) {
    engines.add(engine);
    // 重新排序
    engines.sort((a, b) => b.priority.compareTo(a.priority));
    _logger.i('Engine added: ${engine.name}');
  }

  /// 移除翻译引擎
  bool removeEngine(TranslationEngine engine) {
    final removed = engines.remove(engine);
    if (removed) {
      _logger.i('Engine removed: ${engine.name}');
    }
    return removed;
  }
}

/// 翻译失败异常
class TranslationFailedException implements Exception {
  final String message;

  TranslationFailedException(this.message);

  @override
  String toString() => message;
}

/// 翻译管理器 Provider
final translationManagerProvider = Provider<TranslationManager>((ref) {
  return TranslationManager(
    engines: [
      // 注册翻译引擎 (可按需扩展)
      LocalMockTranslationEngine(),
      // 未来可添加:
      // - RemoteApiTranslationEngine (与后端通信)
      // - TencentTranslationEngine (腾讯云 API)
      // - LocalMLTranslationEngine (本地ML模型)
      // 等等...
    ],
  );
});
