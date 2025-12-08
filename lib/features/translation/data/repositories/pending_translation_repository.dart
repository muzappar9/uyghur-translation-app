import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/features/translation/data/models/pending_translation_model.dart';
import 'package:uyghur_translator/shared/providers/isar_provider.dart';

/// 待同步翻译 Repository 接口
abstract class PendingTranslationRepository {
  /// 添加待同步翻译
  Future<void> addPending(
      String sourceText, String sourceLang, String targetLang);

  /// 获取所有待同步翻译
  Future<List<PendingTranslationModel>> getPendingList();

  /// 标记已同步
  Future<void> markSynced(int id);

  /// 删除已同步的翻译
  Future<void> removePending(int id);

  /// 更新重试计数
  Future<void> updateRetryCount(int id, int retryCount, String? errorMessage);

  /// 获取待重试的翻译
  Future<List<PendingTranslationModel>> getRetryableList();

  /// 清空所有待同步翻译
  Future<void> clearAll();
}

/// 待同步翻译 Repository 实现
class PendingTranslationRepositoryImpl implements PendingTranslationRepository {
  final Isar _isar;

  PendingTranslationRepositoryImpl({required Isar isar}) : _isar = isar;

  @override
  Future<void> addPending(
    String sourceText,
    String sourceLang,
    String targetLang,
  ) async {
    final model = PendingTranslationModel()
      ..sourceText = sourceText
      ..sourceLang = sourceLang
      ..targetLang = targetLang
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..isSynced = false;

    await _isar.writeTxn(() => _isar.pendingTranslationModels.put(model));
  }

  @override
  Future<List<PendingTranslationModel>> getPendingList() async {
    return await _isar.pendingTranslationModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();
  }

  @override
  Future<void> markSynced(int id) async {
    final model = await _isar.pendingTranslationModels.get(id);
    if (model != null) {
      model.isSynced = true;
      await _isar.writeTxn(() => _isar.pendingTranslationModels.put(model));
    }
  }

  @override
  Future<void> removePending(int id) async {
    await _isar.writeTxn(() => _isar.pendingTranslationModels.delete(id));
  }

  @override
  Future<void> updateRetryCount(
    int id,
    int retryCount,
    String? errorMessage,
  ) async {
    final model = await _isar.pendingTranslationModels.get(id);
    if (model != null) {
      model.retryCount = retryCount;
      model.lastRetryAt = DateTime.now();
      model.errorMessage = errorMessage;
      await _isar.writeTxn(() => _isar.pendingTranslationModels.put(model));
    }
  }

  @override
  Future<List<PendingTranslationModel>> getRetryableList() async {
    // 获取重试次数 < 5 且未同步的记录
    final all = await _isar.pendingTranslationModels
        .filter()
        .isSyncedEqualTo(false)
        .findAll();

    return all.where((item) => item.retryCount < 5).toList();
  }

  @override
  Future<void> clearAll() async {
    final allIds = await _isar.pendingTranslationModels.where().findAll();
    await _isar.writeTxn(() async {
      for (final model in allIds) {
        await _isar.pendingTranslationModels.delete(model.id);
      }
    });
  }
}

/// 待同步翻译 Repository Provider
final pendingTranslationRepositoryProvider =
    Provider<PendingTranslationRepository>((ref) {
  final isarAsync = ref.watch(isarProvider);

  return isarAsync.maybeWhen(
    data: (isar) => PendingTranslationRepositoryImpl(isar: isar),
    orElse: () => throw Exception('Isar not initialized'),
  );
});
