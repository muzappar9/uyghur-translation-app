import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'voice_recognition_engine.dart';

/// 语音识别管理器
///
/// 协调多个语音识别引擎，提供：
/// - 按优先级选择可用引擎
/// - 自动故障转移（如果一个失败，尝试下一个）
/// - 权限管理
/// - 识别过程管理
class VoiceRecognitionManager {
  final Logger _logger = Logger();
  final List<VoiceRecognitionEngine> _engines = [];
  bool _initialized = false;

  /// 添加语音识别引擎
  ///
  /// 引擎会按优先级排序，优先级越高越先被使用
  Future<void> addEngine(VoiceRecognitionEngine engine) async {
    _engines.add(engine);
    _engines.sort((a, b) => b.priority.compareTo(a.priority));
    _logger.i(
        'Added voice recognition engine: ${engine.name} (priority: ${engine.priority})');
  }

  /// 移除语音识别引擎
  void removeEngine(String engineName) {
    _engines.removeWhere((e) => e.name == engineName);
    _logger.i('Removed voice recognition engine: $engineName');
  }

  /// 初始化语音识别系统
  ///
  /// 这会初始化所有已注册的引擎
  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    try {
      _logger.i(
          'Initializing voice recognition system with ${_engines.length} engines');

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
      _logger.e('Error initializing voice recognition: $e');
      return false;
    }
  }

  /// 检查是否有语音识别权限（麦克风权限）
  Future<bool> hasPermission() async {
    try {
      for (final engine in _engines) {
        try {
          final isAvailable = await engine.isAvailable();
          if (isAvailable) {
            _logger.i('Engine available for voice recognition: ${engine.name}');
            return true;
          }
        } catch (e) {
          _logger.w('Error checking availability with ${engine.name}: $e');
        }
      }
      _logger.w('No engine available for voice recognition');
      return false;
    } catch (e) {
      _logger.e('Error checking voice permission: $e');
      return false;
    }
  }

  /// 请求语音识别权限（初始化引擎）
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
      _logger.e('Error requesting voice permission: $e');
      return false;
    }
  }

  /// 获取最优先可用的引擎
  ///
  /// 返回优先级最高且可用的引擎，如果都不可用返回 null
  Future<VoiceRecognitionEngine?> _getPrimaryEngine() async {
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

  /// 开始语音识别
  ///
  /// 参数：
  /// - [language] 识别的语言代码
  /// - [onPartialResult] 中间结果回调
  /// - [onFinalResult] 最终结果回调
  /// - [onError] 错误回调
  /// - [timeout] 识别超时时间（默认30秒）
  ///
  /// 使用故障转移策略：如果第一个引擎失败，自动尝试下一个
  Future<bool> startListening({
    required String language,
    required Function(String) onPartialResult,
    required Function(String) onFinalResult,
    required Function(String) onError,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      if (!_initialized) {
        final initSuccess = await initialize();
        if (!initSuccess) {
          onError('Failed to initialize voice recognition');
          throw VoiceRecognitionException('Voice recognition not initialized');
        }
      }

      // 遍历所有引擎，按优先级尝试
      for (final engine in _engines) {
        try {
          _logger
              .i('Attempting to start listening with engine: ${engine.name}');

          final isAvailable = await engine.isAvailable();
          if (!isAvailable) {
            _logger.w('Engine ${engine.name} is not available, trying next...');
            continue;
          }

          // 设置超时
          var timeoutOccurred = false;
          final timeoutTimer = Future.delayed(timeout, () {
            timeoutOccurred = true;
            onError('Voice recognition timeout after ${timeout.inSeconds}s');
          });

          final result = await engine.startListening(
            language: language,
            onPartialResult: (text) {
              if (!timeoutOccurred) {
                onPartialResult(text);
              }
            },
            onFinalResult: (text) {
              if (!timeoutOccurred) {
                timeoutTimer.ignore(); // Cancel timeout
                onFinalResult(text);
              }
            },
            onError: onError,
          );

          if (result) {
            _logger.i('✓ Voice recognition started with ${engine.name}');
            return true;
          }
        } catch (e) {
          _logger.w('Error with engine ${engine.name}: $e, trying next...');
          continue;
        }
      }

      // 所有引擎都失败了
      const errorMsg = 'All voice recognition engines failed';
      onError(errorMsg);
      throw VoiceRecognitionException(errorMsg);
    } catch (e) {
      _logger.e('Error starting voice recognition: $e');
      onError('Failed to start voice recognition: $e');
      return false;
    }
  }

  /// 停止语音识别并获取结果
  ///
  /// 返回识别得到的文本
  Future<String> stopListening() async {
    try {
      // 尝试从最后一个使用的引擎获取结果
      // 在实际应用中，应该跟踪当前活跃的引擎
      if (_engines.isNotEmpty) {
        return await _engines.first.stopListening();
      }
      return '';
    } catch (e) {
      _logger.e('Error stopping voice recognition: $e');
      return '';
    }
  }

  /// 取消语音识别
  Future<void> cancel() async {
    try {
      for (final engine in _engines) {
        try {
          await engine.cancel();
        } catch (e) {
          _logger.w('Error canceling engine ${engine.name}: $e');
        }
      }
    } catch (e) {
      _logger.e('Error canceling voice recognition: $e');
    }
  }

  /// 检查是否有可用的语音识别引擎
  Future<bool> isAvailable() async {
    try {
      final engine = await _getPrimaryEngine();
      return engine != null;
    } catch (e) {
      _logger.e('Error checking voice recognition availability: $e');
      return false;
    }
  }

  /// 获取所有已注册的引擎列表
  List<VoiceRecognitionEngine> get engines => List.unmodifiable(_engines);

  /// 获取所有可用的引擎列表
  Future<List<VoiceRecognitionEngine>> getAvailableEngines() async {
    final availableEngines = <VoiceRecognitionEngine>[];
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
      _logger.e('Error disposing voice recognition: $e');
    }
  }
}

/// 语音识别管理器 Provider
final voiceRecognitionManagerProvider =
    Provider<VoiceRecognitionManager>((ref) {
  final manager = VoiceRecognitionManager();

  // 注册本地引擎
  manager.addEngine(LocalVoiceRecognitionEngine());

  // 后续可以添加更多引擎：
  // manager.addEngine(TencentVoiceRecognitionEngine());
  // manager.addEngine(IFlyTekVoiceRecognitionEngine());
  // manager.addEngine(GoogleVoiceRecognitionEngine());

  // 设置清理回调
  ref.onDispose(() {
    manager.dispose();
  });

  return manager;
});
