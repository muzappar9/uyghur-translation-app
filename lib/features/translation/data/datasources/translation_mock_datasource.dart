/// Mock 翻译数据源
class TranslationMockDatasource {
  /// 模拟翻译数据库
  static const Map<String, Map<String, String>> mockTranslations = {
    'hello': {
      'zh': '你好',
      'ug': 'سلام',
      'en': 'Hello',
    },
    'good morning': {
      'zh': '早上好',
      'ug': 'خەيسەتسىز',
      'en': 'Good morning',
    },
    'thank you': {
      'zh': '谢谢',
      'ug': 'رەھمەت',
      'en': 'Thank you',
    },
    'good night': {
      'zh': '晚安',
      'ug': 'خەيلەساتسىز',
      'en': 'Good night',
    },
    'welcome': {
      'zh': '欢迎',
      'ug': 'خوش كەلدىڭىز',
      'en': 'Welcome',
    },
  };

  /// 执行 Mock 翻译
  static Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    final key = text.toLowerCase();
    if (mockTranslations.containsKey(key)) {
      return mockTranslations[key]![targetLang] ?? '翻译结果不可用';
    }

    return '【Mock】"$text" 的 $targetLang 翻译';
  }
}
