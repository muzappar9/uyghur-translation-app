import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/features/translation/domain/entities/translation.dart';
import 'package:uyghur_translator/features/translation/data/models/translation_isar_model.dart';
import 'package:uyghur_translator/shared/providers/isar_provider.dart';
import 'package:uyghur_translator/shared/services/api/api_client.dart';

/// 翻译 Repository 接口
abstract class TranslationRepository {
  /// 翻译文本（优先从缓存查询，缓存无命中则调用 API）
  Future<String> translate(String text, String sourceLang, String targetLang);

  /// 从缓存查询翻译结果（如果存在）
  Future<String?> getFromCache(String text, String sourceLang, String targetLang);

  /// 获取翻译历史
  Future<List<Translation>> getHistory({int limit = 100});

  /// 添加到收藏
  Future<void> addToFavorites(Translation translation);

  /// 从收藏移除
  Future<void> removeFromFavorites(String translationId);

  /// 监听历史记录变化
  Stream<List<Translation>> watchHistory();
}

/// 翻译 Repository 实现
class TranslationRepositoryImpl implements TranslationRepository {
  final Isar _isar;
  final ApiClient _apiClient;

  TranslationRepositoryImpl({
    required Isar isar,
    required ApiClient apiClient,
  })  : _isar = isar,
        _apiClient = apiClient;

  @override
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    // 先从缓存查询
    final cached = await getFromCache(text, sourceLang, targetLang);
    if (cached != null) {
      return cached;
    }

    // 缓存未命中，调用 API
    final result = await _apiClient.translate(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    // 保存到历史记录和缓存
    final model = TranslationIsarModel()
      ..sourceText = text
      ..targetText = result
      ..sourceLang = sourceLang
      ..targetLang = targetLang
      ..timestamp = DateTime.now()
      ..isFavorite = false
      ..searchTokens = _generateSearchTokens(text);

    await _isar.writeTxn(() => _isar.translationIsarModels.put(model));

    return result;
  }

  @override
  Future<String?> getFromCache(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      // 使用where查询所有满足条件的记录
      final results = await _isar.translationIsarModels
          .where()
          .findAll();

      // 手动过滤匹配的翻译
      final normalizedText = text.trim().toLowerCase();
      for (final result in results) {
        if (result.sourceText.trim().toLowerCase() == normalizedText &&
            result.sourceLang == sourceLang &&
            result.targetLang == targetLang) {
          return result.targetText;
        }
      }

      return null;
    } catch (e) {
      // 缓存查询失败，返回 null 以继续使用 API
      return null;
    }
  }

  @override
  Future<List<Translation>> getHistory({int limit = 100}) async {
    final results = await _isar.translationIsarModels
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();

    return results.map(_modelToEntity).toList();
  }

  @override
  Future<void> addToFavorites(Translation translation) async {
    final model = _entityToModel(translation);
    model.isFavorite = true;
    await _isar.writeTxn(() => _isar.translationIsarModels.put(model));
  }

  @override
  Future<void> removeFromFavorites(String translationId) async {
    final id = int.tryParse(translationId);
    if (id != null) {
      await _isar.writeTxn(() => _isar.translationIsarModels.delete(id));
    }
  }

  @override
  Stream<List<Translation>> watchHistory() {
    return _isar.translationIsarModels
        .where()
        .watch()
        .map((models) => models.map(_modelToEntity).toList());
  }

  /// 转换：Model -> Entity
  Translation _modelToEntity(TranslationIsarModel model) {
    return Translation(
      id: model.id.toString(),
      sourceText: model.sourceText,
      targetText: model.targetText,
      sourceLang: model.sourceLang,
      targetLang: model.targetLang,
      timestamp: model.timestamp,
      isFavorite: model.isFavorite,
      notes: model.notes,
    );
  }

  /// 转换：Entity -> Model
  TranslationIsarModel _entityToModel(Translation entity) {
    return TranslationIsarModel()
      ..sourceText = entity.sourceText
      ..targetText = entity.targetText
      ..sourceLang = entity.sourceLang
      ..targetLang = entity.targetLang
      ..timestamp = entity.timestamp
      ..isFavorite = entity.isFavorite
      ..notes = entity.notes
      ..searchTokens = _generateSearchTokens(entity.sourceText);
  }

  /// 生成搜索令牌
  List<String> _generateSearchTokens(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[\s\p{P}]+', unicode: true))
        .where((token) => token.isNotEmpty)
        .toList();
  }
}

/// Repository Provider
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);

  return isarAsync.maybeWhen(
    data: (isar) {
      final apiClient = ref.watch(apiClientProvider);
      return TranslationRepositoryImpl(
        isar: isar,
        apiClient: apiClient,
      );
    },
    orElse: () => throw Exception('Isar not initialized'),
  );
});
