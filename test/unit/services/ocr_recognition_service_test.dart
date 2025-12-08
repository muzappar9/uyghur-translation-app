import 'package:flutter_test/flutter_test.dart';
import '../../fixtures/mock_services.dart';

void main() {
  group('OCRRecognitionService Tests', () {
    late MockOCRRecognitionEngine successEngine;
    late MockPermissionDeniedOCREngine deniedEngine;

    setUp(() {
      successEngine = TestFixtures.createMockOCREngine();
      deniedEngine = TestFixtures.createMockPermissionDeniedOCREngine();
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
      expect(languages, contains('zh'));
    });

    test('✅ Should recognize text from file', () async {
      final result =
          await successEngine.recognizeFromFile('/path/to/image.png');
      expect(result, isNotEmpty);
      expect(result, contains('Recognized'));
    });

    test('✅ Should recognize text from bytes', () async {
      final bytes = List<int>.generate(100, (i) => i);
      final result = await successEngine.recognizeFromBytes(bytes);
      expect(result, isNotEmpty);
      expect(result, contains('Recognized'));
    });

    test('✅ Should handle different image formats', () async {
      final formats = ['png', 'jpg', 'gif', 'bmp'];

      for (final format in formats) {
        final result =
            await successEngine.recognizeFromFile('/path/image.$format');
        expect(result, isNotEmpty);
      }
    });

    test('✅ Should handle large image data', () async {
      final largeBytes = List<int>.generate(10000, (i) => i % 256);
      final result = await successEngine.recognizeFromBytes(largeBytes);
      expect(result, isNotEmpty);
    });

    test('✅ Should handle concurrent recognition', () async {
      final futures = List.generate(
        5,
        (i) => successEngine.recognizeFromFile('/path/image$i.png'),
      );

      final results = await Future.wait(futures);
      expect(results, hasLength(5));
      expect(results.every((r) => r.isNotEmpty), isTrue);
    });

    test('✅ Should handle mixed file and bytes operations', () async {
      final fileResult = await successEngine.recognizeFromFile('/image.png');
      final bytesResult = await successEngine.recognizeFromBytes([1, 2, 3]);

      expect(fileResult, isNotEmpty);
      expect(bytesResult, isNotEmpty);
    });

    test('✅ Should handle permission denied', () async {
      final hasPermission = await deniedEngine.hasPermission();
      expect(hasPermission, isFalse);
    });

    test('✅ Should fail to recognize without permission', () async {
      expect(
        () => deniedEngine.recognizeFromFile('/path/image.png'),
        throwsException,
      );
    });

    test('✅ Should initialize engine', () async {
      await successEngine.initialize();
      expect(successEngine.name, isNotEmpty);
    });

    test('✅ Should dispose resources', () async {
      await expectLater(successEngine.dispose(), completes);
    });

    test('✅ Should verify language support', () {
      final languages = successEngine.supportedLanguages;
      expect(languages, isNotEmpty);
      expect(languages.length, greaterThanOrEqualTo(3));
    });
  });
}
