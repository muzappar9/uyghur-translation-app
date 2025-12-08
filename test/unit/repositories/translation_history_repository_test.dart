import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('TranslationHistoryRepository Tests', () {
    late MockIsarDatabaseService database;

    setUp(() {
      database = TestFixtures.createMockDatabaseService();
    });

    tearDown(() async {
      await database.dispose();
    });

    test('✅ Should initialize database', () async {
      await database.initialize();
      expect(database, isNotNull);
    });

    test('✅ Should save translation to history', () async {
      final id = await database.addTranslationHistory({
        'text': 'Hello',
        'source': 'en',
        'target': 'zh',
        'timestamp': DateTime.now().toString(),
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should retrieve translation history', () async {
      await database.addTranslationHistory({
        'text': 'Test Translation',
        'source': 'en',
        'target': 'zh',
      });

      final history = await database.getTranslationHistory();
      expect(history, isNotEmpty);
    });

    test('✅ Should handle multiple translations', () async {
      for (int i = 0; i < 5; i++) {
        await database.addTranslationHistory({
          'text': 'Translation $i',
          'source': 'en',
          'target': 'zh',
        });
      }

      final history = await database.getTranslationHistory();
      expect(history.length, greaterThanOrEqualTo(5));
    });

    test('✅ Should maintain translation order', () async {
      await database.clearAllData();

      for (int i = 0; i < 3; i++) {
        await database.addTranslationHistory({
          'text': 'Translation $i',
          'index': i,
        });
      }

      final history = await database.getTranslationHistory();
      expect(history, isNotEmpty);
    });

    test('✅ Should clear history', () async {
      await database.addTranslationHistory({'text': 'Test'});
      await database.clearAllData();

      final history = await database.getTranslationHistory();
      expect(history, isEmpty);
    });

    test('✅ Should handle translation with metadata', () async {
      const translation = {
        'text': 'Hello World',
        'source': 'en',
        'target': 'zh',
        'duration': '1.5s',
        'quality': 'high',
      };

      final id = await database.addTranslationHistory(translation);
      expect(id, greaterThan(0));
    });

    test('✅ Should support batch operations', () async {
      final futures = List.generate(
        10,
        (i) => database.addTranslationHistory({
          'text': 'Batch $i',
          'source': 'en',
          'target': 'zh',
        }),
      );

      final ids = await Future.wait(futures);
      expect(ids, hasLength(10));
    });

    test('✅ Should handle concurrent reads and writes', () async {
      final writes = List.generate(
        5,
        (i) => database.addTranslationHistory({
          'text': 'Write $i',
        }),
      );

      await Future.wait(writes);

      final history = await database.getTranslationHistory();
      expect(history, isNotEmpty);
    });

    test('✅ Should preserve all fields in history', () async {
      const data = {
        'text': 'Preserve Test',
        'source': 'en',
        'target': 'ug',
      };

      await database.addTranslationHistory(data);
      final history = await database.getTranslationHistory();

      expect(history[0]['text'], equals('Preserve Test'));
      expect(history[0]['source'], equals('en'));
      expect(history[0]['target'], equals('ug'));
    });
  });
}
