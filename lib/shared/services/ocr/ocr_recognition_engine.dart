/// OCR 识别引擎的抽象接口
///
/// 支持多种 OCR 后端（Google ML Kit、腾讯云、百度等）
/// 设计遵循策略模式，允许灵活切换实现
abstract class OCRRecognitionEngine {
  /// 获取引擎名称
  String get name;

  /// 获取引擎优先级（数值越大优先级越高）
  int get priority;

  /// 初始化引擎
  ///
  /// 这个方法会处理资源初始化等
  /// 返回 true 表示初始化成功，false 表示失败
  Future<bool> initialize();

  /// 检查引擎是否可用
  ///
  /// 检查内容包括：
  /// - 权限是否已授予
  /// - 网络连接（如果需要）
  /// - 引擎资源是否准备好
  Future<bool> isAvailable();

  /// 从图片文件识别文本
  ///
  /// 参数：
  /// - [imagePath] 图片文件路径
  /// - [language] 识别的语言代码（'en', 'zh', 'ug'）
  ///
  /// 返回识别得到的文本
  /// 如果识别失败，抛出 OCRRecognitionException
  Future<String> recognizeFromFile(
    String imagePath, {
    String language = 'auto',
  });

  /// 从图片字节识别文本
  ///
  /// 参数：
  /// - [imageBytes] 图片字节数据
  /// - [language] 识别的语言代码
  ///
  /// 返回识别得到的文本
  Future<String> recognizeFromBytes(
    List<int> imageBytes, {
    String language = 'auto',
  });

  /// 清理和释放引擎资源
  ///
  /// 应该在应用关闭或不再使用时调用
  Future<void> dispose();

  /// 检查设备是否支持此引擎
  ///
  /// 返回 true 表示设备支持
  Future<bool> isSupported();
}

/// 本地 OCR 识别引擎（使用 Google ML Kit）
///
/// 特点：
/// - 离线可用
/// - 无需 API 密钥
/// - 支持多种语言
/// - 识别准确度良好
class LocalOCRRecognitionEngine implements OCRRecognitionEngine {
  // 模拟识别结果缓存
  final Map<String, String> _recognitionCache = {};

  @override
  String get name => 'LocalOCRRecognition';

  @override
  int get priority => 50;

  @override
  Future<bool> initialize() async {
    try {
      // 在实际应用中，这里会初始化 Google ML Kit
      // 演示版本直接返回成功
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // 在实际应用中，这里会检查 ML Kit 是否可用
      // 演示版本直接返回成功
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> recognizeFromFile(
    String imagePath, {
    String language = 'auto',
  }) async {
    try {
      // 检查缓存
      if (_recognitionCache.containsKey(imagePath)) {
        return _recognitionCache[imagePath]!;
      }

      // 在实际应用中，这里会使用 Google ML Kit 识别图片
      // 演示版本返回模拟文本
      final recognizedText = _simulateOCR(imagePath, language);

      // 缓存结果
      _recognitionCache[imagePath] = recognizedText;

      return recognizedText;
    } catch (e) {
      throw OCRRecognitionException(
        'Failed to recognize text from file: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<String> recognizeFromBytes(
    List<int> imageBytes, {
    String language = 'auto',
  }) async {
    try {
      // 在实际应用中，这里会使用 Google ML Kit 识别字节数据
      // 演示版本返回模拟文本
      final recognizedText =
          _simulateOCR('bytes_${imageBytes.length}', language);
      return recognizedText;
    } catch (e) {
      throw OCRRecognitionException(
        'Failed to recognize text from bytes: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> dispose() async {
    try {
      _recognitionCache.clear();
      // 在实际应用中，这里会释放 ML Kit 资源
    } catch (e) {
      // 忽略清理错误
    }
  }

  @override
  Future<bool> isSupported() async {
    // 在实际应用中，检查设备是否支持 ML Kit
    return true;
  }

  // Private methods

  /// 模拟 OCR 识别
  /// 在实际应用中，这会被替换为真实的 ML Kit 调用
  String _simulateOCR(String imagePath, String language) {
    // 模拟识别结果
    if (imagePath.contains('test')) {
      return 'Test recognized text from image';
    }

    return '''مرحبا بك في تطبيق الترجمة
Welcome to translation app
你好，欢迎使用翻译应用''';
  }
}

/// OCR 识别异常
class OCRRecognitionException implements Exception {
  final String message;
  final dynamic originalException;

  OCRRecognitionException(
    this.message, {
    this.originalException,
  });

  @override
  String toString() => message;
}

/// 相机权限异常
class CameraPermissionException implements Exception {
  final String message;

  CameraPermissionException(this.message);

  @override
  String toString() => message;
}

/// 不支持的图片格式异常
class UnsupportedImageFormatException implements Exception {
  final String format;
  final String message;

  UnsupportedImageFormatException(this.format, this.message);

  @override
  String toString() => message;
}

/// OCR 识别超时异常
class OCRRecognitionTimeoutException implements Exception {
  final String message;

  OCRRecognitionTimeoutException(this.message);

  @override
  String toString() => message;
}

/// 图片处理异常
class ImageProcessingException implements Exception {
  final String message;

  ImageProcessingException(this.message);

  @override
  String toString() => message;
}
