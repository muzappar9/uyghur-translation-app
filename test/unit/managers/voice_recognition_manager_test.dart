import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('MockVoiceRecognitionEngine Tests', () {
    late MockVoiceRecognitionEngine engine;

    setUp(() {
      engine = TestFixtures.createMockVoiceEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('✅ Should initialize successfully', () async {
      await engine.initialize();
      expect(engine.name, equals('MockVoiceRecognitionEngine'));
    });

    test('✅ Should verify engine name', () {
      expect(engine.name, isNotEmpty);
      expect(engine.name, contains('Voice'));
    });

    test('✅ Should get supported languages', () {
      final languages = engine.supportedLanguages;
      expect(languages, isNotEmpty);
      expect(languages, contains('en'));
      expect(languages, contains('ug'));
      expect(languages, contains('zh'));
    });

    test('✅ Should have permission by default', () async {
      final hasPermission = await engine.hasPermission();
      expect(hasPermission, isTrue);
    });

    test('✅ Should request permission successfully', () async {
      final granted = await engine.requestPermission();
      expect(granted, isTrue);
    });

    test('✅ Should listen to voice recognition', () async {
      final stream = engine.listen('en');
      expect(stream, isNotNull);

      final result = await stream.first;
      expect(result, isNotEmpty);
      expect(result, contains('Recognized'));
    });

    test('✅ Should support multiple language listening', () {
      final languages = engine.supportedLanguages;
      for (final lang in languages) {
        final stream = engine.listen(lang);
        expect(stream, isNotNull);
        expect(stream, isA<Stream<String>>());
      }
    });

    test('✅ Should stop listening without errors', () async {
      final stream = engine.listen('en');
      stream.listen((_) {});

      await expectLater(engine.stopListening(), completes);
    });

    test('✅ Should handle concurrent listen operations', () async {
      final stream1 = engine.listen('en');
      final stream2 = engine.listen('zh');

      final r1 = stream1.first;
      final r2 = stream2.first;

      final results = await Future.wait([r1, r2]);
      expect(results, hasLength(2));
      expect(results.every((r) => r.isNotEmpty), isTrue);
    });

    test('✅ Should dispose resources', () async {
      await expectLater(engine.dispose(), completes);
    });

    test('✅ Should support ug language', () {
      final languages = engine.supportedLanguages;
      expect(languages, contains('ug'));
    });

    test('✅ Should recover after stop listening', () async {
      await engine.stopListening();
      final stream = engine.listen('en');
      expect(stream, isNotNull);
    });

    test('✅ Should verify all supported languages', () {
      final languages = engine.supportedLanguages;
      final expected = ['ug', 'zh', 'en', 'tr'];
      expect(languages, equals(expected));
    });
  });

  group('MockPermissionDeniedVoiceEngine Tests', () {
    late MockPermissionDeniedVoiceEngine engine;

    setUp(() {
      engine = TestFixtures.createMockPermissionDeniedVoiceEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('✅ Should reject permission', () async {
      final hasPermission = await engine.hasPermission();
      expect(hasPermission, isFalse);
    });

    test('✅ Should fail to request permission', () async {
      final granted = await engine.requestPermission();
      expect(granted, isFalse);
    });

    test('✅ Should throw on listen', () async {
      final stream = engine.listen('en');
      expect(stream, emitsError(isException));
    });

    test('✅ Should handle permission denied gracefully', () async {
      final hasPermission = await engine.hasPermission();
      expect(hasPermission, isFalse);
    });

    test('✅ Should verify name', () {
      expect(engine.name, equals('MockPermissionDeniedVoiceEngine'));
    });

    test('✅ Should have supported languages list', () {
      final languages = engine.supportedLanguages;
      expect(languages, isNotEmpty);
    });

    test('✅ Should dispose resources', () async {
      await expectLater(engine.dispose(), completes);
    });

    test('✅ Should handle concurrent listen failures', () async {
      final stream1 = engine.listen('en');
      final stream2 = engine.listen('zh');

      expect(stream1, emitsError(isException));
      expect(stream2, emitsError(isException));
    });
  });
}
