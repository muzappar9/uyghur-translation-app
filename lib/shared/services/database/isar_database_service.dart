import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../data/models/isar_models/translation_history_model.dart';
import '../../data/models/isar_models/ocr_result_model.dart';
import '../../data/models/isar_models/user_preferences_model.dart';
import '../../data/models/isar_models/pending_sync_model.dart';
import '../../data/models/isar_models/favorite_item_model.dart';
import '../../data/models/isar_models/analytics_event_model.dart';
import '../../../core/exceptions/app_exceptions.dart';

/// Isar 数据库服务 - 按照 Isar 3.1 官方规范实现
class IsarDatabaseService {
  static late Isar _isar;

  /// 初始化数据库
  static Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [
          TranslationHistoryModelSchema,
          OcrResultModelSchema,
          UserPreferencesModelSchema,
          PendingSyncModelSchema,
          FavoriteItemModelSchema,
          AnalyticsEventModelSchema,
        ],
        directory: dir.path,
      );
      appLogger.i('✅ Isar database initialized successfully');
    } catch (e) {
      throw DatabaseException('Failed to initialize Isar database: $e');
    }
  }

  /// 检查数据库是否初始化
  static bool get isInitialized => _isar.isOpen;

  /// 获取数据库实例
  static Isar get isar {
    if (!isInitialized) {
      throw DatabaseException('Database is not initialized');
    }
    return _isar;
  }

  // === 翻译历史操作 ===

  /// 保存翻译历史
  static Future<int> saveTranslationHistory(
    TranslationHistoryModel data,
  ) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.translationHistoryModels.put(data);
      });
    } catch (e) {
      throw DatabaseException('Failed to save translation history: $e');
    }
  }

  /// 批量保存翻译历史
  static Future<void> saveTranslationHistoryBatch(
    List<TranslationHistoryModel> items,
  ) async {
    try {
      await isar.writeTxn(() async {
        await isar.translationHistoryModels.putAll(items);
      });
    } catch (e) {
      throw DatabaseException('Failed to save translation history batch: $e');
    }
  }

  /// 获取所有翻译历史
  static Future<List<TranslationHistoryModel>> getTranslationHistory({
    String? userId,
    int? limit,
  }) async {
    try {
      if (userId != null) {
        return await isar.translationHistoryModels
            .where()
            .filter()
            .userIdEqualTo(userId)
            .sortByTimestampDesc()
            .limit(limit ?? 100)
            .findAll();
      } else {
        return await isar.translationHistoryModels
            .where()
            .sortByTimestampDesc()
            .limit(limit ?? 100)
            .findAll();
      }
    } catch (e) {
      throw DatabaseException('Failed to get translation history: $e');
    }
  }

  /// 获取特定语言对的翻译历史
  static Future<List<TranslationHistoryModel>> getTranslationHistoryByLanguage(
    String sourceLanguage,
    String targetLanguage, {
    String? userId,
  }) async {
    try {
      var query = isar.translationHistoryModels
          .where()
          .filter()
          .sourceLanguageEqualTo(sourceLanguage);

      query = query.and().targetLanguageEqualTo(targetLanguage);

      if (userId != null) {
        query = query.and().userIdEqualTo(userId);
      }

      return await query.sortByTimestampDesc().findAll();
    } catch (e) {
      throw DatabaseException(
        'Failed to get translation history by language: $e',
      );
    }
  }

  /// 删除翻译历史
  static Future<bool> deleteTranslationHistory(int id) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.translationHistoryModels.delete(id);
      });
    } catch (e) {
      throw DatabaseException('Failed to delete translation history: $e');
    }
  }

  /// 清除所有翻译历史
  static Future<int> clearTranslationHistory({String? userId}) async {
    try {
      return await isar.writeTxn(() async {
        if (userId != null) {
          return await isar.translationHistoryModels
              .where()
              .filter()
              .userIdEqualTo(userId)
              .deleteAll();
        }
        return await isar.translationHistoryModels.where().deleteAll();
      });
    } catch (e) {
      throw DatabaseException('Failed to clear translation history: $e');
    }
  }

  // === OCR 结果操作 ===

  /// 保存 OCR 识别结果
  static Future<int> saveOcrResult(OcrResultModel data) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.ocrResultModels.put(data);
      });
    } catch (e) {
      throw DatabaseException('Failed to save OCR result: $e');
    }
  }

  /// 批量保存 OCR 结果
  static Future<void> saveOcrResultBatch(
    List<OcrResultModel> items,
  ) async {
    try {
      await isar.writeTxn(() async {
        await isar.ocrResultModels.putAll(items);
      });
    } catch (e) {
      throw DatabaseException('Failed to save OCR result batch: $e');
    }
  }

  /// 获取所有 OCR 结果
  static Future<List<OcrResultModel>> getOcrResults({
    String? userId,
    int? limit,
  }) async {
    try {
      if (userId != null) {
        return await isar.ocrResultModels
            .where()
            .filter()
            .userIdEqualTo(userId)
            .sortByCreatedAtDesc()
            .limit(limit ?? 50)
            .findAll();
      } else {
        return await isar.ocrResultModels
            .where()
            .sortByCreatedAtDesc()
            .limit(limit ?? 50)
            .findAll();
      }
    } catch (e) {
      throw DatabaseException('Failed to get OCR results: $e');
    }
  }

  /// 获取收藏的 OCR 结果
  static Future<List<OcrResultModel>> getFavoriteOcrResults({
    String? userId,
  }) async {
    try {
      var query = isar.ocrResultModels.where().filter().isFavoriteEqualTo(true);

      if (userId != null) {
        query = query.and().userIdEqualTo(userId);
      }

      return await query.sortByCreatedAtDesc().findAll();
    } catch (e) {
      throw DatabaseException('Failed to get favorite OCR results: $e');
    }
  }

  /// 删除 OCR 结果
  static Future<bool> deleteOcrResult(int id) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.ocrResultModels.delete(id);
      });
    } catch (e) {
      throw DatabaseException('Failed to delete OCR result: $e');
    }
  }

  /// 清除所有 OCR 结果
  static Future<int> clearOcrResults({String? userId}) async {
    try {
      return await isar.writeTxn(() async {
        if (userId != null) {
          return await isar.ocrResultModels
              .where()
              .filter()
              .userIdEqualTo(userId)
              .deleteAll();
        }
        return await isar.ocrResultModels.where().deleteAll();
      });
    } catch (e) {
      throw DatabaseException('Failed to clear OCR results: $e');
    }
  }

  // === 用户偏好操作 ===

  /// 保存用户偏好
  static Future<int> saveUserPreferences(UserPreferencesModel data) async {
    try {
      return await isar.writeTxn(() async {
        return await isar.userPreferencesModels.put(data);
      });
    } catch (e) {
      throw DatabaseException('Failed to save user preferences: $e');
    }
  }

  /// 获取用户偏好
  static Future<UserPreferencesModel?> getUserPreferences(String userId) async {
    try {
      return await isar.userPreferencesModels
          .where()
          .filter()
          .userIdEqualTo(userId)
          .findFirst();
    } catch (e) {
      throw DatabaseException('Failed to get user preferences: $e');
    }
  }

  /// 更新用户偏好
  static Future<int> updateUserPreferences(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final existing = await getUserPreferences(userId);
      if (existing == null) {
        throw ResourceNotFoundException(
            'User preferences not found for $userId');
      }

      // 更新字段
      if (updates.containsKey('sourceLanguage')) {
        existing.sourceLanguage = updates['sourceLanguage'];
      }
      if (updates.containsKey('targetLanguage')) {
        existing.targetLanguage = updates['targetLanguage'];
      }
      if (updates.containsKey('darkMode')) {
        existing.darkMode = updates['darkMode'];
      }
      if (updates.containsKey('fontSize')) {
        existing.fontSize = updates['fontSize'];
      }
      if (updates.containsKey('enableNotifications')) {
        existing.enableNotifications = updates['enableNotifications'];
      }
      if (updates.containsKey('enableOfflineMode')) {
        existing.enableOfflineMode = updates['enableOfflineMode'];
      }

      existing.lastUpdated = DateTime.now();

      return await saveUserPreferences(existing);
    } catch (e) {
      throw DatabaseException('Failed to update user preferences: $e');
    }
  }

  /// 删除用户偏好
  static Future<bool> deleteUserPreferences(String userId) async {
    try {
      return await isar.writeTxn(() async {
        final prefs = await isar.userPreferencesModels
            .where()
            .filter()
            .userIdEqualTo(userId)
            .findFirst();
        if (prefs != null) {
          return await isar.userPreferencesModels.delete(prefs.id);
        }
        return false;
      });
    } catch (e) {
      throw DatabaseException('Failed to delete user preferences: $e');
    }
  }

  // === 数据库维护 ===

  /// 获取数据库统计信息
  static Future<Map<String, int>> getStatistics() async {
    try {
      return {
        'translationHistory':
            await isar.translationHistoryModels.where().count(),
        'ocrResults': await isar.ocrResultModels.where().count(),
        'userPreferences': await isar.userPreferencesModels.where().count(),
      };
    } catch (e) {
      throw DatabaseException('Failed to get database statistics: $e');
    }
  }

  /// 清除所有数据
  static Future<void> clearAllData() async {
    try {
      await isar.writeTxn(() async {
        await isar.translationHistoryModels.where().deleteAll();
        await isar.ocrResultModels.where().deleteAll();
        await isar.userPreferencesModels.where().deleteAll();
      });
      appLogger.i('✅ All data cleared successfully');
    } catch (e) {
      throw DatabaseException('Failed to clear all data: $e');
    }
  }

  /// 关闭数据库
  static Future<void> close() async {
    try {
      await _isar.close();
      appLogger.i('✅ Isar database closed');
    } catch (e) {
      appLogger.e('❌ Error closing database: $e');
    }
  }
}
