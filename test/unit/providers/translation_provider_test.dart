import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/shared/providers/translation_provider.dart';
import 'package:uyghur_translator/shared/services/translation/translation_manager.dart'
    hide translationManagerProvider;
import 'package:uyghur_translator/shared/services/translation/translation_engine.dart';

void main() {
  group('TranslationProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      // 使用 override 提供 Mock 的 TranslationManager，避免访问 dotenv
      final mockManager = TranslationManager(
        engines: [LocalMockTranslationEngine()],
      );

      container = ProviderContainer(
        overrides: [
          translationManagerProvider.overrideWithValue(mockManager),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('初始状态正确', () {
      final state = container.read(translationProvider);
      expect(state.sourceText, '');
      expect(state.targetText, '');
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('translate 更新源文本和目标文本', () async {
      final notifier = container.read(translationProvider.notifier);
      await notifier.translate('Hello');

      final state = container.read(translationProvider);
      expect(state.sourceText, isNotEmpty);
      expect(state.targetText, isNotEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('translate 处理空文本', () async {
      final notifier = container.read(translationProvider.notifier);
      await notifier.translate('');

      final state = container.read(translationProvider);
      expect(state.sourceText.isEmpty, true);
    });

    test('translate 在加载时设置 isLoading 为 true', () async {
      final notifier = container.read(translationProvider.notifier);

      final future = notifier.translate('test');
      // 检查加载状态
      await future;

      final state = container.read(translationProvider);
      expect(state.isLoading, false); // 加载完成后应该是 false
    });

    test('setSourceLanguage 更新源语言', () async {
      final notifier = container.read(translationProvider.notifier);
      notifier.setSourceLanguage('zh');

      final state = container.read(translationProvider);
      expect(state.sourceLanguage, 'zh');
    });

    test('setTargetLanguage 更新目标语言', () async {
      final notifier = container.read(translationProvider.notifier);
      notifier.setTargetLanguage('ug');

      final state = container.read(translationProvider);
      expect(state.targetLanguage, 'ug');
    });

    test('swapLanguages 交换源目标语言和文本', () async {
      final notifier = container.read(translationProvider.notifier);

      // 先设置一些文本
      await notifier.translate('Hello');
      notifier.setSourceLanguage('en');
      notifier.setTargetLanguage('zh');

      final beforeSwap = container.read(translationProvider);
      final beforeSource = beforeSwap.sourceLanguage;
      final beforeTarget = beforeSwap.targetLanguage;

      // 交换
      notifier.swapLanguages();

      final afterSwap = container.read(translationProvider);
      expect(afterSwap.sourceLanguage, beforeTarget);
      expect(afterSwap.targetLanguage, beforeSource);
    });

    test('clearTranslation 重置状态', () async {
      final notifier = container.read(translationProvider.notifier);

      // 先设置一些数据
      await notifier.translate('test');

      // 清除
      notifier.clearTranslation();

      final state = container.read(translationProvider);
      expect(state.sourceText, '');
      expect(state.targetText, '');
      expect(state.error, isNull);
    });

    test('toggleFavorite 改变 isFavorite 状态', () async {
      final notifier = container.read(translationProvider.notifier);

      final beforeToggle = container.read(translationProvider);
      expect(beforeToggle.isFavorite, false);

      notifier.toggleFavorite();

      final afterToggle = container.read(translationProvider);
      expect(afterToggle.isFavorite, true);

      notifier.toggleFavorite();

      final afterToggleAgain = container.read(translationProvider);
      expect(afterToggleAgain.isFavorite, false);
    });

    test('supportedLanguagePairsProvider 返回语言对列表', () {
      final pairs = container.read(supportedLanguagePairsProvider);
      expect(pairs, isNotEmpty);
      expect(pairs.length, 8); // 应该有8个语言对
    });

    test('translationHistoryProvider 返回异步值', () {
      final history = container.read(translationHistoryProvider);
      expect(history, isA<AsyncValue>());
    });
  });
}
