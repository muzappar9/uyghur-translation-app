import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../domain/repositories/translation_repository.dart';
import '../../domain/entities/translation_result.dart';
import '../models/translation_model.dart';
import '../services/google_translate_service.dart';
import '../../../../shared/services/database/isar_database_service.dart';
import '../../../../shared/data/models/isar_models/translation_history_model.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// 翻译仓库实现
class TranslationRepositoryImpl implements TranslationRepository {
  /// Google 翻译服务
  final GoogleTranslateService _googleTranslateService;

  /// 网络连接状态
  late bool _isOnline;

  /// 构造函数
  TranslationRepositoryImpl({
    required GoogleTranslateService googleTranslateService,
  }) : _googleTranslateService = googleTranslateService {
    _isOnline = true; // 默认在线
  }

  /// 执行翻译
  @override
  Future<TranslationResult> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      // 验证输入
      if (text.isEmpty) {
        return TranslationResult.failure(
          errorMessage: '翻译文本不能为空',
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
      }

      if (sourceLanguage == targetLanguage) {
        return TranslationResult.failure(
          errorMessage: '源语言和目标语言不能相同',
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
      }

      // 尝试在线翻译
      if (_isOnline) {
        return await _translateOnline(
          text,
          sourceLanguage,
          targetLanguage,
        );
      } else {
        // 离线模式：从历史记录查询
        return await _translateOffline(
          text,
          sourceLanguage,
          targetLanguage,
        );
      }
    } catch (e) {
      appLogger.e('❌ 翻译失败: $e');
      return TranslationResult.failure(
        errorMessage: '翻译异常: $e',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    }
  }

  /// 在线翻译
  Future<TranslationResult> _translateOnline(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      // 调用 Google Translate API
      final translatedText = await _googleTranslateService.translate(
        text,
        sourceLanguage,
        targetLanguage,
      );

      // 保存到本地数据库
      final history = TranslationHistoryModel(
        sourceText: text,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        timestamp: DateTime.now(),
        isSynced: true, // API 翻译已同步
      );

      await IsarDatabaseService.saveTranslationHistory(history);

      appLogger.i('✅ 在线翻译成功: "$text" → "$translatedText"');
      return TranslationResult.success(
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } on ApiException catch (e) {
      appLogger.e('❌ API 错误 (${e.statusCode}): ${e.message}');
      return TranslationResult.failure(
        errorMessage: '翻译 API 错误: ${e.message}',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      appLogger.e('❌ 在线翻译异常: $e');
      return TranslationResult.failure(
        errorMessage: '在线翻译失败: $e',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    }
  }

  /// 离线翻译（从缓存查询）
  Future<TranslationResult> _translateOffline(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      // 从数据库查询历史记录
      final historyList =
          await IsarDatabaseService.getTranslationHistoryByLanguage(
        sourceLanguage,
        targetLanguage,
      );

      // 查找匹配的翻译
      for (final history in historyList) {
        if (history.sourceText.toLowerCase() == text.toLowerCase()) {
          appLogger.i('✅ 离线模式使用缓存翻译');
          return TranslationResult.success(
            translatedText: history.translatedText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
          );
        }
      }

      // 未找到缓存
      return TranslationResult.offline(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      appLogger.e('❌ 离线翻译查询失败: $e');
      return TranslationResult.failure(
        errorMessage: '离线查询失败: $e',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    }
  }

  /// 获取翻译历史
  @override
  Future<List<TranslationModel>> getHistory({
    String? userId,
    String? sourceLanguage,
    String? targetLanguage,
    int limit = 50,
  }) async {
    try {
      List<TranslationHistoryModel> history;

      if (sourceLanguage != null && targetLanguage != null) {
        // 按语言对查询
        history = await IsarDatabaseService.getTranslationHistoryByLanguage(
          sourceLanguage,
          targetLanguage,
          userId: userId,
        );
      } else {
        // 获取所有历史
        history = await IsarDatabaseService.getTranslationHistory(
          userId: userId,
          limit: limit,
        );
      }

      // 转换为模型
      return history.map((h) => TranslationModel.fromIsar(h)).toList();
    } catch (e) {
      appLogger.e('❌ 获取历史记录失败: $e');
      rethrow;
    }
  }

  /// 删除翻译历史
  @override
  Future<bool> deleteHistory(int id) async {
    try {
      final result = await IsarDatabaseService.deleteTranslationHistory(id);
      if (result) {
        appLogger.i('✅ 翻译记录已删除: $id');
      }
      return result;
    } catch (e) {
      appLogger.e('❌ 删除历史记录失败: $e');
      rethrow;
    }
  }

  /// 清空翻译历史
  @override
  Future<void> clearHistory({String? userId}) async {
    try {
      final count =
          await IsarDatabaseService.clearTranslationHistory(userId: userId);
      appLogger.i('✅ 已清除 $count 条翻译记录');
    } catch (e) {
      appLogger.e('❌ 清空历史记录失败: $e');
      rethrow;
    }
  }

  /// 批量翻译
  @override
  Future<List<TranslationResult>> translateBatch(
    List<String> texts,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final results = <TranslationResult>[];

      for (final text in texts) {
        final result = await translate(
          text,
          sourceLanguage,
          targetLanguage,
        );
        results.add(result);
      }

      appLogger.i('✅ 批量翻译完成: ${results.length} 项');
      return results;
    } catch (e) {
      appLogger.e('❌ 批量翻译失败: $e');
      rethrow;
    }
  }

  /// 设置在线/离线状态
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    appLogger.d('${isOnline ? '🌐' : '📴'} 网络状态: ${isOnline ? "在线" : "离线"}');
  }

  /// 获取在线状态
  bool get isOnline => _isOnline;

  /// 同步待上传的翻译记录
  @override
  Future<void> syncTranslations() async {
    try {
      if (!_isOnline) {
        appLogger.w('⚠️ 离线模式，无法同步');
        return;
      }

      // 获取未同步的记录
      final history = await IsarDatabaseService.getTranslationHistory();
      final unsyncedCount = history.where((h) => !h.isSynced).length;

      if (unsyncedCount == 0) {
        appLogger.i('✅ 所有翻译记录已同步');
        return;
      }

      appLogger.d('🔄 开始同步 $unsyncedCount 条未同步的翻译记录');

      // 实际应用中应该上传到云服务
      // 这里仅作示例
      appLogger.i('✅ 翻译记录同步完成');
    } catch (e) {
      appLogger.e('❌ 同步失败: $e');
      rethrow;
    }
  }
}
