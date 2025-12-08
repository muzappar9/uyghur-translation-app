import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'translation_api_interface.dart';
import 'providers/mock_translation_api.dart';
import 'providers/self_hosted_translation_api.dart';

/// API提供商类型
///
/// 支持的提供商：
/// - mock: 开发测试用
/// - selfHosted: 自托管模型（私有服务器部署）
/// - deepSeek: DeepSeek API
/// - iflytekSpark: 科大讯飞星火
/// - tencentHunyuan: 腾讯混元
/// - openAI: OpenAI API（GPT系列）
enum TranslationApiProvider {
  /// Mock API（开发和测试）
  mock,

  /// 自托管API（私有部署）
  selfHosted,

  /// DeepSeek API
  deepSeek,

  /// 科大讯飞 星火大模型
  iflytekSpark,

  /// 腾讯混元大模型
  tencentHunyuan,

  /// OpenAI API（GPT系列）
  openAI,
}

/// API工厂 - 创建和管理翻译API实例
class TranslationApiFactory {
  static final Logger _logger = Logger();
  static final Map<TranslationApiProvider, TranslationApiInterface> _instances =
      {};

  /// 创建API实例
  static TranslationApiInterface create({
    required TranslationApiProvider provider,
    TranslationApiConfig? config,
  }) {
    _logger.i('🏭 Creating translation API: ${provider.name}');

    switch (provider) {
      case TranslationApiProvider.mock:
        return MockTranslationApi(
          simulatedDelay: const Duration(milliseconds: 300),
          errorRate: 0.0,
        );

      case TranslationApiProvider.selfHosted:
        if (config == null || config.apiEndpoint == null) {
          throw ArgumentError('Self-hosted API requires apiEndpoint in config');
        }
        return SelfHostedTranslationApi(
          config: SelfHostedApiConfig(
            apiEndpoint: config.apiEndpoint!,
            apiKey: config.apiKey,
            timeout: config.timeout,
            maxRetries: config.maxRetries,
          ),
        );

      case TranslationApiProvider.deepSeek:
        // DeepSeek API - 兼容 OpenAI 格式
        if (config == null || config.apiKey == null) {
          throw ArgumentError('DeepSeek API requires apiKey in config');
        }
        return SelfHostedTranslationApi(
          config: SelfHostedApiConfig.openAICompatible(
            apiEndpoint: config.apiEndpoint ?? 'https://api.deepseek.com',
            apiKey: config.apiKey!,
            model: config.model ?? 'deepseek-chat',
          ),
        );

      case TranslationApiProvider.iflytekSpark:
        // 科大讯飞星火大模型
        if (config == null || config.apiKey == null) {
          throw ArgumentError('iFlytek Spark API requires apiKey in config');
        }
        return SelfHostedTranslationApi(
          config: SelfHostedApiConfig(
            apiEndpoint: config.apiEndpoint ??
                'https://spark-api-open.xf-yun.com/v1/chat/completions',
            apiKey: config.apiKey!,
            modelId: config.model ?? 'generalv3.5',
            timeout: config.timeout,
            maxRetries: config.maxRetries,
          ),
        );

      case TranslationApiProvider.tencentHunyuan:
        // 腾讯混元大模型
        if (config == null || config.apiKey == null) {
          throw ArgumentError('Tencent Hunyuan API requires apiKey in config');
        }
        return SelfHostedTranslationApi(
          config: SelfHostedApiConfig(
            apiEndpoint:
                config.apiEndpoint ?? 'https://hunyuan.tencentcloudapi.com',
            apiKey: config.apiKey!,
            modelId: config.model ?? 'hunyuan-lite',
            timeout: config.timeout,
            maxRetries: config.maxRetries,
          ),
        );

      case TranslationApiProvider.openAI:
        if (config == null || config.apiKey == null) {
          throw ArgumentError('OpenAI API requires apiKey in config');
        }
        return SelfHostedTranslationApi(
          config: SelfHostedApiConfig.openAICompatible(
            apiEndpoint: config.apiEndpoint ?? 'https://api.openai.com',
            apiKey: config.apiKey!,
            model: config.model ?? 'gpt-3.5-turbo',
          ),
        );
    }
  }

  /// 获取或创建单例实例
  static TranslationApiInterface getOrCreate({
    required TranslationApiProvider provider,
    TranslationApiConfig? config,
  }) {
    if (!_instances.containsKey(provider)) {
      _instances[provider] = create(provider: provider, config: config);
    }
    return _instances[provider]!;
  }

  /// 释放所有实例
  static Future<void> disposeAll() async {
    for (final instance in _instances.values) {
      await instance.dispose();
    }
    _instances.clear();
  }

