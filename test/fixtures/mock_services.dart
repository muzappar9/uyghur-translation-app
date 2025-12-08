import 'package:flutter_test/flutter_test.dart';

// 简化的 Mock 基类 - 不使用 mockito，直接实现接口
abstract class MockBase {}

// 翻译引擎接口定义
abstract class TranslationEngine {
  String get name;
  Future<bool> isSupported(String sourceLanguage, String targetLanguage);
  Future<String> translate(
      String text, String sourceLanguage, String targetLanguage);
  Future<void> initialize();
  Future<void> dispose();
}

// 语音识别引擎接口定义
abstract class VoiceRecognitionEngine {
  String get name;
  List<String> get supportedLanguages;
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Stream<String> listen(String languageCode);
  Future<void> stopListening();
  Future<void> initialize();
  Future<void> dispose();
}

// OCR 识别引擎接口定义
abstract class OCRRecognitionEngine {
  String get name;
  List<String> get supportedLanguages;
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<String> recognizeFromFile(String filePath);
  Future<String> recognizeFromBytes(List<int> bytes);
  Future<void> initialize();
  Future<void> dispose();
}

// 翻译管理器接口定义
abstract class TranslationManager {
  Future<String> translate(
      String text, String sourceLanguage, String targetLanguage);
  Future<bool> isLanguagePairSupported(
      String sourceLanguage, String targetLanguage);
  Future<void> dispose();
}

// 语音识别管理器接口定义
abstract class VoiceRecognitionManager {
  List<String> get supportedLanguages;
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Stream<String> listen(String languageCode);
  Future<void> stopListening();
  Future<void> dispose();
}

// OCR 识别管理器接口定义
abstract class OCRRecognitionManager {
  List<String> get supportedLanguages;
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<String> recognizeFromFile(String filePath);
  Future<String> recognizeFromBytes(List<int> bytes);
  Future<void> dispose();
}

// 数据库服务接口定义
abstract class IsarDatabaseService {
  Future<void> initialize();
  Future<void> dispose();
  Future<int> addTranslationHistory(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getTranslationHistory();
  Future<void> clearAllData();
}

/// 翻译引擎 Mock
class MockTranslationEngine implements TranslationEngine {
  @override
  String get name => 'MockTranslationEngine';

  @override
  Future<bool> isSupported(String sourceLanguage, String targetLanguage) async {
    return true;
  }

  @override
  Future<String> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    return 'Translated: $text';
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

/// 翻译引擎 Mock - 失败版本
class MockFailingTranslationEngine implements TranslationEngine {
  @override
  String get name => 'MockFailingTranslationEngine';

  @override
  Future<bool> isSupported(String sourceLanguage, String targetLanguage) async {
    return true;
  }

  @override
  Future<String> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    throw Exception('Translation failed');
  }

  @override
  Future<void> initialize() async {
    throw Exception('Initialization failed');
  }

  @override
  Future<void> dispose() async {}
}

/// 语音识别引擎 Mock
class MockVoiceRecognitionEngine implements VoiceRecognitionEngine {
  @override
  String get name => 'MockVoiceRecognitionEngine';

  @override
  List<String> get supportedLanguages => ['ug', 'zh', 'en', 'tr'];

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Stream<String> listen(String languageCode) =>
      Stream.value('Recognized: test speech');

  @override
  Future<void> stopListening() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

/// 语音识别引擎 Mock - 权限拒绝版本
class MockPermissionDeniedVoiceEngine implements VoiceRecognitionEngine {
  @override
  String get name => 'MockPermissionDeniedVoiceEngine';

  @override
  List<String> get supportedLanguages => ['ug', 'zh', 'en', 'tr'];

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Stream<String> listen(String languageCode) =>
      Stream.error(Exception('Permission denied'));

  @override
  Future<void> stopListening() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

/// OCR 识别引擎 Mock
class MockOCRRecognitionEngine implements OCRRecognitionEngine {
  @override
  String get name => 'MockOCRRecognitionEngine';

  @override
  List<String> get supportedLanguages => ['ug', 'zh', 'en', 'tr'];

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String> recognizeFromFile(String filePath) async =>
      'Recognized text from file';

  @override
  Future<String> recognizeFromBytes(List<int> bytes) async =>
      'Recognized text from bytes';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}

/// OCR 识别引擎 Mock - 权限拒绝版本
class MockPermissionDeniedOCREngine implements OCRRecognitionEngine {
  @override
  String get name => 'MockPermissionDeniedOCREngine';

  @override
  List<String> get supportedLanguages => ['ug', 'zh', 'en', 'tr'];

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<String> recognizeFromFile(String filePath) async =>
      throw Exception('Permission denied');

  @override
  Future<String> recognizeFromBytes(List<int> bytes) async =>
      throw Exception('Permission denied');

  @override
  Future<void> initialize() async {
    throw Exception('Initialization failed');
  }

  @override
  Future<void> dispose() async {}
}

/// 数据库服务 Mock
class MockIsarDatabaseService implements IsarDatabaseService {
  final Map<String, List<dynamic>> _collections = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async => _collections.clear();

  @override
  Future<int> addTranslationHistory(Map<String, dynamic> data) async {
    _collections.putIfAbsent('translation_history', () => []);
    _collections['translation_history']!.add(data);
    return _collections['translation_history']!.length;
  }

  @override
  Future<List<Map<String, dynamic>>> getTranslationHistory() async {
    final list = _collections['translation_history'] ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> clearAllData() async => _collections.clear();
}

/// 测试 Fixtures 工厂类
class TestFixtures {
  /// 创建 Mock 翻译引擎
  static MockTranslationEngine createMockTranslationEngine() {
    return MockTranslationEngine();
  }

  /// 创建失败的 Mock 翻译引擎
  static MockFailingTranslationEngine createMockFailingTranslationEngine() {
    return MockFailingTranslationEngine();
  }

  /// 创建 Mock 语音识别引擎
  static MockVoiceRecognitionEngine createMockVoiceEngine() {
    return MockVoiceRecognitionEngine();
  }

  /// 创建权限拒绝的 Mock 语音引擎
  static MockPermissionDeniedVoiceEngine
      createMockPermissionDeniedVoiceEngine() {
    return MockPermissionDeniedVoiceEngine();
  }

  /// 创建 Mock OCR 引擎
  static MockOCRRecognitionEngine createMockOCREngine() {
    return MockOCRRecognitionEngine();
  }

  /// 创建权限拒绝的 Mock OCR 引擎
  static MockPermissionDeniedOCREngine createMockPermissionDeniedOCREngine() {
    return MockPermissionDeniedOCREngine();
  }

  /// 创建 Mock 数据库服务
  static MockIsarDatabaseService createMockDatabaseService() {
    return MockIsarDatabaseService();
  }
}
