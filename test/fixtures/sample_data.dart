/// 翻译测试数据
final sampleTranslations = [
  {
    'id': '1',
    'sourceText': 'Hello',
    'targetText': '你好',
    'sourceLanguage': 'en',
    'targetLanguage': 'zh',
    'sourceType': 'text',
    'engine': 'mock',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '2',
    'sourceText': 'Good morning',
    'targetText': '早上好',
    'sourceLanguage': 'en',
    'targetLanguage': 'zh',
    'sourceType': 'voice',
    'engine': 'mock',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '3',
    'sourceText': 'Thank you',
    'targetText': '谢谢',
    'sourceLanguage': 'en',
    'targetLanguage': 'zh',
    'sourceType': 'text',
    'engine': 'mock',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
];

/// 语音识别测试数据
final sampleVoiceResults = [
  {
    'id': '1',
    'text': '我想翻译这句话',
    'language': 'ug',
    'confidence': 0.95,
    'duration': 2.5,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '2',
    'text': 'Hello world',
    'language': 'en',
    'confidence': 0.92,
    'duration': 1.2,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '3',
    'text': '你好吗',
    'language': 'zh',
    'confidence': 0.98,
    'duration': 1.5,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
];

/// OCR 识别测试数据
final sampleOCRResults = [
  {
    'id': '1',
    'text': 'Uyghur text from image',
    'language': 'ug',
    'confidence': 0.88,
    'imageSize': '1024x768',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '2',
    'text': 'English text from image',
    'language': 'en',
    'confidence': 0.91,
    'imageSize': '1920x1080',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '3',
    'text': '图片中的中文文本',
    'language': 'zh',
    'confidence': 0.89,
    'imageSize': '800x600',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
];

/// 待同步队列测试数据
final sampleSyncQueueItems = [
  {
    'id': '1',
    'type': 'translation',
    'operationData': '{"sourceText":"Hello","targetLanguage":"zh"}',
    'isCompleted': false,
    'retryCount': 0,
    'createdAt': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '2',
    'type': 'voice',
    'operationData': '{"audioPath":"/path/to/audio.wav"}',
    'isCompleted': false,
    'retryCount': 1,
    'createdAt': DateTime.now()
        .subtract(const Duration(hours: 1))
        .millisecondsSinceEpoch,
  },
  {
    'id': '3',
    'type': 'ocr',
    'operationData': '{"imagePath":"/path/to/image.png"}',
    'isCompleted': true,
    'retryCount': 0,
    'createdAt':
        DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
  },
];

/// 收藏项目测试数据
final sampleFavorites = [
  {
    'id': '1',
    'type': 'translation',
    'title': 'Hello Translation',
    'description': 'English to Chinese',
    'content': '{"sourceText":"Hello","targetText":"你好"}',
    'tags': '["common","greeting"]',
    'notes': 'Basic greeting',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '2',
    'type': 'voice',
    'title': 'Voice Sample',
    'description': 'Uyghur pronunciation',
    'content': '{"text":"Assalammualaikum"}',
    'tags': '["uyghur","audio"]',
    'notes': 'Islamic greeting',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '3',
    'type': 'ocr',
    'title': 'Document OCR',
    'description': 'Chinese document',
    'content': '{"text":"文档内容"}',
    'tags': '["document","chinese"]',
    'notes': 'Important document',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
];

/// 分析事件测试数据
final sampleAnalyticsEvents = [
  {
    'id': '1',
    'type': 'translation_started',
    'userId': 'user123',
    'sessionId': 'session123',
    'deviceId': 'device123',
    'metadata': '{"sourceLanguage":"en","targetLanguage":"zh"}',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '2',
    'type': 'voice_recognized',
    'userId': 'user123',
    'sessionId': 'session123',
    'deviceId': 'device123',
    'metadata': '{"language":"ug","confidence":0.95}',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  {
    'id': '3',
    'type': 'ocr_completed',
    'userId': 'user123',
    'sessionId': 'session123',
    'deviceId': 'device123',
    'metadata': '{"language":"zh","duration":2500}',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
];

/// 测试助手函数
class TestDataHelper {
  /// 获取翻译样本
  static Map<String, dynamic> getTranslationSample(int index) {
    return sampleTranslations[index % sampleTranslations.length];
  }

  /// 获取语音样本
  static Map<String, dynamic> getVoiceSample(int index) {
    return sampleVoiceResults[index % sampleVoiceResults.length];
  }

  /// 获取 OCR 样本
  static Map<String, dynamic> getOCRSample(int index) {
    return sampleOCRResults[index % sampleOCRResults.length];
  }

  /// 创建自定义翻译数据
  static Map<String, dynamic> createTranslation({
    String? sourceText,
    String? targetText,
    String sourceLanguage = 'en',
    String targetLanguage = 'zh',
    String sourceType = 'text',
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'sourceText': sourceText ?? 'Test text',
      'targetText': targetText ?? 'Test translation',
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'sourceType': sourceType,
      'engine': 'test',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 创建自定义语音识别数据
  static Map<String, dynamic> createVoiceResult({
    String? text,
    String language = 'en',
    double confidence = 0.9,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text ?? 'Test speech',
      'language': language,
      'confidence': confidence,
      'duration': 2.5,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 创建自定义 OCR 数据
  static Map<String, dynamic> createOCRResult({
    String? text,
    String language = 'en',
    double confidence = 0.9,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text ?? 'Test OCR text',
      'language': language,
      'confidence': confidence,
      'imageSize': '1024x768',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 创建自定义收藏项目
  static Map<String, dynamic> createFavorite({
    String type = 'translation',
    String? title,
    String? content,
    List<String>? tags,
  }) {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'title': title ?? 'Test $type',
      'description': 'Test description',
      'content': content ?? '{"test":"data"}',
      'tags': (tags ?? ['test']).toString(),
      'notes': 'Test notes',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
