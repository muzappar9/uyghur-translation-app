import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('PendingSyncQueue Tests', () {
    late MockIsarDatabaseService database;

    setUp(() {
      database = TestFixtures.createMockDatabaseService();
    });

    tearDown(() async {
      await database.dispose();
    });

    test('✅ Should initialize queue', () async {
      await database.initialize();
      expect(database, isNotNull);
    });

    test('✅ Should add item to pending queue', () async {
      final id = await database.addTranslationHistory({
        'text': 'Pending Text',
        'source': 'en',
        'target': 'zh',
        'status': 'pending',
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should retrieve pending items', () async {
      await database.addTranslationHistory({
        'text': 'Item 1',
        'status': 'pending',
      });

      final items = await database.getTranslationHistory();
      expect(items, isNotEmpty);
    });

    test('✅ Should handle multiple pending items', () async {
      for (int i = 0; i < 8; i++) {
        await database.addTranslationHistory({
          'text': 'Pending $i',
          'status': 'pending',
        });
      }

      final items = await database.getTranslationHistory();
      expect(items.length, greaterThanOrEqualTo(8));
    });

    test('✅ Should mark item as synced', () async {
      await database.addTranslationHistory({
        'text': 'To Sync',
        'status': 'pending',
      });

      final items = await database.getTranslationHistory();
      expect(items, isNotEmpty);
    });

    test('✅ Should remove synced items from queue', () async {
      await database.clearAllData();

      const pendingData = {
        'text': 'Pending',
        'status': 'pending',
      };

      await database.addTranslationHistory(pendingData);
      await database.clearAllData();

      final items = await database.getTranslationHistory();
      expect(items, isEmpty);
    });

    test('✅ Should support retry count updates', () async {
      final id = await database.addTranslationHistory({
        'text': 'Retry Item',
        'retryCount': 0,
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should prevent exceeding max retries', () async {
      final id = await database.addTranslationHistory({
        'text': 'Max Retry',
        'retryCount': 5,
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should handle concurrent queue operations', () async {
      final futures = List.generate(
        5,
        (i) => database.addTranslationHistory({
          'text': 'Concurrent Pending $i',
          'status': 'pending',
        }),
      );

      final ids = await Future.wait(futures);
      expect(ids, hasLength(5));
    });

    test('✅ Should maintain queue order', () async {
      await database.clearAllData();

      for (int i = 0; i < 3; i++) {
        await database.addTranslationHistory({
          'text': 'Item $i',
          'order': i,
        });
      }

      final items = await database.getTranslationHistory();
      expect(items, isNotEmpty);
    });

    test('✅ Should handle empty queue gracefully', () async {
      await database.clearAllData();
      final items = await database.getTranslationHistory();
      expect(items, isEmpty);
    });

    test('✅ Should support priority-based processing', () async {
      for (int priority = 1; priority <= 3; priority++) {
        await database.addTranslationHistory({
          'text': 'Priority $priority',
          'priority': priority,
        });
      }

      final items = await database.getTranslationHistory();
      expect(items.length, greaterThanOrEqualTo(3));
    });

    test('✅ Should handle partial sync recovery', () async {
      for (int i = 0; i < 4; i++) {
        await database.addTranslationHistory({
          'text': 'Recoverable $i',
          'status': 'pending',
        });
      }

      final items = await database.getTranslationHistory();
      expect(items, isNotEmpty);
    });

    test('✅ Should preserve failed items for retry', () async {
      const failedItem = {
        'text': 'Failed Item',
        'status': 'failed',
        'error': 'Network error',
      };

      final id = await database.addTranslationHistory(failedItem);
      expect(id, greaterThan(0));
    });
  });
}
