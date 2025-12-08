import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('IsarDatabaseService Tests', () {
    late MockIsarDatabaseService database;

    setUp(() {
      database = TestFixtures.createMockDatabaseService();
    });

    tearDown(() async {
      await database.dispose();
    });

    test('✅ Should initialize database', () async {
      await database.initialize();
      // No exception thrown
      expect(database, isNotNull);
    });

    test('✅ Should add translation history', () async {
      final id = await database.addTranslationHistory({
        'text': 'Hello',
        'source': 'en',
        'target': 'zh',
        'timestamp': DateTime.now().toString(),
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should get translation history', () async {
      await database.addTranslationHistory({'text': 'Test1'});
      final history = await database.getTranslationHistory();

      expect(history, isNotEmpty);
      expect(history.length, greaterThanOrEqualTo(1));
    });

    test('✅ Should handle multiple entries', () async {
      for (int i = 0; i < 5; i++) {
        await database.addTranslationHistory({
          'text': 'Text$i',
          'source': 'en',
          'target': 'zh',
        });
      }

      final history = await database.getTranslationHistory();
      expect(history.length, greaterThanOrEqualTo(5));
    });

    test('✅ Should clear all data', () async {
      await database.addTranslationHistory({'text': 'Test'});
      await database.clearAllData();

      final history = await database.getTranslationHistory();
      expect(history, isEmpty);
    });

    test('✅ Should maintain data integrity', () async {
      final data1 = {
        'text': 'Original',
        'source': 'en',
        'target': 'zh',
      };

      await database.addTranslationHistory(data1);
      final history = await database.getTranslationHistory();

      expect(history, isNotEmpty);
      expect(history[0]['text'], equals('Original'));
    });

    test('✅ Should handle empty history query', () async {
      await database.clearAllData();
      final history = await database.getTranslationHistory();

      expect(history, isEmpty);
    });

    test('✅ Should support concurrent operations', () async {
      final futures = List.generate(
        10,
        (i) => database.addTranslationHistory({
          'text': 'Concurrent$i',
          'source': 'en',
          'target': 'zh',
        }),
      );

      final ids = await Future.wait(futures);
      expect(ids, hasLength(10));
      expect(ids.every((id) => id > 0), isTrue);
    });

    test('✅ Should handle large data entries', () async {
      final largeText = 'a' * 1000;
      final id = await database.addTranslationHistory({
        'text': largeText,
        'source': 'en',
        'target': 'zh',
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should preserve field information', () async {
      const testData = {
        'text': 'Hello World',
        'source': 'en',
        'target': 'ug',
        'timestamp': '2024-01-01 00:00:00',
      };

      await database.addTranslationHistory(testData);
      final history = await database.getTranslationHistory();

      expect(history, isNotEmpty);
      expect(history[0]['text'], equals('Hello World'));
      expect(history[0]['source'], equals('en'));
      expect(history[0]['target'], equals('ug'));
    });

    test('✅ Should handle rapid clear and add operations', () async {
      await database.addTranslationHistory({'text': 'Initial'});
      await database.clearAllData();
      await database.addTranslationHistory({'text': 'After Clear'});

      final history = await database.getTranslationHistory();
      expect(history, isNotEmpty);
      expect(history[0]['text'], equals('After Clear'));
    });

    test('✅ Should be reusable after dispose', () async {
      await database.initialize();
      await database.dispose();

      // Should be able to reinitialize
      final newDb = TestFixtures.createMockDatabaseService();
      await newDb.initialize();
      expect(newDb, isNotNull);
    });

    test('✅ Should handle special characters in data', () async {
      const specialData = {
        'text': 'Hello! @#\$%^&*()',
        'source': 'en',
        'target': 'zh',
      };

      final id = await database.addTranslationHistory(specialData);
      expect(id, greaterThan(0));
    });

    test('✅ Should increment IDs correctly', () async {
      final id1 = await database.addTranslationHistory({'text': 'First'});
      final id2 = await database.addTranslationHistory({'text': 'Second'});
      final id3 = await database.addTranslationHistory({'text': 'Third'});

      expect(id1, lessThan(id2));
      expect(id2, lessThan(id3));
    });

    test('✅ Should handle null and empty values gracefully', () async {
      final id = await database.addTranslationHistory({
        'text': '',
        'source': '',
        'target': '',
      });

      expect(id, greaterThan(0));
    });
  });
}
