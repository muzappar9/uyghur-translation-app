/// DeepSeek API 集成测试
/// 测试 DeepSeek 翻译 API 是否正常工作
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/core/api/translation_api_factory.dart';
import 'package:uyghur_translator/core/api/translation_api_interface.dart';

void main() {
  group('DeepSeek API Integration Tests', () {
    late TranslationApiInterface api;

    setUpAll(() {
      // 使用环境变量中的 API Key
      // 注意：运行测试前需要确保 .env 文件已加载
      api = TranslationApiFactory.create(
        provider: TranslationApiProvider.deepSeek,
        config: const TranslationApiConfig(
          providerId: 'deepseek',
          apiKey: 'sk-9034336091e7419b83729a18f3f38f87',
          apiEndpoint: 'https://api.deepseek.com',
          model: 'deepseek-chat',
        ),
      );
    });

    test('should translate Chinese to English', () async {
      final result = await api.translate(
        text: '你好',
        sourceLanguage: 'zh',
        targetLanguage: 'en',
      );

      expect(result.success, isTrue);
      expect(result.translatedText, isNotNull);
      expect(result.translatedText!.toLowerCase(), contains('hello'));
    });

    test('should translate English to Chinese', () async {
      final result = await api.translate(
        text: 'Hello, how are you?',
        sourceLanguage: 'en',
        targetLanguage: 'zh',
      );

      expect(result.success, isTrue);
      expect(result.translatedText, isNotNull);
    });

    test('should translate Chinese to Uyghur', () async {
      final result = await api.translate(
        text: '你好，你好吗？',
        sourceLanguage: 'zh',
        targetLanguage: 'ug',
      );

      expect(result.success, isTrue);
      expect(result.translatedText, isNotNull);
    });

    test('should translate Uyghur to Chinese', () async {
      final result = await api.translate(
        text: 'سالام، ياخشىمۇسىز؟',
        sourceLanguage: 'ug',
        targetLanguage: 'zh',
      );

      expect(result.success, isTrue);
      expect(result.translatedText, isNotNull);
    });

    test('should handle long text translation', () async {
      const longText = '''
Flutter 是 Google 开源的应用开发框架，仅通过一套代码库，
就能构建精美的、原生平台编译的多平台应用。
它支持移动端、Web 端和桌面端。
''';

      final result = await api.translate(
        text: longText,
        sourceLanguage: 'zh',
        targetLanguage: 'en',
      );

      expect(result.success, isTrue);
      expect(result.translatedText, isNotNull);
      expect(result.translatedText!.length, greaterThan(50));
    });
  });
}
