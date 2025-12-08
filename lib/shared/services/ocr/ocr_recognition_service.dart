import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'ocr_recognition_manager.dart';
import 'ocr_recognition_engine.dart';

/// OCR 识别服务
///
/// 提供高层次的 OCR 识别功能，包括：
/// - 权限检查和请求
/// - 识别过程管理
/// - 错误处理和恢复
/// - 识别结果缓存
/// - 离线支持（待同步队列）
class OCRRecognitionService {
  final OCRRecognitionManager _manager;
  final Logger _logger = Logger();

  // 识别过程中的状态跟踪
  bool _isRecognizing = false;
  String _recognitionResult = '';

  // 简单的内存缓存（基于文件路径）
  final Map<String, String> _cache = {};
  static const int _maxCacheSize = 100;

  OCRRecognitionService(this._manager);

  /// 初始化 OCR 识别服务
  ///
  /// 这会：
  /// 1. 初始化所有 OCR 识别引擎
  /// 2. 请求相机权限（如果需要）
  /// 3. 验证设备支持
  Future<bool> initialize() async {
    try {
      _logger.i('[OCRService] Initializing OCR recognition service');

      final success = await _manager.initialize();
      if (!success) {
        _logger.e('[OCRService] Failed to initialize OCR recognition manager');
        return false;
      }

      _logger.i('[OCRService] ✓ OCR recognition service initialized');
      return true;
    } catch (e) {
      _logger.e('[OCRService] Error initializing: $e');
      return false;
    }
  }

  /// 从图片文件识别文本
  ///
  /// 参数：
  /// - [imagePath] 图片文件路径
  /// - [language] 识别语言（'en', 'zh', 'ug', 'auto'）
  /// - [timeout] 超时时间（默认30秒）
  ///
  /// 返回识别得到的文本
  Future<String> recognizeFromFile(
    String imagePath, {
    String language = 'auto',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // 检查是否已在识别中
      if (_isRecognizing) {
        throw OCRRecognitionException('Already recognizing');
      }

      _isRecognizing = true;
      _recognitionResult = '';

      _logger.i('[OCRService] Starting OCR recognition for file: $imagePath');

      // 检查缓存
      if (_cache.containsKey(imagePath)) {
        _logger.d('[OCRService] Cache hit for file: $imagePath');
        _isRecognizing = false;
        _recognitionResult = _cache[imagePath]!;
        return _recognitionResult;
      }

      // 执行识别
      final result = await _manager.recognizeFromFile(
        imagePath,
        language: language,
        timeout: timeout,
      );

      _logger.i('[OCRService] ✓ Recognition complete, text: $result');

      // 缓存结果
      _cacheResult(imagePath, result);
      _recognitionResult = result;
      _isRecognizing = false;

      return result;
    } catch (e) {
      _isRecognizing = false;
      _logger.e('[OCRService] Error recognizing from file: $e');
      rethrow;
    }
  }

  /// 从图片字节识别文本
  ///
  /// 参数：
  /// - [imageBytes] 图片字节数据
  /// - [language] 识别语言
  /// - [timeout] 超时时间
  ///
  /// 返回识别得到的文本
  Future<String> recognizeFromBytes(
    List<int> imageBytes, {
    String language = 'auto',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      // 检查是否已在识别中
      if (_isRecognizing) {
        throw OCRRecognitionException('Already recognizing');
      }

      _isRecognizing = true;
      _recognitionResult = '';

      _logger.i(
          '[OCRService] Starting OCR recognition for bytes (size: ${imageBytes.length})');

      // 执行识别
      final result = await _manager.recognizeFromBytes(
        imageBytes,
        language: language,
        timeout: timeout,
      );

      _logger.i('[OCRService] ✓ Recognition complete');

      _recognitionResult = result;
      _isRecognizing = false;

      return result;
    } catch (e) {
      _isRecognizing = false;
      _logger.e('[OCRService] Error recognizing from bytes: $e');
      rethrow;
    }
  }

  /// 检查 OCR 识别是否可用
  ///
  /// 检查内容：
  /// - 至少有一个可用引擎
  /// - 设备支持 OCR
  Future<bool> isAvailable() async {
    try {
      return await _manager.isAvailable();
    } catch (e) {
      _logger.e('[OCRService] Error checking availability: $e');
      return false;
    }
  }

  /// 获取所有可用的 OCR 识别引擎
  Future<List<OCRRecognitionEngine>> getAvailableEngines() async {
    try {
      return await _manager.getAvailableEngines();
    } catch (e) {
      _logger.e('[OCRService] Error getting available engines: $e');
      return [];
    }
  }

  /// 获取当前识别状态
  bool get isRecognizing => _isRecognizing;

  /// 获取最后的识别结果
  String get lastResult => _recognitionResult;

  /// 清空缓存
  void clearCache() {
    _cache.clear();
    _logger.i('[OCRService] Cache cleared');
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
  /// 应该在不再需要 OCR 识别时调用（如应用关闭）
  Future<void> dispose() async {
    try {
      _logger.i('[OCRService] Disposing OCR recognition service');

      if (_isRecognizing) {
        _isRecognizing = false;
      }

      await _manager.dispose();
      _cache.clear();

      _logger.i('[OCRService] ✓ OCR recognition service disposed');
    } catch (e) {
      _logger.e('[OCRService] Error disposing: $e');
    }
  }

  // Private methods

  /// 缓存识别结果
  ///
  /// 采用简单的 LRU 策略：
  /// - 新结果始终被缓存
  /// - 超过最大容量时，移除最老的结果
  void _cacheResult(String filePath, String text) {
    try {
      // 移除旧条目
      if (_cache.length >= _maxCacheSize) {
        // 移除第一个条目（最老的）
        _cache.remove(_cache.keys.first);
      }

      _cache[filePath] = text;
      _logger.d(
          '[OCRService] Cached result for: $filePath (cache size: ${_cache.length})');
    } catch (e) {
      _logger.w('[OCRService] Error caching result: $e');
    }
  }
}

/// OCR 识别服务 Provider
final ocrRecognitionServiceProvider = Provider<OCRRecognitionService>((ref) {
  final manager = ref.watch(ocrRecognitionManagerProvider);
  final service = OCRRecognitionService(manager);

  // 设置清理回调
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// OCR 识别可用性 Provider
///
/// 异步 Provider，检查 OCR 识别是否可用
final ocrRecognitionAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(ocrRecognitionServiceProvider);
  return service.isAvailable();
});

/// 可用的 OCR 识别引擎列表 Provider
///
/// 异步 Provider，返回所有可用的 OCR 识别引擎
final availableOCREnginesProvider =
    FutureProvider<List<OCRRecognitionEngine>>((ref) async {
  final service = ref.watch(ocrRecognitionServiceProvider);
  return service.getAvailableEngines();
});

/// OCR 识别中状态 Provider
///
/// 响应式 Provider，跟踪是否正在进行 OCR 识别
final isOCRRecognizingProvider = StateProvider<bool>((ref) {
  return false;
});

/// 当前识别结果 Provider
///
/// 响应式 Provider，存储最后的 OCR 识别结果
final currentOCRResultProvider = StateProvider<String>((ref) {
  return '';
});
