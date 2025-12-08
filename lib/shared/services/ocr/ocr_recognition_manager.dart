import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'ocr_recognition_engine.dart';

/// OCR 识别管理器
///
/// 协调多个 OCR 识别引擎，提供：
/// - 按优先级选择可用引擎
/// - 自动故障转移（如果一个失败，尝试下一个）
/// - 权限管理
/// - 识别过程管理
class OCRRecognitionManager {
  final Logger _logger = Logger();
  final List<OCRRecognitionEngine> _engines = [];
  bool _initialized = false;

  /// 添加 OCR 识别引擎
  ///
  /// 引擎会按优先级排序，优先级越高越先被使用
  Future<void> addEngine(OCRRecognitionEngine engine) async {
    _engines.add(engine);
    _engines.sort((a, b) => b.priority.compareTo(a.priority));
    _logger.i(
        'Added OCR recognition engine: ${engine.name} (priority: ${engine.priority})');
  }

  /// 移除 OCR 识别引擎
  void removeEngine(String engineName) {
    _engines.removeWhere((e) => e.name == engineName);
    _logger.i('Removed OCR recognition engine: $engineName');
  }

  /// 初始化 OCR 识别系统
  ///
  /// 这会初始化所有已注册的引擎
  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    try {
      _logger.i(
          'Initializing OCR recognition system with ${_engines.length} engines');

      for (final engine in _engines) {
        try {
          final success = await engine.initialize();
          if (success) {
            _logger.i('✓ Engine initialized: ${engine.name}');
          } else {
            _logger.w('✗ Failed to initialize engine: ${engine.name}');
          }
        } catch (e) {
          _logger.e('Error initializing engine ${engine.name}: $e');
        }
      }

      _initialized = true;
      return true;
    } catch (e) {
      _logger.e('Error initializing OCR recognition: $e');
      return false;
    }
  }

  /// 检查是否有 OCR 权限（摄像头权限）
  Future<bool> hasPermission() async {
    try {
      for (final engine in _engines) {
        try {
          final isAvailable = await engine.isAvailable();
          if (isAvailable) {
            _logger.i('Engine available for OCR recognition: ${engine.name}');
            return true;
          }
        } catch (e) {
          _logger.w('Error checking availability with ${engine.name}: $e');
        }
      }
      _logger.w('No engine available for OCR recognition');
      return false;
    } catch (e) {
      _logger.e('Error checking OCR permission: $e');
      return false;
    }
  }

  /// 请求 OCR 权限（初始化引擎）
  Future<bool> requestPermission() async {
    try {
      for (final engine in _engines) {
        try {
          final initialized = await engine.initialize();
          if (initialized) {
            _logger.i('Engine initialized: ${engine.name}');
            return true;
          }
        } catch (e) {
          _logger.w('Error initializing ${engine.name}: $e');
        }
      }
      _logger.w('Failed to initialize any engine');
      return false;
    } catch (e) {
      _logger.e('Error requesting OCR permission: $e');
      return false;
    }
  }

  /// 获取最优先可用的引擎
  ///
  /// 返回优先级最高且可用的引擎，如果都不可用返回 null
  Future<OCRRecognitionEngine?> _getPrimaryEngine() async {
    for (final engine in _engines) {
      try {
        final isAvailable = await engine.isAvailable();
        if (isAvailable) {
          _logger.d('Selected engine: ${engine.name}');
          return engine;
        }
      } catch (e) {
        _logger.w('Error checking availability of ${engine.name}: $e');
      }
    }
    return null;
  }

  /// 从图片文件识别文本
  ///
  /// 参数：
  /// - [imagePath] 图片文件路径
  /// - [language] 识别的语言代码
  /// - [timeout] 识别超时时间（默认30秒）
  ///
  /// 使用故障转移策略：如果第一个引擎失败，自动尝试下一个
  Future<String> recognizeFromFile(
    String imagePath, {
    String language = 'auto',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      if (!_initialized) {
        final initSuccess = await initialize();
        if (!initSuccess) {
          throw OCRRecognitionException('OCR recognition not initialized');
        }
      }

      _logger.i(
          'Starting OCR recognition from file: $imagePath (language: $language)');

      // 遍历所有引擎，按优先级尝试
      for (final engine in _engines) {
        try {
          _logger.i('Attempting to recognize with engine: ${engine.name}');

          final isAvailable = await engine.isAvailable();
          if (!isAvailable) {
            _logger.w('Engine ${engine.name} is not available, trying next...');
            continue;
          }

          // 设置超时
          final result = await engine
              .recognizeFromFile(
            imagePath,
            language: language,
          )
              .timeout(timeout, onTimeout: () {
            throw OCRRecognitionTimeoutException(
              'Recognition timeout after ${timeout.inSeconds}s',
            );
          });

          _logger.i('✓ Recognition successful with ${engine.name}: $result');
          return result;
        } catch (e) {
          _logger.w('Error with engine ${engine.name}: $e, trying next...');
          continue;
        }
      }

      // 所有引擎都失败了
      const errorMsg = 'All OCR recognition engines failed';
      throw OCRRecognitionException(errorMsg);
    } catch (e) {
      _logger.e('Error in OCR recognition: $e');
      rethrow;
    }
  }

  /// 从图片字节识别文本
  ///
  /// 参数：
  /// - [imageBytes] 图片字节数据
  /// - [language] 识别的语言代码
  /// - [timeout] 识别超时时间
  Future<String> recognizeFromBytes(
    List<int> imageBytes, {
    String language = 'auto',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      if (!_initialized) {
        final initSuccess = await initialize();
        if (!initSuccess) {
          throw OCRRecognitionException('OCR recognition not initialized');
        }
      }

      _logger.i(
          'Starting OCR recognition from bytes (size: ${imageBytes.length})');

      // 遍历所有引擎，按优先级尝试
      for (final engine in _engines) {
        try {
          _logger.i('Attempting to recognize with engine: ${engine.name}');

          final isAvailable = await engine.isAvailable();
          if (!isAvailable) {
            _logger.w('Engine ${engine.name} is not available, trying next...');
            continue;
          }

          // 设置超时
          final result = await engine
              .recognizeFromBytes(
            imageBytes,
            language: language,
          )
              .timeout(timeout, onTimeout: () {
            throw OCRRecognitionTimeoutException(
              'Recognition timeout after ${timeout.inSeconds}s',
            );
          });

          _logger.i('✓ Recognition successful with ${engine.name}');
          return result;
        } catch (e) {
          _logger.w('Error with engine ${engine.name}: $e, trying next...');
          continue;
        }
      }

      // 所有引擎都失败了
      const errorMsg = 'All OCR recognition engines failed';
      throw OCRRecognitionException(errorMsg);
    } catch (e) {
      _logger.e('Error in OCR recognition: $e');
      rethrow;
    }
  }

  /// 检查是否有可用的 OCR 识别引擎
  Future<bool> isAvailable() async {
    try {
      final engine = await _getPrimaryEngine();
      return engine != null;
    } catch (e) {
      _logger.e('Error checking OCR recognition availability: $e');
      return false;
    }
  }

  /// 获取所有已注册的引擎列表
  List<OCRRecognitionEngine> get engines => List.unmodifiable(_engines);

  /// 获取所有可用的引擎列表
  Future<List<OCRRecognitionEngine>> getAvailableEngines() async {
    final availableEngines = <OCRRecognitionEngine>[];
    for (final engine in _engines) {
      try {
        final isAvailable = await engine.isAvailable();
        if (isAvailable) {
          availableEngines.add(engine);
        }
      } catch (e) {
        _logger.w('Error checking availability of ${engine.name}: $e');
      }
    }
    return availableEngines;
  }

  /// 清理资源
  ///
  /// 应该在应用关闭时调用
  Future<void> dispose() async {
    try {
      for (final engine in _engines) {
        try {
          await engine.dispose();
        } catch (e) {
          _logger.w('Error disposing engine ${engine.name}: $e');
        }
      }
      _initialized = false;
      _engines.clear();
    } catch (e) {
      _logger.e('Error disposing OCR recognition: $e');
    }
  }
}

/// OCR 识别管理器 Provider
final ocrRecognitionManagerProvider = Provider<OCRRecognitionManager>((ref) {
  final manager = OCRRecognitionManager();

  // 注册本地引擎
  manager.addEngine(LocalOCRRecognitionEngine());

  // 后续可以添加更多引擎：
  // manager.addEngine(TencentOCRRecognitionEngine());
  // manager.addEngine(BaiduOCRRecognitionEngine());
  // manager.addEngine(GoogleOCRRecognitionEngine());

  // 设置清理回调
  ref.onDispose(() {
    manager.dispose();
  });

  return manager;
});
