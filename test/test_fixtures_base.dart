import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/features/translation/domain/entities/translation.dart';

/// 测试基础框架 - 提供通用mock和助手
class TestFixtures {
  static Widget createTestApp(Widget home) {
    return ProviderScope(
      child: MaterialApp(
        home: home,
        localizationsDelegates: const [],
      ),
    );
  }

  static Translation createMockTranslation({
    String id = 'test-1',
    String sourceText = 'Hello',
    String targetText = 'ياخشىمۇسىز',
    String sourceLang = 'en',
    String targetLang = 'ug',
    bool isFavorite = false,
  }) {
    return Translation(
      id: id,
      sourceText: sourceText,
      targetText: targetText,
      sourceLang: sourceLang,
      targetLang: targetLang,
      timestamp: DateTime.now(),
      isFavorite: isFavorite,
    );
  }

  static List<Translation> createMockTranslationList(int count) {
    return List.generate(
      count,
      (i) => createMockTranslation(
        id: 'test-$i',
        sourceText: 'Text $i',
        targetText: 'ترجمة $i',
      ),
    );
  }

  static AppState createMockAppState({
    String currentLanguage = 'zh',
    String sourceLanguage = 'en',
    String targetLanguage = 'ug',
    bool isDarkMode = false,
    bool isInitialized = true,
    bool isOnline = true,
  }) {
    return AppState(
      currentLanguage: currentLanguage,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isDarkMode: isDarkMode,
      isInitialized: isInitialized,
      isOnline: isOnline,
    );
  }
}

/// 单元测试中常用的setUp/tearDown辅助
mixin TestHelper {
  void setUpCommonTest() {
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  void tearDownCommonTest() {
    // 清理资源
  }
}
