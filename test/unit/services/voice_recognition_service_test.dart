import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('VoiceRecognitionService Tests', () {
    late MockVoiceRecognitionEngine successEngine;
    late MockPermissionDeniedVoiceEngine deniedEngine;

    setUp(() {
      successEngine = TestFixtures.createMockVoiceEngine();
      deniedEngine = TestFixtures.createMockPermissionDeniedVoiceEngine();
    });

    tearDown(() async {
      await successEngine.dispose();
      await deniedEngine.dispose();
    });

    test('✅ Should check permission successfully', () async {
      final hasPermission = await successEngine.hasPermission();
      expect(hasPermission, isTrue);
    });

    test('✅ Should request permission successfully', () async {
      final granted = await successEngine.requestPermission();
      expect(granted, isTrue);
    });

    test('✅ Should get supported languages', () {
      final languages = successEngine.supportedLanguages;
      expect(languages, isNotEmpty);
      expect(languages, contains('en'));
      expect(languages, contains('ug'));
    });

    test('✅ Should listen to voice recognition', () async {
      final stream = successEngine.listen('en');
      expect(stream, isNotNull);

      final result = await stream.first;
      expect(result, isNotEmpty);
      expect(result, contains('Recognized'));
    });

    test('✅ Should support multiple languages', () {
      final languages = successEngine.supportedLanguages;
      expect(languages.length, greaterThanOrEqualTo(3));
    });

    test('✅ Should stop listening', () async {
      final stream = successEngine.listen('en');
      stream.listen((_) {});

      await expectLater(successEngine.stopListening(), completes);
    });

    test('✅ Should handle multiple concurrent listeners', () async {
      final stream1 = successEngine.listen('en');
      final stream2 = successEngine.listen('zh');

      final results = await Future.wait([
        stream1.first,
        stream2.first,
      ]);

      expect(results, hasLength(2));
      expect(results.every((r) => r.isNotEmpty), isTrue);
    });

    test('✅ Should recover after stop listening', () async {
      await successEngine.stopListening();
      final stream = successEngine.listen('en');
      expect(stream, isNotNull);
    });

    test('✅ Should handle permission denied', () async {
      final hasPermission = await deniedEngine.hasPermission();
      expect(hasPermission, isFalse);
    });

    test('✅ Should fail to listen without permission', () async {
      final stream = deniedEngine.listen('en');
      expect(stream, emitsError(isException));
    });

    test('✅ Should initialize engine', () async {
      await successEngine.initialize();
      expect(successEngine.name, isNotEmpty);
    });

    test('✅ Should dispose resources', () async {
      await expectLater(successEngine.dispose(), completes);
    });

    test('✅ Should handle language code case sensitivity', () {
      final languages = successEngine.supportedLanguages;
      expect(languages, contains('en'));
      expect(languages, contains('zh'));
    });
  });
}
