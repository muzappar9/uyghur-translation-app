/// 路由名称常量
class RouteNames {
  // 主要路由
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String translateResult = '/translate-result';
  static const String conversation = '/conversation';
  static const String voiceInput = '/voice-input';
  static const String camera = '/camera';
  static const String ocrResult = '/ocr-result';
  static const String dictionary = '/dictionary';
  static const String dictionaryDetail = '/dictionary/:id';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String languageSwitcher = '/language-switcher';

  // 子路由前缀
  static const String dictionaryBase = '/dictionary';

  // 页面数据传递键
  static const String translationDataKey = 'translationData';
  static const String wordIdKey = 'wordId';
}
