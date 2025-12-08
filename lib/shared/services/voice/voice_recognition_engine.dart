/// 语音识别引擎的抽象接口
///
/// 支持多种语音识别后端（科大讯飞、腾讯云、Google、本地等）
/// 设计遵循策略模式，允许灵活切换实现
abstract class VoiceRecognitionEngine {
  /// 获取引擎名称
  String get name;

  /// 获取引擎优先级（数值越大优先级越高）
  int get priority;

  /// 初始化引擎
  ///
  /// 这个方法会处理权限请求、资源初始化等
  /// 返回 true 表示初始化成功，false 表示失败
  Future<bool> initialize();

  /// 检查引擎是否可用
  ///
  /// 检查内容包括：
  /// - 权限是否已授予
  /// - 网络连接（如果需要）
  /// - 引擎资源是否准备好
  Future<bool> isAvailable();

  /// 开始录音并识别语音
  ///
  /// 参数：
  /// - [language] 识别的语言代码（'en', 'zh', 'ug'）
  /// - [onPartialResult] 识别中间结果回调
  /// - [onFinalResult] 最终识别结果回调
  /// - [onError] 错误回调
  ///
  /// 返回 true 表示成功开始录音
  Future<bool> startListening({
    required String language,
    required Function(String) onPartialResult,
    required Function(String) onFinalResult,
    required Function(String) onError,
  });

  /// 停止录音并返回识别结果
  ///
  /// 返回识别得到的文本
  Future<String> stopListening();

  /// 取消录音
  ///
  /// 会清空当前录音数据
  Future<void> cancel();

  /// 释放引擎资源
  ///
  /// 应该在应用关闭或不再使用时调用
  Future<void> dispose();

  /// 检查设备是否支持此引擎
  ///
  /// 返回 true 表示设备支持
  Future<bool> isSupported();
}

/// 本地语音识别引擎（使用speech_to_text包）
///
/// 特点：
/// - 离线可用（取决于系统支持）
/// - 无需API密钥
/// - 识别准确度一般
/// - 作为备用方案
class LocalVoiceRecognitionEngine implements VoiceRecognitionEngine {
  bool _isListening = false;
  String _recognizedText = '';

  // 模拟的语言支持
  static const Map<String, String> _languageMap = {
    'en': 'en-US',
    'zh': 'zh-CN',
    'ug': 'ug-CN', // 维吾尔语
  };

  @override
  String get name => 'LocalVoiceRecognition';

  @override
  int get priority => 50;

  @override
  Future<bool> initialize() async {
    try {
      // 在实际应用中，这里会初始化speech_to_text包
      // 演示版本直接返回成功
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // 在实际应用中，这里会检查麦克风权限和设备支持
      // 演示版本直接返回成功
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> startListening({
    required String language,
    required Function(String) onPartialResult,
    required Function(String) onFinalResult,
    required Function(String) onError,
  }) async {
    try {
      if (!_languageMap.containsKey(language)) {
        onError('Unsupported language: $language');
        return false;
      }

      _isListening = true;
      _recognizedText = '';

      // 模拟语音识别过程
      // 在实际应用中，这里会使用speech_to_text包来处理真实的语音输入

      // 模拟中间结果
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isListening) {
          onPartialResult('正在识别...');
        }
      });

      // 模拟最终结果
      Future.delayed(const Duration(seconds: 2), () {
        if (_isListening) {
          _recognizedText = '模拟识别的文本';
          onFinalResult(_recognizedText);
        }
      });

      return true;
    } catch (e) {
      onError('Error starting voice recognition: $e');
      return false;
    }
  }

  @override
  Future<String> stopListening() async {
    _isListening = false;
    return _recognizedText;
  }

  @override
  Future<void> cancel() async {
    _isListening = false;
    _recognizedText = '';
  }

  @override
  Future<void> dispose() async {
    _isListening = false;
    _recognizedText = '';
  }

  @override
  Future<bool> isSupported() async {
    // 在实际应用中，检查设备是否支持语音识别
    return true;
  }
}

/// 语音识别异常
class VoiceRecognitionException implements Exception {
  final String message;
  final dynamic originalException;

  VoiceRecognitionException(
    this.message, {
    this.originalException,
  });

  @override
  String toString() => message;
}

/// 麦克风权限异常
class MicrophonePermissionException implements Exception {
  final String message;

  MicrophonePermissionException(this.message);

  @override
  String toString() => message;
}

/// 不支持的语言异常
class UnsupportedLanguageException implements Exception {
  final String language;
  final String message;

  UnsupportedLanguageException(this.language, this.message);

  @override
  String toString() => message;
}

/// 语音识别超时异常
class VoiceRecognitionTimeoutException implements Exception {
  final String message;

  VoiceRecognitionTimeoutException(this.message);

  @override
  String toString() => message;
}
