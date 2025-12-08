import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('MockTranslationEngine Tests', () {
    late MockTranslationEngine engine;

    setUp(() {
      engine = TestFixtures.createMockTranslationEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('✅ Should initialize successfully', () async {
      await engine.initialize();
      expect(engine.name, equals('MockTranslationEngine'));
    });

    test('✅ Should translate text', () async {
      final result = await engine.translate('Hello', 'en', 'zh');
      expect(result, contains('Translated'));
      expect(result, contains('Hello'));
    });

    test('✅ Should support language pairs', () async {
      final supported = await engine.isSupported('en', 'zh');
      expect(supported, isTrue);
    });

    test('✅ Should handle multiple language pairs', () async {
      final pairs = [('en', 'zh'), ('ug', 'en'), ('zh', 'tr')];
      for (final (src, tgt) in pairs) {
        final result = await engine.isSupported(src, tgt);
        expect(result, isTrue);
      }
    });

    test('✅ Should handle empty text', () async {
      final result = await engine.translate('', 'en', 'zh');
      expect(result, contains('Translated'));
    });

    test('✅ Should handle long text', () async {
      final longText = 'a' * 1000;
      final result = await engine.translate(longText, 'en', 'zh');
      expect(result, contains(longText));
    });

    test('✅ Should handle special characters', () async {
      const special = 'Hello! @#\$%^&*()';
      final result = await engine.translate(special, 'en', 'zh');
      expect(result, contains(special));
    });

    test('✅ Should dispose without errors', () async {
      await expectLater(engine.dispose(), completes);
    });

    test('✅ Should handle concurrent calls', () async {
      final futures = List.generate(
        5,
        (i) => engine.translate('Text $i', 'en', 'zh'),
      );
      final results = await Future.wait(futures);
      expect(results, hasLength(5));
      expect(results.every((r) => r.contains('Translated')), isTrue);
    });

    test('✅ Should recover from multiple operations', () async {
      await engine.initialize();
      final r1 = await engine.translate('Test1', 'en', 'zh');
      final r2 = await engine.translate('Test2', 'en', 'zh');
      await engine.dispose();
      expect(r1, isNotEmpty);
      expect(r2, isNotEmpty);
    });
  });

  group('MockFailingTranslationEngine Tests', () {
    late MockFailingTranslationEngine engine;

    setUp(() {
      engine = TestFixtures.createMockFailingTranslationEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('✅ Should throw on translate', () async {
      expect(
        () => engine.translate('Test', 'en', 'zh'),
        throwsException,
      );
    });

    test('✅ Should throw on initialize', () async {
      expect(() => engine.initialize(), throwsException);
    });

    test('✅ Should handle error gracefully', () async {
      try {
        await engine.translate('Test', 'en', 'zh');
        fail('Should throw exception');
      } catch (e) {
        expect(e, isException);
      }
    });
  });
}
