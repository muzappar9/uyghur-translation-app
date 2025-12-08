import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../services/database/isar_database_service.dart';
import '../data/models/isar_models/translation_history_model.dart';

/// 翻译历史仓储
///
/// 提供翻译历史的持久化管理：
/// - 保存翻译记录
/// - 查询和搜索历史
/// - 删除和清空历史
/// - 分页和统计
class TranslationHistoryRepository {
  final Logger _logger = Logger();

  /// 保存翻译记录到历史
  ///
  /// 参数：
  /// - [sourceText] 原文
  /// - [translatedText] 译文
  /// - [sourceLanguage] 源语言
  /// - [targetLanguage] 目标语言
  /// - [sourceType] 来源类型（'text', 'voice', 'ocr'）
  ///
  /// 返回保存的记录 ID
  Future<int> saveTranslation({
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required String sourceType,
  }) async {
    try {
      _logger.i(
          '[TranslationHistory] Saving translation: $sourceText → $translatedText');

      final model = TranslationHistoryModel(
        sourceText: sourceText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        sourceType: sourceType,
        timestamp: DateTime.now(),
      );

      final isar = IsarDatabaseService.isar;
      final id = await isar.writeTxn(() async {
        return await isar.translationHistoryModels.put(model);
      });

      _logger.i('[TranslationHistory] ✓ Translation saved with ID: $id');
      return id;
    } catch (e) {
      _logger.e('[TranslationHistory] Error saving translation: $e');
      rethrow;
    }
  }

  /// 获取所有翻译历史
  ///
  /// 参数：
  /// - [limit] 限制数量（默认 100）
  ///
  /// 返回翻译历史列表
  Future<List<TranslationHistoryModel>> getAllTranslations({
    int limit = 100,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final results = await isar.translationHistoryModels
          .where()
          .sortByTimestampDesc()
          .limit(limit)
          .findAll();

      _logger
          .d('[TranslationHistory] Retrieved ${results.length} translations');
      return results;
    } catch (e) {
      _logger.e('[TranslationHistory] Error getting all translations: $e');
      rethrow;
    }
  }

  /// 按源语言和目标语言搜索翻译历史
  ///
  /// 参数：
  /// - [sourceLanguage] 源语言
  /// - [targetLanguage] 目标语言
  /// - [limit] 限制数量
  Future<List<TranslationHistoryModel>> getTranslationsByLanguagePair({
    required String sourceLanguage,
    required String targetLanguage,
    int limit = 100,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      // 因为sourceLanguage和targetLanguage都是索引字段
      // 我们先按sourceLanguage查询，然后在客户端过滤targetLanguage
      final results = await isar.translationHistoryModels
          .where()
          .sourceLanguageEqualTo(sourceLanguage)
          .sortByTimestampDesc()
          .limit(limit)
          .findAll();

      // 在客户端进行targetLanguage过滤
      final filtered =
          results.where((t) => t.targetLanguage == targetLanguage).toList();

      _logger.d(
          '[TranslationHistory] Found ${filtered.length} translations for $sourceLanguage→$targetLanguage');
      return filtered;
    } catch (e) {
      _logger.e('[TranslationHistory] Error searching by language pair: $e');
      rethrow;
    }
  }

  /// 按来源类型搜索（'text', 'voice', 'ocr'）
  ///
  /// 参数：
  /// - [sourceType] 来源类型
  /// - [limit] 限制数量
  Future<List<TranslationHistoryModel>> getTranslationsBySourceType({
    required String sourceType,
    int limit = 100,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final results = await isar.translationHistoryModels
          .where()
          .sourceTypeEqualTo(sourceType)
          .sortByTimestampDesc()
          .limit(limit)
          .build()
          .findAll();

      _logger.d(
          '[TranslationHistory] Found ${results.length} translations of type $sourceType');
      return results;
    } catch (e) {
      _logger.e('[TranslationHistory] Error searching by source type: $e');
      rethrow;
    }
  }

  /// 搜索原文或译文（模糊搜索）
  ///
  /// 参数：
  /// - [query] 搜索关键词
  /// - [limit] 限制数量
  ///
  /// 返回匹配的翻译记录
  Future<List<TranslationHistoryModel>> searchTranslations({
    required String query,
    int limit = 100,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;
      final lowerQuery = query.toLowerCase();

      // Isar 模糊搜索：使用 contains 过滤
      final results = await isar.translationHistoryModels
          .where()
          .sortByTimestampDesc()
          .build()
          .findAll();

      // 在客户端进行过滤（如需要服务器端全文搜索，可后续优化）
      final filtered = results
          .where((t) =>
              t.sourceText.toLowerCase().contains(lowerQuery) ||
              t.translatedText.toLowerCase().contains(lowerQuery))
          .take(limit)
          .toList();

      _logger.d(
          '[TranslationHistory] Found ${filtered.length} translations matching "$query"');
      return filtered;
    } catch (e) {
      _logger.e('[TranslationHistory] Error searching translations: $e');
      rethrow;
    }
  }

