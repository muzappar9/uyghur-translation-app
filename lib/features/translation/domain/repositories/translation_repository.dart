import '../../data/models/translation_model.dart';
import '../entities/translation_result.dart';

/// 翻译仓库接口
abstract class TranslationRepository {
  /// 执行翻译
  Future<TranslationResult> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  );

  /// 获取翻译历史
  Future<List<TranslationModel>> getHistory({
    String? userId,
    String? sourceLanguage,
    String? targetLanguage,
    int limit = 50,
  });

  /// 删除翻译历史
  Future<bool> deleteHistory(int id);

  /// 清空翻译历史
  Future<void> clearHistory({String? userId});

  /// 批量翻译
  Future<List<TranslationResult>> translateBatch(
    List<String> texts,
    String sourceLanguage,
    String targetLanguage,
  );

  /// 同步翻译记录
  Future<void> syncTranslations();
}
