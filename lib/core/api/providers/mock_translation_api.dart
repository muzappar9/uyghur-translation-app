import 'dart:async';
import '../translation_api_interface.dart';

/// Mock翻译API实现 - 用于开发和测试
///
/// 功能：
/// - 模拟翻译响应
/// - 可配置延迟和错误率
/// - 支持本地字典
class MockTranslationApi implements TranslationApiInterface {
  final Duration _simulatedDelay;
  final double _errorRate;
  final Map<String, Map<String, String>> _localDictionary;

  MockTranslationApi({
    Duration simulatedDelay = const Duration(milliseconds: 500),
    double errorRate = 0.0,
    Map<String, Map<String, String>>? localDictionary,
  })  : _simulatedDelay = simulatedDelay,
        _errorRate = errorRate,
        _localDictionary = localDictionary ?? _defaultDictionary;

  /// 默认Mock字典
  static const Map<String, Map<String, String>> _defaultDictionary = {
    'hello': {
      'en_zh': '你好',
      'en_ug': 'سالام',
      'zh_en': 'hello',
      'zh_ug': 'سالام',
      'ug_en': 'hello',
      'ug_zh': '你好',
    },
    'good morning': {
      'en_zh': '早上好',
      'en_ug': 'خەيرلىك ئەتىگەن',
      'zh_en': 'good morning',
      'zh_ug': 'خەيرلىك ئەتىگەن',
    },
    'thank you': {
      'en_zh': '谢谢',
      'en_ug': 'رەھمەت',
      'zh_en': 'thank you',
      'zh_ug': 'رەھمەت',
      'ug_en': 'thank you',
      'ug_zh': '谢谢',
    },
    'how are you': {
      'en_zh': '你好吗',
      'en_ug': 'ئەھۋالىڭىز قانداق؟',
      'zh_en': 'how are you',
      'zh_ug': 'ئەھۋالىڭىز قانداق؟',
    },
    'goodbye': {
      'en_zh': '再见',
      'en_ug': 'خەير خوش',
      'zh_en': 'goodbye',
      'zh_ug': 'خەير خوش',
      'ug_en': 'goodbye',
      'ug_zh': '再见',
    },
    'welcome': {
      'en_zh': '欢迎',
      'en_ug': 'خۇش كەلدىڭىز',
      'zh_en': 'welcome',
      'zh_ug': 'خۇش كەلدىڭىز',
    },
    'please': {
      'en_zh': '请',
      'en_ug': 'مەرھەمەت قىلىپ',
      'zh_en': 'please',
      'zh_ug': 'مەرھەمەت قىلىپ',
    },
    'sorry': {
      'en_zh': '对不起',
      'en_ug': 'كەچۈرۈڭ',
      'zh_en': 'sorry',
      'zh_ug': 'كەچۈرۈڭ',
    },
    'yes': {
      'en_zh': '是',
      'en_ug': 'شۇنداق',
      'zh_en': 'yes',
      'zh_ug': 'شۇنداق',
    },
    'no': {
      'en_zh': '不',
      'en_ug': 'ياق',
      'zh_en': 'no',
      'zh_ug': 'ياق',
    },
    // 维吾尔语特色词汇
    'bread': {
      'en_zh': '馕',
      'en_ug': 'نان',
      'zh_en': 'bread/naan',
      'zh_ug': 'نان',
    },
    'tea': {
      'en_zh': '茶',
      'en_ug': 'چاي',
      'zh_en': 'tea',
      'zh_ug': 'چاي',
    },
    'friend': {
      'en_zh': '朋友',
      'en_ug': 'دوست',
      'zh_en': 'friend',
      'zh_ug': 'دوست',
    },
    'family': {
      'en_zh': '家庭',
      'en_ug': 'ئائىلە',
      'zh_en': 'family',
      'zh_ug': 'ئائىلە',
    },
    'love': {
      'en_zh': '爱',
      'en_ug': 'مۇھەببەت',
      'zh_en': 'love',
      'zh_ug': 'مۇھەببەت',
    },
  };

  @override
  TranslationApiInfo get apiInfo => const TranslationApiInfo(
        providerId: 'mock',
        providerName: 'Mock Translation API',
        version: '1.0.0',
        supportsOffline: true,
        supportsBatch: true,
        supportsDetectLanguage: true,
        maxTextLength: 5000,
        maxBatchSize: 100,
        supportedLanguages: [
          SupportedLanguage(
            code: 'en',
            name: 'English',
            nativeName: 'English',
          ),
          SupportedLanguage(
            code: 'zh',
            name: 'Chinese',
            nativeName: '中文',
          ),
          SupportedLanguage(
            code: 'ug',
            name: 'Uyghur',
            nativeName: 'ئۇيغۇرچە',
          ),
        ],
      );

  @override
  Future<bool> isAvailable() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<TranslationApiResponse> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 模拟网络延迟
    await Future.delayed(_simulatedDelay);

    // 模拟随机错误
    if (_errorRate > 0 && _shouldSimulateError()) {
      return TranslationApiResponse.failure(
        errorMessage: '模拟网络错误',
        errorCode: 'MOCK_ERROR',
      );
    }

    // 查找翻译
    final langPair = '${sourceLanguage}_$targetLanguage';
    final key = text.toLowerCase().trim();

    String translatedText;
    if (_localDictionary.containsKey(key)) {
      final translations = _localDictionary[key]!;
      translatedText = translations[langPair] ??
          _generateMockTranslation(text, targetLanguage);
    } else {
      translatedText = _generateMockTranslation(text, targetLanguage);
    }

    stopwatch.stop();

    return TranslationApiResponse.success(
      translatedText: translatedText,
      responseTime: stopwatch.elapsed,
      metadata: {
        'provider': 'mock',
        'cached': _localDictionary.containsKey(key),
        'langPair': langPair,
      },
    );
  }

  @override
  Future<BatchTranslationApiResponse> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final stopwatch = Stopwatch()..start();
    final results = <TranslationApiResponse>[];

    for (final text in texts) {
      final result = await translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      results.add(result);
    }

    stopwatch.stop();

    return BatchTranslationApiResponse(
      success: results.every((r) => r.success),
      results: results,
      totalResponseTime: stopwatch.elapsed,
    );
  }

  @override
  Future<String?> detectLanguage(String text) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 简单的语言检测逻辑
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
      return 'zh';
    } else if (RegExp(r'[\u0600-\u06ff]').hasMatch(text)) {
      return 'ug';
    } else if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      return 'en';
    }

    return null;
  }

  @override
  Future<List<SupportedLanguage>> getSupportedLanguages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return apiInfo.supportedLanguages;
  }

  @override
  Future<bool> validateConfiguration() async {
    return true;
  }

  @override
  Future<void> dispose() async {
    // Mock API 无需清理
  }

  bool _shouldSimulateError() {
    return DateTime.now().millisecondsSinceEpoch % 100 < (_errorRate * 100);
  }

  String _generateMockTranslation(String text, String targetLanguage) {
    // 为未知词汇生成模拟翻译
    switch (targetLanguage) {
      case 'zh':
        return '[$text的中文翻译]';
      case 'ug':
        return '[$text نىڭ تەرجىمىسى]';
      case 'en':
        return '[Translation of $text]';
      default:
        return '[$text]';
    }
  }
}

/// Mock API配置
class MockTranslationApiConfig extends TranslationApiConfig {
  final Duration simulatedDelay;
  final double errorRate;

  const MockTranslationApiConfig({
    this.simulatedDelay = const Duration(milliseconds: 500),
    this.errorRate = 0.0,
  }) : super(providerId: 'mock');
}
