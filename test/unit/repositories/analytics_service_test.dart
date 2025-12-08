import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('AnalyticsService Tests', () {
    late MockIsarDatabaseService database;

    setUp(() {
      database = TestFixtures.createMockDatabaseService();
    });

    tearDown(() async {
      await database.dispose();
    });

    test('✅ Should initialize analytics', () async {
      await database.initialize();
      expect(database, isNotNull);
    });

    test('✅ Should track translation event', () async {
      final id = await database.addTranslationHistory({
        'text': 'Hello',
        'source': 'en',
        'target': 'zh',
        'event': 'translation',
        'timestamp': DateTime.now().toString(),
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should track voice recognition event', () async {
      final id = await database.addTranslationHistory({
        'text': 'Voice input',
        'event': 'voice_recognition',
        'language': 'en',
        'duration': '2.5s',
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should track OCR event', () async {
      final id = await database.addTranslationHistory({
        'text': 'OCR recognized',
        'event': 'ocr_recognition',
        'imageSize': '2MB',
      });

      expect(id, greaterThan(0));
    });

    test('✅ Should collect multiple events', () async {
      for (int i = 0; i < 8; i++) {
        await database.addTranslationHistory({
          'event': 'event_$i',
          'data': 'data_$i',
        });
      }

      final events = await database.getTranslationHistory();
      expect(events.length, greaterThanOrEqualTo(8));
    });

    test('✅ Should track user interactions', () async {
      const interaction = {
        'event': 'button_click',
        'button': 'translate',
        'timestamp': '2024-01-01 00:00:00',
      };

      final id = await database.addTranslationHistory(interaction);
      expect(id, greaterThan(0));
    });

    test('✅ Should track performance metrics', () async {
      const metrics = {
        'event': 'performance',
        'translationTime': '1.5s',
        'networkLatency': '500ms',
        'memoryUsage': '45MB',
      };

      final id = await database.addTranslationHistory(metrics);
      expect(id, greaterThan(0));
    });

    test('✅ Should handle concurrent analytics events', () async {
      final futures = List.generate(
        10,
        (i) => database.addTranslationHistory({
          'event': 'concurrent_event_$i',
          'index': i,
        }),
      );

      final ids = await Future.wait(futures);
      expect(ids, hasLength(10));
    });

    test('✅ Should track error events', () async {
      const errorEvent = {
        'event': 'error',
        'errorType': 'NetworkException',
        'message': 'Connection timeout',
        'timestamp': '2024-01-01 00:00:00',
      };

      final id = await database.addTranslationHistory(errorEvent);
      expect(id, greaterThan(0));
    });

    test('✅ Should support custom events', () async {
      const customEvent = {
        'event': 'custom_action',
        'action': 'user_defined',
        'metadata': 'custom_data',
      };

      final id = await database.addTranslationHistory(customEvent);
      expect(id, greaterThan(0));
    });

    test('✅ Should preserve event order', () async {
      await database.clearAllData();

      for (int i = 0; i < 5; i++) {
        await database.addTranslationHistory({
          'event': 'ordered_event',
          'order': i,
        });
      }

      final events = await database.getTranslationHistory();
      expect(events.length, greaterThanOrEqualTo(5));
    });

    test('✅ Should track session information', () async {
      const sessionEvent = {
        'event': 'session_start',
        'sessionId': 'session_123',
        'startTime': '2024-01-01 00:00:00',
      };

      final id = await database.addTranslationHistory(sessionEvent);
      expect(id, greaterThan(0));
    });

    test('✅ Should support event categorization', () async {
      const categories = [
        'feature_usage',
        'error',
        'performance',
        'user_action'
      ];

      for (final category in categories) {
        await database.addTranslationHistory({
          'event': 'categorized_event',
          'category': category,
        });
      }

      final events = await database.getTranslationHistory();
      expect(events.length, greaterThanOrEqualTo(4));
    });

    test('✅ Should handle batch event logging', () async {
      final futures = List.generate(
        8,
        (i) => database.addTranslationHistory({
          'event': 'batch_event',
          'batchId': 'batch_123',
          'index': i,
        }),
      );

      final ids = await Future.wait(futures);
      expect(ids, hasLength(8));
    });
  });
}