  /// 获取翻译历史统计信息
  ///
  /// 返回包含总数、各类型数、各语言对数的统计
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final isar = IsarDatabaseService.isar;

      // 获取全部翻译记录
      final allTranslations = await isar.translationHistoryModels
          .where()
          .sortByTimestampDesc()
          .limit(100000) // 设置一个很大的limit，实际不会用到
          .build()
          .findAll();
      final total = allTranslations.length;

      // 按来源类型统计
      final typeStats = <String, int>{};
      for (final t in allTranslations) {
        typeStats[t.sourceType] = (typeStats[t.sourceType] ?? 0) + 1;
      }

      // 按语言对统计
      final langPairStats = <String, int>{};
      for (final t in allTranslations) {
        final pair = '${t.sourceLanguage}→${t.targetLanguage}';
        langPairStats[pair] = (langPairStats[pair] ?? 0) + 1;
      }

      // 最近的翻译记录
      final recentTranslations = allTranslations
          .map((t) => {
                'sourceText': t.sourceText,
                'translatedText': t.translatedText,
                'timestamp': t.timestamp,
              })
          .toList();

      final stats = {
        'total': total,
        'typeStatistics': typeStats,
        'languagePairStatistics': langPairStats,
        'lastModified':
            allTranslations.isNotEmpty ? allTranslations.first.timestamp : null,
        'recentTranslations': recentTranslations.take(10).toList(),
      };

      _logger.i(
          '[TranslationHistory] Statistics: Total=$total, Types=${typeStats.length}');
      return stats;
    } catch (e) {
      _logger.e('[TranslationHistory] Error getting statistics: $e');
      rethrow;
    }
  }

  /// 删除单条翻译记录
  ///
  /// 参数：
  /// - [id] 记录 ID
  ///
  /// 返回是否删除成功
  Future<bool> deleteTranslation(int id) async {
    try {
      final isar = IsarDatabaseService.isar;

      final success = await isar.writeTxn(() async {
        return await isar.translationHistoryModels.delete(id);
      });

      _logger.i('[TranslationHistory] ✓ Translation deleted: ID=$id');
      return success;
    } catch (e) {
      _logger.e('[TranslationHistory] Error deleting translation: $e');
      rethrow;
    }
  }

  /// 删除所有翻译历史
  ///
  /// 返回删除的记录数
  Future<int> deleteAllTranslations() async {
    try {
      final isar = IsarDatabaseService.isar;

      final count = await isar.writeTxn(() async {
        final allCount = await isar.translationHistoryModels
            .where()
            .sortByTimestampDesc()
            .limit(1000000) // 获取全部记录（实际会删除所有）
            .build()
            .deleteAll();
        return allCount;
      });

      _logger
          .i('[TranslationHistory] ✓ All translations deleted, count=$count');
      return count;
    } catch (e) {
      _logger.e('[TranslationHistory] Error deleting all translations: $e');
      rethrow;
    }
  }

  /// 清空指定时间之前的翻译记录
  ///
  /// 参数：
  /// - [before] 删除该日期之前的记录
  ///
  /// 返回删除的记录数
  Future<int> deleteTranslationsBefore(DateTime before) async {
    try {
      final isar = IsarDatabaseService.isar;

      // 查找要删除的记录（使用filter获取timestamp小于before的记录）
      final toDelete = await isar.translationHistoryModels
          .where()
          .filter()
          .timestampLessThan(before)
          .findAll();

      final count = await isar.writeTxn(() async {
        await isar.translationHistoryModels
            .deleteAll(toDelete.map((t) => t.id).toList());
        return toDelete.length;
      });

      _logger.i(
          '[TranslationHistory] ✓ Deleted $count records before ${before.toIso8601String()}');
      return count;
    } catch (e) {
      _logger.e('[TranslationHistory] Error deleting old translations: $e');
      rethrow;
    }
  }

  /// 获取总数量
  Future<int> getCount() async {
    try {
      final isar = IsarDatabaseService.isar;
      final count = await isar.translationHistoryModels.where().count();
      return count;
    } catch (e) {
      _logger.e('[TranslationHistory] Error getting count: $e');
      rethrow;
    }
  }
}

/// 翻译历史仓储 Provider
final translationHistoryRepositoryProvider =
    Provider<TranslationHistoryRepository>((ref) {
  return TranslationHistoryRepository();
});

/// 翻译历史列表 Provider（异步）
final translationHistoryProvider =
    FutureProvider<List<TranslationHistoryModel>>((ref) async {
  final repo = ref.watch(translationHistoryRepositoryProvider);
  return repo.getAllTranslations(limit: 100);
});

/// 翻译统计信息 Provider（异步）
final translationStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(translationHistoryRepositoryProvider);
  return repo.getStatistics();
});

/// 翻译历史总数 Provider（异步）
final translationHistoryCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(translationHistoryRepositoryProvider);
  return repo.getCount();
});
