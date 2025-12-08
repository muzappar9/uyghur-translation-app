import 'package:flutter_test/flutter_test.dart';
import '../fixtures/mock_services.dart';

void main() {
  group('Translation Performance Tests', () {
    late MockTranslationEngine engine;

    setUp(() {
      engine = TestFixtures.createMockTranslationEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('✅ Should complete single translation in acceptable time', () async {
      final stopwatch = Stopwatch()..start();

      await engine.translate('Hello World', 'en', 'zh');

      stopwatch.stop();

      // Mock should be very fast - less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('✅ Should handle 100 translations efficiently', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await engine.translate('Text $i', 'en', 'zh');
      }

      stopwatch.stop();

      // 100 mocks should complete in reasonable time
      final avgTime = stopwatch.elapsedMilliseconds / 100;
      expect(avgTime, lessThan(10)); // Average < 10ms per translation
    });

    test('✅ Should maintain performance with large text', () async {
      final largeText = 'a' * 1000;
      final stopwatch = Stopwatch()..start();

      await engine.translate(largeText, 'en', 'zh');

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Voice Recognition Performance Tests', () {
    late MockVoiceRecognitionEngine engine;

    setUp(() {
      engine = TestFixtures.createMockVoiceEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('✅ Should recognize audio in acceptable time', () async {
      final stopwatch = Stopwatch()..start();

      final stream = engine.listen('en');
      await stream.first;

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('✅ Should handle concurrent voice recognition', () async {
      final stopwatch = Stopwatch()..start();

      final futures = List.generate(
        5,
        (i) => engine.listen('en').first,
      );

      await Future.wait(futures);

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });

  group('Database Performance Tests', () {
    late MockIsarDatabaseService database;

    setUp(() {
      database = TestFixtures.createMockDatabaseService();
    });

    tearDown(() async {
      await database.dispose();
    });

    test('✅ Should add 100 records efficiently', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await database.addTranslationHistory({
          'text': 'Record $i',
          'index': i,
        });
      }

      stopwatch.stop();

      final avgTime = stopwatch.elapsedMilliseconds / 100;
      expect(avgTime, lessThan(5));
    });

    test('✅ Should retrieve history efficiently', () async {
      // Add some records
      for (int i = 0; i < 50; i++) {
        await database.addTranslationHistory({'text': 'Item $i'});
      }

      final stopwatch = Stopwatch()..start();

      await database.getTranslationHistory();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('✅ Should clear data efficiently', () async {
      // Add records
      for (int i = 0; i < 50; i++) {
        await database.addTranslationHistory({'text': 'Item $i'});
      }

      final stopwatch = Stopwatch()..start();

      await database.clearAllData();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
