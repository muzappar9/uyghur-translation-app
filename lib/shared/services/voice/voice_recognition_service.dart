import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'voice_recognition_manager.dart';
import 'voice_recognition_engine.dart';

/// 语音识别服务
///
/// 提供高层次的语音识别功能，包括：
/// - 权限检查和请求
/// - 识别过程管理
/// - 错误处理和恢复
/// - 识别结果缓存
/// - 离线支持（待同步队列）
class VoiceRecognitionService {
  final VoiceRecognitionManager _manager;
  final Logger _logger = Logger();

  // 识别过程中的状态跟踪
  bool _isListening = false;
  String _recognitionResult = '';

  // 简单的内存缓存
  final Map<String, String> _cache = {};
  static const int _maxCacheSize = 50;

  VoiceRecognitionService(this._manager);

  /// 初始化语音识别服务
  ///
  /// 这会：
  /// 1. 初始化所有语音识别引擎
  /// 2. 请求麦克风权限
  /// 3. 验证设备支持
  Future<bool> initialize() async {
    try {
      _logger.i('[VoiceService] Initializing voice recognition service');

      final success = await _manager.initialize();
      if (!success) {
        _logger
            .e('[VoiceService] Failed to initialize voice recognition manager');
        return false;
      }

      _logger.i('[VoiceService] ✓ Voice recognition service initialized');
      return true;
    } catch (e) {
      _logger.e('[VoiceService] Error initializing: $e');
      return false;
    }
  }

  /// 开始语音识别
  ///
  /// 参数：
  /// - [language] 识别语言（'en', 'zh', 'ug'）
  /// - [onPartialResult] 识别中间结果回调
  /// - [onFinalResult] 最终识别结果回调
  /// - [onError] 错误回调
  /// - [timeout] 超时时间（默认30秒）
  Future<void> startRecognition({
    required String language,
    required Function(String) onPartialResult,
    required Function(String) onFinalResult,
    required Function(String) onError,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // 检查是否已在识别中
      if (_isListening) {
        onError('Already listening');
        return;
      }

      _logger.i(
          '[VoiceService] Starting voice recognition for language: $language');

      // 开始识别
      final success = await _manager.startListening(
        language: language,
        onPartialResult: (text) {
          _logger.d('[VoiceService] Partial result: $text');
          onPartialResult(text);
        },
        onFinalResult: (text) {
          _logger.i('[VoiceService] Final result: $text');
          _recognitionResult = text;

          // 缓存结果
          _cacheResult(language, text);

          onFinalResult(text);
        },
        onError: (error) {
          _logger.w('[VoiceService] Recognition error: $error');
          onError(error);
        },
        timeout: timeout,
      );

      if (!success) {
        _isListening = false;
        onError('Failed to start voice recognition');
      }
    } catch (e) {
      _isListening = false;
      _logger.e('[VoiceService] Error starting recognition: $e');
      onError('Failed to start recognition: $e');
    }
  }

  /// 停止语音识别
  ///
  /// 返回识别得到的文本
  Future<String> stopRecognition() async {
    try {
      if (!_isListening) {
        return _recognitionResult;
      }

      _logger.i('[VoiceService] Stopping voice recognition');

      final result = await _manager.stopListening();
      _isListening = false;
      _recognitionResult = result;

      _logger.i('[VoiceService] ✓ Recognition stopped, result: $result');
      return result;
    } catch (e) {
      _isListening = false;
      _logger.e('[VoiceService] Error stopping recognition: $e');
      return '';
    }
  }

  /// 取消语音识别
  Future<void> cancelRecognition() async {
    try {
      if (!_isListening) {
        return;
      }

      _logger.i('[VoiceService] Canceling voice recognition');

      await _manager.cancel();
      _isListening = false;
      _recognitionResult = '';

      _logger.i('[VoiceService] ✓ Recognition canceled');
    } catch (e) {
      _isListening = false;
      _logger.e('[VoiceService] Error canceling recognition: $e');
    }
  }

  /// 检查语音识别是否可用
  ///
  /// 检查内容：
  /// - 至少有一个可用引擎
  /// - 麦克风权限已授予
  /// - 设备支持语音识别
  Future<bool> isAvailable() async {
    try {
      return await _manager.isAvailable();
    } catch (e) {
      _logger.e('[VoiceService] Error checking availability: $e');
      return false;
    }
  }

  /// 获取所有可用的语音识别引擎
  Future<List<VoiceRecognitionEngine>> getAvailableEngines() async {
    try {
      return await _manager.getAvailableEngines();
    } catch (e) {
      _logger.e('[VoiceService] Error getting available engines: $e');
      return [];
    }
  }

  /// 获取当前识别状态
  bool get isListening => _isListening;

  /// 获取最后的识别结果
  String get lastResult => _recognitionResult;

  /// 清空缓存
  void clearCache() {
    _cache.clear();
    _logger.i('[VoiceService] Cache cleared');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'size': _cache.length,
      'maxSize': _maxCacheSize,
      'keys': _cache.keys.toList(),
    };
  }

  /// 清理资源
  ///
  /// 应该在不再需要语音识别时调用（如App关闭）
  Future<void> dispose() async {
    try {
      _logger.i('[VoiceService] Disposing voice recognition service');

      if (_isListening) {
        await cancelRecognition();
      }

      await _manager.dispose();
      _cache.clear();

      _logger.i('[VoiceService] ✓ Voice recognition service disposed');
    } catch (e) {
      _logger.e('[VoiceService] Error disposing: $e');
    }
  }

  // Private methods

  /// 缓存识别结果
  ///
  /// 采用简单的 LRU 策略：
  /// - 新结果始终被缓存
  /// - 超过最大容量时，移除最老的结果
  void _cacheResult(String language, String text) {
    try {
      final cacheKey = '${language}_$text'.toLowerCase();

      // 移除旧条目
      if (_cache.length >= _maxCacheSize) {
        // 移除第一个条目（最老的）
        _cache.remove(_cache.keys.first);
      }

      _cache[cacheKey] = text;
      _logger.d(
          '[VoiceService] Cached result: $cacheKey (cache size: ${_cache.length})');
    } catch (e) {
      _logger.w('[VoiceService] Error caching result: $e');
    }
  }
}

/// 语音识别服务 Provider
final voiceRecognitionServiceProvider =
    Provider<VoiceRecognitionService>((ref) {
  final manager = ref.watch(voiceRecognitionManagerProvider);
  final service = VoiceRecognitionService(manager);

  // 设置清理回调
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// 语音识别可用性 Provider
///
/// 异步 Provider，检查语音识别是否可用
final voiceRecognitionAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(voiceRecognitionServiceProvider);
  return service.isAvailable();
});

/// 可用的语音识别引擎列表 Provider
///
/// 异步 Provider，返回所有可用的语音识别引擎
final availableVoiceEnginesProvider =
    FutureProvider<List<VoiceRecognitionEngine>>((ref) async {
  final service = ref.watch(voiceRecognitionServiceProvider);
  return service.getAvailableEngines();
});

/// 语音识别中状态 Provider
///
/// 响应式 Provider，跟踪是否正在进行语音识别
final isVoiceListeningProvider = StateProvider<bool>((ref) {
  return false;
});

/// 当前识别结果 Provider
///
/// 响应式 Provider，存储最后的识别结果
final currentVoiceResultProvider = StateProvider<String>((ref) {
  return '';
});
