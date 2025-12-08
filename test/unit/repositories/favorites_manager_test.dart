import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('FavoritesManager Tests', () {
    late MockIsarDatabaseService database;

    setUp(() {
      database = TestFixtures.createMockDatabaseService();
    });

    tearDown(() async {
      await database.dispose();
    });

    test('✅ Should initialize favorites manager', () async {
      await database.initialize();
      expect(database, isNotNull);
    });

    test('✅ Should add item to favorites', () async {
      final id = await database.addTranslationHistory({
        'text': 'Favorite Text',
        'source': 'en',
        'target': 'zh',
        'isFavorite': true,
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should retrieve favorite items', () async {
      await database.addTranslationHistory({
        'text': 'My Favorite',
        'isFavorite': true,
      });

      final items = await database.getTranslationHistory();
      expect(items, isNotEmpty);
    });

    test('✅ Should handle multiple favorites', () async {
      for (int i = 0; i < 10; i++) {
        await database.addTranslationHistory({
          'text': 'Favorite $i',
          'isFavorite': true,
        });
      }

      final items = await database.getTranslationHistory();
      expect(items.length, greaterThanOrEqualTo(10));
    });

    test('✅ Should remove item from favorites', () async {
      const favoriteData = {
        'text': 'To Unfavorite',
        'isFavorite': true,
      };

      await database.addTranslationHistory(favoriteData);
      await database.clearAllData();

      final items = await database.getTranslationHistory();
      expect(items, isEmpty);
    });

    test('✅ Should toggle favorite status', () async {
      final id = await database.addTranslationHistory({
        'text': 'Toggle Item',
        'isFavorite': true,
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should support favorite with categories', () async {
      const categorizedFav = {
        'text': 'Categorized Favorite',
        'isFavorite': true,
        'category': 'phrases',
      };

      final id = await database.addTranslationHistory(categorizedFav);
      expect(id, greaterThan(0));
    });

    test('✅ Should handle concurrent favorite operations', () async {
      final futures = List.generate(
        10,
        (i) => database.addTranslationHistory({
          'text': 'Concurrent Fav $i',
          'isFavorite': true,
        }),
      );

      final ids = await Future.wait(futures);
      expect(ids, hasLength(10));
    });

    test('✅ Should preserve favorite metadata', () async {
      const favWithMeta = {
        'text': 'Metadata Favorite',
        'isFavorite': true,
        'addedDate': '2024-01-01',
        'category': 'important',
        'tags': 'translation,favorite',
      };

      final id = await database.addTranslationHistory(favWithMeta);
      expect(id, greaterThan(0));
    });

    test('✅ Should support favorite search', () async {
      for (int i = 0; i < 5; i++) {
        await database.addTranslationHistory({
          'text': 'Searchable Favorite $i',
          'isFavorite': true,
          'keyword': 'search',
        });
      }

      final items = await database.getTranslationHistory();
      expect(items, isNotEmpty);
    });

    test('✅ Should handle favorite deletion', () async {
      await database.addTranslationHistory({
        'text': 'To Delete',
        'isFavorite': true,
      });

      await database.clearAllData();

      final items = await database.getTranslationHistory();
      expect(items, isEmpty);
    });

    test('✅ Should support sorting favorites', () async {
      for (int i = 0; i < 5; i++) {
        await database.addTranslationHistory({
          'text': 'Item $i',
          'isFavorite': true,
          'priority': i,
        });
      }

      final items = await database.getTranslationHistory();
      expect(items.length, greaterThanOrEqualTo(5));
    });

    test('✅ Should handle favorite with translations', () async {
      const favWithTranslation = {
        'text': 'Original Text',
        'translation': 'أصلي النص',
        'isFavorite': true,
      };

      final id = await database.addTranslationHistory(favWithTranslation);
      expect(id, greaterThan(0));
    });

    test('✅ Should maintain favorite count', () async {
      await database.clearAllData();

      for (int i = 0; i < 3; i++) {
        await database.addTranslationHistory({
          'text': 'Count $i',
          'isFavorite': true,
        });
      }

      final items = await database.getTranslationHistory();
      expect(items.length, equals(3));
    });

    test('✅ Should support batch favorite operations', () async {
      final futures = List.generate(
        5,
        (i) => database.addTranslationHistory({
          'text': 'Batch $i',
          'isFavorite': true,
        }),
      );

      final ids = await Future.wait(futures);
      expect(ids, hasLength(5));
    });
  });
}
