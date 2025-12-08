import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/features/translation/data/models/pending_translation_model.dart';
import 'package:uyghur_translator/features/translation/data/repositories/pending_translation_repository.dart';

/// 待同步翻译列表 Notifier
class PendingTranslationListNotifier
    extends AsyncNotifier<List<PendingTranslationModel>> {
  @override
  Future<List<PendingTranslationModel>> build() async {
    final repo = ref.watch(pendingTranslationRepositoryProvider);
    return await repo.getPendingList();
  }

  /// 刷新待同步列表
  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.watch(pendingTranslationRepositoryProvider);
    state = await AsyncValue.guard(() => repo.getPendingList());
  }
}

/// 待同步翻译列表 Provider
final pendingTranslationListProvider = AsyncNotifierProvider<
    PendingTranslationListNotifier,
    List<PendingTranslationModel>>(PendingTranslationListNotifier.new);
