import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uyghur_translator/shared/services/translation/translation_engine.dart';
import 'package:uyghur_translator/shared/services/translation/translation_manager.dart';
import 'package:uyghur_translator/core/config/api_keys.dart';
import 'package:uyghur_translator/core/api/translation_api_factory.dart';
import 'package:uyghur_translator/core/api/translation_api_interface.dart';
import 'package:uyghur_translator/core/i18n/language_config.dart';
import 'package:logger/logger.dart';

part 'translation_provider.freezed.dart';

/// 翻译状态
@freezed
class TranslationState with _$TranslationState {
  const factory TranslationState({
    @Default('') String sourceText,
    @Default('') String targetText,
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default('en') String sourceLanguage,
    @Default('zh') String targetLanguage,
    @Default(false) bool isFavorite,
  }) = _TranslationState;
}

/// 翻译 StateNotifier
class TranslationNotifier extends StateNotifier<TranslationState> {
  final TranslationManager _translationManager;
  final Logger _logger = Logger();

  TranslationNotifier(this._translationManager)
      : super(const TranslationState());

  /// 执行翻译
  Future<void> translate(String text) async {
    if (text.isEmpty) {
      state = state.copyWith(
        sourceText: text,
        targetText: '',
        error: null,
      );
      return;
    }

    state = state.copyWith(
      sourceText: text,
      isLoading: true,
      error: null,
    );

    try {
      final result = await _translationManager.translate(
        text,
        state.sourceLanguage,
        state.targetLanguage,
      );

      state = state.copyWith(
        sourceText: text,
        targetText: result,
        isLoading: false,
        error: null,
      );

      _logger.i('Translation successful: "$text" → "$result"');
    } catch (e) {
      final errorMsg = 'Translation failed: $e';
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
      );
      _logger.e(errorMsg);
    }
  }

  /// 设置源语言
  void setSourceLanguage(String language) {
    state = state.copyWith(sourceLanguage: language);
    // 如果已有翻译，自动重新翻译
    if (state.sourceText.isNotEmpty) {
      translate(state.sourceText);
    }
  }

  /// 设置目标语言
  void setTargetLanguage(String language) {
    state = state.copyWith(targetLanguage: language);
    // 如果已有翻译，自动重新翻译
    if (state.sourceText.isNotEmpty) {
      translate(state.sourceText);
    }
  }

  /// 交换源语言和目标语言
  void swapLanguages() {
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: state.sourceLanguage,
      sourceText: state.targetText,
      targetText: state.sourceText,
    );
  }

  /// 清除翻译
  void clearTranslation() {
    state = const TranslationState(
      sourceLanguage: 'en',
      targetLanguage: 'zh',
    );
  }

  /// 切换收藏状态
  void toggleFavorite() {
    state = state.copyWith(isFavorite: !state.isFavorite);
  }
}

/// 翻译 Manager Provider
final translationManagerProvider = Provider<TranslationManager>((ref) {
  final engines = <TranslationEngine>[];

  // 尝试使用 DeepSeek API（如果配置了 API Key）
  if (ApiKeys.hasDeepSeekApiKey()) {
    try {
      final deepSeekApi = TranslationApiFactory.create(
        provider: TranslationApiProvider.deepSeek,
        config: TranslationApiConfig(
          providerId: 'deepseek',
          apiKey: ApiKeys.getDeepSeekApiKey(),
          apiEndpoint: ApiKeys.getDeepSeekApiEndpoint(),
          model: ApiKeys.getDeepSeekModel(),
        ),
      );
      engines.add(ApiTranslationEngine(
        api: deepSeekApi,
        name: 'DeepSeek Translation',
        priority: 10,
      ));
    } catch (e) {
      Logger().w('Failed to initialize DeepSeek API: $e');
    }
  }

  // 始终添加本地 Mock 引擎作为后备
  engines.add(LocalMockTranslationEngine());

  return TranslationManager(engines: engines);
});

/// 翻译状态 Provider (StateNotifier)
final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  final manager = ref.watch(translationManagerProvider);
  return TranslationNotifier(manager);
});

/// 翻译历史 Provider (从内存读取示例数据)
final translationHistoryProvider = FutureProvider<List<String>>((ref) async {
  // 返回示例历史数据（实际应该从数据库读取）
  await Future.delayed(const Duration(milliseconds: 200));
  return [
    '你好 → سالام',
    '谢谢 → رەھمەت',
    '早上好 → خەيرلىك تاڭ',
    '再见 → خەير خوش',
    '我爱你 → مەن سىزنى ياخشى كۆرىمەن',
  ];
});

/// 支持的语言对 Provider
/// 基于 Hunyuan-MT-7B 模型支持的 36 种语言互译
final supportedLanguagePairsProvider = Provider<List<(String, String)>>((ref) {
  // 从 SupportedLanguages 动态生成所有语言对
  final allCodes = SupportedLanguages.all.map((l) => l.code).toList();
  final pairs = <(String, String)>[];
  
  for (final source in allCodes) {
    for (final target in allCodes) {
      if (source != target) {
        pairs.add((source, target));
      }
    }
  }
  
  return pairs;
});

/// 支持的语言列表 Provider
final supportedLanguagesProvider = Provider<List<LanguageConfig>>((ref) {
  return SupportedLanguages.all;
});

/// 常用语言对 Provider（用于快速选择）
final commonLanguagePairsProvider = Provider<List<(String, String)>>((ref) {
  return [
    ('zh', 'ug'),    // 中文 → 维吾尔语
    ('ug', 'zh'),    // 维吾尔语 → 中文
    ('zh', 'en'),    // 中文 → 英语
    ('en', 'zh'),    // 英语 → 中文
    ('ug', 'en'),    // 维吾尔语 → 英语
    ('en', 'ug'),    // 英语 → 维吾尔语
    ('zh', 'ar'),    // 中文 → 阿拉伯语
    ('ar', 'zh'),    // 阿拉伯语 → 中文
    ('zh', 'ja'),    // 中文 → 日语
    ('ja', 'zh'),    // 日语 → 中文
    ('zh', 'ko'),    // 中文 → 韩语
    ('ko', 'zh'),    // 韩语 → 中文
  ];
});

/// 中国少数民族语言 Provider
final minorityLanguagesProvider = Provider<List<LanguageConfig>>((ref) {
  return SupportedLanguages.chineseMinorityLanguages;
});
