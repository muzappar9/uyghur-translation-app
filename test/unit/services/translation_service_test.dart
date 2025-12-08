import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('TranslationService Tests', () {
    late MockTranslationEngine successEngine;
    late MockFailingTranslationEngine failureEngine;

    setUp(() {
      successEngine = TestFixtures.createMockTranslationEngine();
      failureEngine = TestFixtures.createMockFailingTranslationEngine();
    });

    tearDown(() async {
      await successEngine.dispose();
      await failureEngine.dispose();
    });

    test('✅ Should translate text successfully', () async {
      final result = await successEngine.translate('Hello', 'en', 'zh');
      expect(result, isNotEmpty);
      expect(result, contains('Translated'));
    });

    test('✅ Should support language pairs', () async {
      final supported = await successEngine.isSupported('en', 'zh');
      expect(supported, isTrue);
    });

    test('✅ Should handle empty text', () async {
      final result = await successEngine.translate('', 'en', 'zh');
      expect(result, isNotEmpty);
    });

    test('✅ Should support multiple language pairs', () async {
      final pairs = [
        ('en', 'zh'),
        ('zh', 'en'),
        ('ug', 'en'),
      ];

      for (final (source, target) in pairs) {
        final supported = await successEngine.isSupported(source, target);
        expect(supported, isTrue);
      }
    });

    test('✅ Should handle special characters', () async {
      final result = await successEngine.translate('Hello! @#\$%', 'en', 'zh');
      expect(result, isNotEmpty);
    });

    test('✅ Should handle long text', () async {
      final longText = 'a' * 500;
      final result = await successEngine.translate(longText, 'en', 'zh');
      expect(result, isNotEmpty);
    });

    test('✅ Should handle concurrent translations', () async {
      final futures = List.generate(
        5,
        (i) => successEngine.translate('Text $i', 'en', 'zh'),
      );
      final results = await Future.wait(futures);
      expect(results, hasLength(5));
      expect(results.every((r) => r.isNotEmpty), isTrue);
    });

    test('✅ Should throw when engine fails', () async {
      expect(
        () => failureEngine.translate('Test', 'en', 'zh'),
        throwsException,
      );
    });

    test('✅ Should initialize successfully', () async {
      await successEngine.initialize();
      expect(successEngine.name, isNotEmpty);
    });

    test('✅ Should maintain state across calls', () async {
      final r1 = await successEngine.translate('Text1', 'en', 'zh');
      final r2 = await successEngine.translate('Text2', 'en', 'zh');
      final r3 = await successEngine.translate('Text3', 'en', 'zh');

      expect(r1, isNotEmpty);
      expect(r2, isNotEmpty);
      expect(r3, isNotEmpty);
    });

    test('✅ Should handle rapid consecutive calls', () async {
      for (int i = 0; i < 10; i++) {
        final result = await successEngine.translate('Rapid $i', 'en', 'zh');
        expect(result, isNotEmpty);
      }
    });

    test('✅ Should dispose resources', () async {
      await expectLater(successEngine.dispose(), completes);
    });
  });
}
