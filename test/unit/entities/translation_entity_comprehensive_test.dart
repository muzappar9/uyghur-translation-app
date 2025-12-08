import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/features/translation/domain/entities/translation.dart';

void main() {
  group('翻译实体单元测试', () {
    test('创建有效的Translation实体', () {
      final translation = Translation(
        id: 'test-1',
        sourceText: 'Hello',
        targetText: 'ياخشىمۇسىز',
        sourceLang: 'en',
        targetLang: 'ug',
        timestamp: DateTime.now(),
      );
      expect(translation.id, 'test-1');
      expect(translation.sourceText, 'Hello');
      expect(translation.targetText, 'ياخشىمۇسىز');
      expect(translation.sourceLang, 'en');
      expect(translation.targetLang, 'ug');
      expect(translation.isFavorite, false);
    });

    test('支持copyWith方法', () {
      final translation = Translation(
        id: 'test-1',
        sourceText: 'Hello',
        targetText: 'ياخشىمۇسىز',
        sourceLang: 'en',
        targetLang: 'ug',
        timestamp: DateTime.now(),
      );
      final updated = translation.copyWith(isFavorite: true);
      expect(updated.isFavorite, true);
      expect(updated.id, translation.id);
      expect(updated.sourceText, translation.sourceText);
    });

    test('时间戳保持', () {
      final now = DateTime.now();
      final translation = Translation(
        id: '1',
        sourceText: 'test',
        targetText: 'تست',
        sourceLang: 'en',
        targetLang: 'ug',
        timestamp: now,
      );
      expect(translation.timestamp, now);
    });

    test('默认isFavorite为false', () {
      final translation = Translation(
        id: '1',
        sourceText: 'test',
        targetText: 'تست',
        sourceLang: 'en',
        targetLang: 'ug',
        timestamp: DateTime.now(),
      );
      expect(translation.isFavorite, false);
    });

    test('支持notes字段', () {
      final translation = Translation(
        id: '1',
        sourceText: 'test',
        targetText: 'تست',
        sourceLang: 'en',
        targetLang: 'ug',
        timestamp: DateTime.now(),
      );
      final withNotes = translation.copyWith(notes: '这是一个笔记');
      expect(withNotes.notes, '这是一个笔记');
    });
  });

  group('TranslationRequest实体单元测试', () {
    test('创建有效的TranslationRequest', () {
      const request = TranslationRequest(
        text: 'Hello world',
        sourceLang: 'en',
        targetLang: 'ug',
      );
      expect(request.text, 'Hello world');
      expect(request.sourceLang, 'en');
      expect(request.targetLang, 'ug');
    });

    test('支持copyWith方法', () {
      const request = TranslationRequest(
        text: 'Hello',
        sourceLang: 'en',
        targetLang: 'ug',
      );
      final updated = request.copyWith(targetLang: 'zh');
      expect(updated.targetLang, 'zh');
      expect(updated.text, 'Hello');
    });
  });

  group('AppState实体单元测试', () {
    test('创建默认AppState', () {
      const state = AppState();
      expect(state.currentLanguage, 'zh');
      expect(state.isDarkMode, false);
      expect(state.isInitialized, false);
    });

    test('创建自定义AppState', () {
      const state = AppState(
        isDarkMode: true,
        isInitialized: true,
      );
      expect(state.isDarkMode, true);
      expect(state.isInitialized, true);
    });

    test('支持copyWith方法', () {
      const state = AppState();
      final updated = state.copyWith(isDarkMode: true);
      expect(updated.isDarkMode, true);
      expect(updated.currentLanguage, 'zh');
    });

    test('语言设置更新', () {
      const state = AppState();
      final updated = state.copyWith(
        sourceLanguage: 'zh',
        targetLanguage: 'en',
      );
      expect(updated.sourceLanguage, 'zh');
      expect(updated.targetLanguage, 'en');
    });
  });

  group('翻译列表操作单元测试', () {
    test('创建翻译列表', () {
      final translations = List.generate(
        5,
        (i) => Translation(
          id: 'test-$i',
          sourceText: 'Text $i',
          targetText: 'ترجمة $i',
          sourceLang: 'en',
          targetLang: 'ug',
          timestamp: DateTime.now(),
        ),
      );
      expect(translations.length, 5);
      expect(translations.first.id, 'test-0');
      expect(translations.last.id, 'test-4');
    });

    test('翻译列表中的元素是独立的', () {
      final translations = List.generate(
        3,
        (i) => Translation(
          id: 'test-$i',
          sourceText: 'Text $i',
          targetText: 'ترجمة $i',
          sourceLang: 'en',
          targetLang: 'ug',
          timestamp: DateTime.now(),
        ),
      );
      final first = translations[0];
      final second = translations[1];
      expect(first.id, isNot(second.id));
      expect(first.sourceText, isNot(second.sourceText));
    });

    test('翻译列表可以被筛选', () {
      final translations = List.generate(
        5,
        (i) => Translation(
          id: 'test-$i',
          sourceText: 'Text $i',
          targetText: 'ترجمة $i',
          sourceLang: 'en',
          targetLang: 'ug',
          timestamp: DateTime.now(),
        ),
      );
      final favorites = translations
          .map((t) => t.copyWith(isFavorite: true))
          .toList();
      expect(favorites.every((t) => t.isFavorite), true);
    });
  });
}
