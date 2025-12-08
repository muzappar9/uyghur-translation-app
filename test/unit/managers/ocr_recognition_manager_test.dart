import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('MockOCRRecognitionEngine Tests', () {
    late MockOCRRecognitionEngine engine;

    setUp(() {
      engine = TestFixtures.createMockOCREngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('✅ Should initialize successfully', () async {
      await engine.initialize();
      expect(engine.name, equals('MockOCRRecognitionEngine'));
    });

    test('✅ Should verify engine name', () {
      expect(engine.name, isNotEmpty);
      expect(engine.name, contains('OCR'));
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

    test('✅ Should recognize text from file', () async {
      final result = await engine.recognizeFromFile('/path/to/image.png');
      expect(result, isNotEmpty);
      expect(result, contains('Recognized'));
    });

    test('✅ Should recognize text from bytes', () async {
      final bytes = List<int>.generate(100, (i) => i);
      final result = await engine.recognizeFromBytes(bytes);
      expect(result, isNotEmpty);
      expect(result, contains('Recognized'));
    });

    test('✅ Should handle empty file path', () async {
      final result = await engine.recognizeFromFile('');
      expect(result, isNotEmpty);
    });

    test('✅ Should handle empty bytes', () async {
      final result = await engine.recognizeFromBytes([]);
      expect(result, isNotEmpty);
    });

    test('✅ Should handle large byte data', () async {
      final largeBytes = List<int>.generate(10000, (i) => i % 256);
      final result = await engine.recognizeFromBytes(largeBytes);
      expect(result, isNotEmpty);
    });

    test('✅ Should handle concurrent file recognition', () async {
      final futures = List.generate(
        5,
        (i) => engine.recognizeFromFile('/path/image$i.png'),
      );
      final results = await Future.wait(futures);
      expect(results, hasLength(5));
      expect(results.every((r) => r.isNotEmpty), isTrue);
    });

    test('✅ Should handle concurrent bytes recognition', () async {
      final futures = List.generate(
        5,
        (i) => engine.recognizeFromBytes(List.filled(1024, i)),
      );
      final results = await Future.wait(futures);
      expect(results, hasLength(5));
      expect(results.every((r) => r.isNotEmpty), isTrue);
    });

    test('✅ Should handle concurrent mixed operations', () async {
      final futures = [
        engine.recognizeFromFile('/image.png'),
        engine.recognizeFromBytes([1, 2, 3]),
        engine.hasPermission(),
        engine.recognizeFromFile('/photo.jpg'),
      ];
      final results = await Future.wait(futures);
      expect(results, isNotEmpty);
    });

    test('✅ Should dispose resources', () async {
      await expectLater(engine.dispose(), completes);
    });

    test('✅ Should support ug language', () {
      final languages = engine.supportedLanguages;
      expect(languages, contains('ug'));
    });

    test('✅ Should verify all supported languages', () {
      final languages = engine.supportedLanguages;
      final expected = ['ug', 'zh', 'en', 'tr'];
      expect(languages, equals(expected));
    });
  });

  group('MockPermissionDeniedOCREngine Tests', () {
    late MockPermissionDeniedOCREngine engine;

    setUp(() {
      engine = TestFixtures.createMockPermissionDeniedOCREngine();
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

    test('✅ Should throw on recognize from file', () async {
      expect(
        () => engine.recognizeFromFile('/path/to/image.png'),
        throwsException,
      );
    });

    test('✅ Should throw on recognize from bytes', () async {
      expect(
        () => engine.recognizeFromBytes([1, 2, 3]),
        throwsException,
      );
    });

    test('✅ Should throw on initialize', () async {
      expect(() => engine.initialize(), throwsException);
    });

    test('✅ Should verify name', () {
      expect(engine.name, equals('MockPermissionDeniedOCREngine'));
    });

    test('✅ Should have supported languages list', () {
      final languages = engine.supportedLanguages;
      expect(languages, isNotEmpty);
    });

    test('✅ Should dispose resources', () async {
      await expectLater(engine.dispose(), completes);
    });

    test('✅ Should handle permission denied gracefully', () async {
      final hasPermission = await engine.hasPermission();
      expect(hasPermission, isFalse);
    });

    test('✅ Should throw consistently on file recognition', () async {
      expect(
        () => engine.recognizeFromFile('/image1.png'),
        throwsException,
      );
      expect(
        () => engine.recognizeFromFile('/image2.jpg'),
        throwsException,
      );
    });
  });
}
