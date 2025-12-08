import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/features/translation/domain/entities/translation.dart';

void main() {
  group('Translation Entity', () {
    test('should create a valid Translation object', () {
      final translation = Translation(
        id: '1',
        sourceText: 'Hello',
        targetText: 'ياخشىمۇسىز',
        sourceLang: 'en',
        targetLang: 'ug',
        timestamp: DateTime.parse('2025-12-06T12:00:00'),
        isFavorite: true,
        notes: 'Greeting',
      );
      expect(translation.id, '1');
      expect(translation.sourceText, 'Hello');
      expect(translation.targetText, 'ياخشىمۇسىز');
      expect(translation.sourceLang, 'en');
      expect(translation.targetLang, 'ug');
      expect(translation.isFavorite, true);
      expect(translation.notes, 'Greeting');
    });

    test('should support copyWith', () {
      final translation = Translation(
        id: '1',
        sourceText: 'Hello',
        targetText: 'ياخشىمۇسىز',
        sourceLang: 'en',
        targetLang: 'ug',
        timestamp: DateTime.now(),
      );
      final updated = translation.copyWith(isFavorite: true);
      expect(updated.isFavorite, true);
      expect(updated.id, translation.id);
    });
  });

  group('TranslationRequest Entity', () {
    test('should create a valid TranslationRequest object', () {
      const request = TranslationRequest(
        text: 'Hello',
        sourceLang: 'en',
        targetLang: 'ug',
      );
      expect(request.text, 'Hello');
      expect(request.sourceLang, 'en');
      expect(request.targetLang, 'ug');
    });
  });

  group('AppState Entity', () {
    test('should create a valid AppState object', () {
      const state = AppState();
      expect(state.currentLanguage, 'zh');
      expect(state.isDarkMode, false);
      expect(state.isInitialized, false);
    });

    test('should support copyWith', () {
      const state = AppState();
      final updated = state.copyWith(isDarkMode: true);
      expect(updated.isDarkMode, true);
    });
  });
}
