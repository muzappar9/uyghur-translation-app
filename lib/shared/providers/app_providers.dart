import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/features/translation/domain/entities/translation.dart';
import 'package:uyghur_translator/features/translation/data/repositories/translation_repository.dart';
import 'package:uyghur_translator/shared/services/translation_service.dart';

// ==================== 应用全局状态 ====================

/// 应用状态 Notifier
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return const AppState(
      currentLanguage: 'zh',
      sourceLanguage: 'en',
      targetLanguage: 'zh',
      isDarkMode: false,
      isInitialized: false,
    );
  }

  /// 设置当前界面语言
  void setLanguage(String language) {
    state = state.copyWith(currentLanguage: language);
  }

  /// 设置翻译源语言
  void setSourceLanguage(String language) {
    state = state.copyWith(sourceLanguage: language);
  }

  /// 设置翻译目标语言
  void setTargetLanguage(String language) {
    state = state.copyWith(targetLanguage: language);
  }

  /// 交换源语言和目标语言
  void swapLanguages() {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
    );
  }

  /// 设置深色模式
  void setDarkMode(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
  }

  /// 标记应用已初始化
  void markInitialized() {
    state = state.copyWith(isInitialized: true);
  }

  /// 设置在线状态
  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }
}

/// 全局应用状态 Provider
final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

// ==================== 翻译历史 ====================

/// 翻译历史 Notifier
class TranslationHistoryNotifier extends AsyncNotifier<List<Translation>> {
  @override
  Future<List<Translation>> build() async {
    return ref.watch(translationRepositoryProvider).getHistory();
  }

  /// 添加翻译到历史
  Future<void> addTranslation(Translation translation) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.watch(translationRepositoryProvider).addToFavorites(translation);

      // 刷新历史
      return ref.watch(translationRepositoryProvider).getHistory();
    });
  }

  /// 刷新历史记录
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.watch(translationRepositoryProvider).getHistory();
    });
  }
}

/// 翻译历史 Provider
final translationHistoryProvider = AsyncNotifierProvider<
    TranslationHistoryNotifier,
    List<Translation>>(TranslationHistoryNotifier.new);

// ==================== 当前翻译操作 ====================

/// 当前翻译 Notifier
class CurrentTranslationNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  /// 执行翻译
  Future<void> translate(String text, String sourceLang, String targetLang) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // 使用 TranslationService 处理离线和重试逻辑
      final service = ref.watch(translationServiceProvider);
      return await service.translate(text, sourceLang, targetLang);
    });
  }

  /// 重置翻译结果
  void reset() => state = const AsyncData(null);
}

/// 当前翻译 Provider
final currentTranslationProvider = AsyncNotifierProvider<
    CurrentTranslationNotifier,
    String?>(CurrentTranslationNotifier.new);