  /// 释放特定实例
  static Future<void> dispose(TranslationApiProvider provider) async {
    final instance = _instances.remove(provider);
    await instance?.dispose();
  }
}

/// API管理器状态
class TranslationApiManagerState {
  final TranslationApiProvider currentProvider;
  final TranslationApiInterface? api;
  final bool isAvailable;
  final String? errorMessage;

  const TranslationApiManagerState({
    required this.currentProvider,
    this.api,
    this.isAvailable = false,
    this.errorMessage,
  });

  TranslationApiManagerState copyWith({
    TranslationApiProvider? currentProvider,
    TranslationApiInterface? api,
    bool? isAvailable,
    String? errorMessage,
  }) {
    return TranslationApiManagerState(
      currentProvider: currentProvider ?? this.currentProvider,
      api: api ?? this.api,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: errorMessage,
    );
  }
}

/// API管理器 - Riverpod Notifier
class TranslationApiManager extends Notifier<TranslationApiManagerState> {
  final Logger _logger = Logger();

  @override
  TranslationApiManagerState build() {
    // 默认使用Mock API
    final api = TranslationApiFactory.create(
      provider: TranslationApiProvider.mock,
    );

    return TranslationApiManagerState(
      currentProvider: TranslationApiProvider.mock,
      api: api,
      isAvailable: true,
    );
  }

  /// 切换API提供商
  Future<void> switchProvider(
    TranslationApiProvider provider, {
    TranslationApiConfig? config,
  }) async {
    _logger.i('🔄 Switching to provider: ${provider.name}');

    try {
      // 释放旧实例
      await state.api?.dispose();

      // 创建新实例
      final api = TranslationApiFactory.create(
        provider: provider,
        config: config,
      );

      // 检查可用性
      final isAvailable = await api.isAvailable();

      state = state.copyWith(
        currentProvider: provider,
        api: api,
        isAvailable: isAvailable,
        errorMessage: isAvailable ? null : 'API not available',
      );

      _logger.i('✅ Switched to ${provider.name}, available: $isAvailable');
    } catch (e) {
      _logger.e('❌ Failed to switch provider: $e');
      state = state.copyWith(
        errorMessage: 'Failed to switch: $e',
        isAvailable: false,
      );
    }
  }

  /// 翻译文本
  Future<TranslationApiResponse> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (state.api == null || !state.isAvailable) {
      return TranslationApiResponse.failure(
        errorMessage: 'Translation API not available',
        errorCode: 'API_NOT_AVAILABLE',
      );
    }

    return await state.api!.translate(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  /// 批量翻译
  Future<BatchTranslationApiResponse> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (state.api == null || !state.isAvailable) {
      return const BatchTranslationApiResponse(
        success: false,
        results: [],
        errorMessage: 'Translation API not available',
      );
    }

    return await state.api!.translateBatch(
      texts: texts,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  /// 检测语言
  Future<String?> detectLanguage(String text) async {
    return await state.api?.detectLanguage(text);
  }

  /// 获取支持的语言
  Future<List<SupportedLanguage>> getSupportedLanguages() async {
    return await state.api?.getSupportedLanguages() ?? [];
  }

  /// 刷新可用性状态
  Future<void> refreshAvailability() async {
    final isAvailable = await state.api?.isAvailable() ?? false;
    state = state.copyWith(isAvailable: isAvailable);
  }
}

/// API管理器Provider
final translationApiManagerProvider =
    NotifierProvider<TranslationApiManager, TranslationApiManagerState>(
  TranslationApiManager.new,
);

/// 当前API Provider
final currentTranslationApiProvider = Provider<TranslationApiInterface?>((ref) {
  return ref.watch(translationApiManagerProvider).api;
});

/// API可用性Provider
final translationApiAvailableProvider = Provider<bool>((ref) {
  return ref.watch(translationApiManagerProvider).isAvailable;
});

/// 翻译快捷Provider
final translateProvider =
    FutureProvider.family<TranslationApiResponse, TranslateParams>(
  (ref, params) async {
    final manager = ref.read(translationApiManagerProvider.notifier);
    return await manager.translate(
      text: params.text,
      sourceLanguage: params.sourceLanguage,
      targetLanguage: params.targetLanguage,
    );
  },
);

/// 翻译参数
class TranslateParams {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  const TranslateParams({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslateParams &&
          text == other.text &&
          sourceLanguage == other.sourceLanguage &&
          targetLanguage == other.targetLanguage;

  @override
  int get hashCode =>
      text.hashCode ^ sourceLanguage.hashCode ^ targetLanguage.hashCode;
}
