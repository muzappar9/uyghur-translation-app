import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../services/voice/voice_recognition_service.dart';
import '../services/translation_service.dart';

/// 语音到文本提供者
///
/// 这个提供者处理语音识别流程，包括：
/// 1. 开始语音识别
/// 2. 获取识别结果
/// 3. 触发自动翻译
/// 4. 处理错误和重试
class VoiceToTextProvider {
  final VoiceRecognitionService _voiceService;
  final TranslationService _translationService;
  final Logger _logger = Logger();

  VoiceToTextProvider(this._voiceService, this._translationService);

  /// 初始化语音识别
  ///
  /// 返回 true 表示初始化成功
  Future<bool> initialize() async {
    try {
      _logger.i('[VoiceToText] Initializing voice to text provider');

      final success = await _voiceService.initialize();
      if (!success) {
        _logger.e('[VoiceToText] Failed to initialize voice service');
        return false;
      }

      _logger.i('[VoiceToText] ✓ Voice to text provider initialized');
      return true;
    } catch (e) {
      _logger.e('[VoiceToText] Error initializing: $e');
      return false;
    }
  }

  /// 开始语音识别并自动翻译
  ///
  /// 参数：
  /// - [sourceLanguage] 语音识别语言（如 'ug' 表示维吾尔语）
  /// - [targetLanguage] 翻译目标语言（如 'en' 表示英文）
  /// - [onRecognizing] 识别中的回调（接收中间结果）
  /// - [onRecognized] 识别完成的回调（接收最终识别文本）
  /// - [onTranslating] 翻译中的回调
  /// - [onTranslated] 翻译完成的回调（接收翻译结果）
  /// - [onError] 错误回调
  Future<void> startVoiceToText({
    required String sourceLanguage,
    required String targetLanguage,
    required Function(String) onRecognizing,
    required Function(String) onRecognized,
    required Function() onTranslating,
    required Function(String) onTranslated,
    required Function(String) onError,
  }) async {
    try {
      _logger.i(
          '[VoiceToText] Starting voice to text: $sourceLanguage → $targetLanguage');

      // 检查语音识别是否可用
      final isAvailable = await _voiceService.isAvailable();
      if (!isAvailable) {
        onError('语音识别不可用');
        return;
      }

      // 开始语音识别
      await _voiceService.startRecognition(
        language: sourceLanguage,
        onPartialResult: (text) {
          _logger.d('[VoiceToText] Partial recognition: $text');
          onRecognizing(text);
        },
        onFinalResult: (text) {
          _logger.i('[VoiceToText] Final recognition: $text');
          onRecognized(text);

          // 自动触发翻译
          _translateRecognizedText(
            text: text,
            sourceLang: sourceLanguage,
            targetLang: targetLanguage,
            onTranslating: onTranslating,
            onTranslated: onTranslated,
            onError: onError,
          );
        },
        onError: onError,
      );
    } catch (e) {
      _logger.e('[VoiceToText] Error starting voice to text: $e');
      onError('启动语音识别失败: $e');
    }
  }

  /// 停止语音识别
  Future<String> stopVoiceToText() async {
    try {
      _logger.i('[VoiceToText] Stopping voice recognition');

      final result = await _voiceService.stopRecognition();

      _logger.i('[VoiceToText] ✓ Voice recognition stopped');
      return result;
    } catch (e) {
      _logger.e('[VoiceToText] Error stopping: $e');
      return '';
    }
  }

  /// 取消语音识别
  Future<void> cancelVoiceToText() async {
    try {
      _logger.i('[VoiceToText] Canceling voice recognition');

      await _voiceService.cancelRecognition();

      _logger.i('[VoiceToText] ✓ Voice recognition canceled');
    } catch (e) {
      _logger.e('[VoiceToText] Error canceling: $e');
    }
  }

  /// 检查语音识别是否可用
  Future<bool> isVoiceAvailable() async {
    try {
      return await _voiceService.isAvailable();
    } catch (e) {
      _logger.e('[VoiceToText] Error checking availability: $e');
      return false;
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    try {
      _logger.i('[VoiceToText] Disposing voice to text provider');
      await _voiceService.dispose();
      _logger.i('[VoiceToText] ✓ Voice to text provider disposed');
    } catch (e) {
      _logger.e('[VoiceToText] Error disposing: $e');
    }
  }

  // Private methods

  /// 翻译识别的文本
  Future<void> _translateRecognizedText({
    required String text,
    required String sourceLang,
    required String targetLang,
    required Function() onTranslating,
    required Function(String) onTranslated,
    required Function(String) onError,
  }) async {
    try {
      // 如果识别文本为空，跳过翻译
      if (text.trim().isEmpty) {
        _logger
            .w('[VoiceToText] Recognized text is empty, skipping translation');
        return;
      }

      _logger.i('[VoiceToText] Translating: $text');
      onTranslating();

      // 触发翻译
      final translatedText = await _translationService.translate(
        text,
        sourceLang,
        targetLang,
      );

      _logger.i('[VoiceToText] Translation complete: $translatedText');
      onTranslated(translatedText);
    } catch (e) {
      _logger.e('[VoiceToText] Error translating: $e');
      onError('翻译失败: $e');
    }
  }
}

/// 语音转文本提供者的 Riverpod Provider
final voiceToTextProvider = Provider<VoiceToTextProvider>((ref) {
  final voiceService = ref.watch(voiceRecognitionServiceProvider);
  final translationService = ref.watch(translationServiceProvider);

  final provider = VoiceToTextProvider(voiceService, translationService);

  // 设置清理回调
  ref.onDispose(() {
    provider.dispose();
  });

  return provider;
});

/// 语音识别进度状态
class VoiceToTextState {
  final bool isRecognizing;
  final String recognizedText;
  final bool isTranslating;
  final String translatedText;
  final String? error;

  VoiceToTextState({
    this.isRecognizing = false,
    this.recognizedText = '',
    this.isTranslating = false,
    this.translatedText = '',
    this.error,
  });

  VoiceToTextState copyWith({
    bool? isRecognizing,
    String? recognizedText,
    bool? isTranslating,
    String? translatedText,
    String? error,
  }) {
    return VoiceToTextState(
      isRecognizing: isRecognizing ?? this.isRecognizing,
      recognizedText: recognizedText ?? this.recognizedText,
      isTranslating: isTranslating ?? this.isTranslating,
      translatedText: translatedText ?? this.translatedText,
      error: error ?? this.error,
    );
  }
}

/// 语音转文本状态管理 Notifier
class VoiceToTextNotifier extends StateNotifier<VoiceToTextState> {
  final VoiceToTextProvider _provider;
  final Logger _logger = Logger();

  VoiceToTextNotifier(this._provider) : super(VoiceToTextState());

  /// 初始化
  Future<bool> initialize() async {
    try {
      return await _provider.initialize();
    } catch (e) {
      _logger.e('[VoiceToTextNotifier] Error initializing: $e');
      state = state.copyWith(error: 'Initialization failed: $e');
      return false;
    }
  }

  /// 开始语音到文本转换
  Future<void> startVoiceToText({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      state = state.copyWith(isRecognizing: true, error: null);

      await _provider.startVoiceToText(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        onRecognizing: (text) {
          state = state.copyWith(recognizedText: text);
        },
        onRecognized: (text) {
          state = state.copyWith(recognizedText: text);
        },
        onTranslating: () {
          state = state.copyWith(isTranslating: true);
        },
        onTranslated: (text) {
          state = state.copyWith(
            translatedText: text,
            isTranslating: false,
          );
        },
        onError: (error) {
          _logger.e('[VoiceToTextNotifier] Error: $error');
          state = state.copyWith(
            error: error,
            isRecognizing: false,
            isTranslating: false,
          );
        },
      );
    } catch (e) {
      _logger.e('[VoiceToTextNotifier] Error starting voice to text: $e');
      state = state.copyWith(
        error: 'Failed to start: $e',
        isRecognizing: false,
      );
    }
  }

  /// 停止语音识别
  Future<void> stopVoiceToText() async {
    try {
      await _provider.stopVoiceToText();
      state = state.copyWith(isRecognizing: false);
    } catch (e) {
      _logger.e('[VoiceToTextNotifier] Error stopping: $e');
      state = state.copyWith(error: 'Failed to stop: $e');
    }
  }

  /// 取消语音识别
  Future<void> cancelVoiceToText() async {
    try {
      await _provider.cancelVoiceToText();
      state = VoiceToTextState();
    } catch (e) {
      _logger.e('[VoiceToTextNotifier] Error canceling: $e');
      state = state.copyWith(error: 'Failed to cancel: $e');
    }
  }

  /// 检查语音是否可用
  Future<bool> isVoiceAvailable() async {
    try {
      return await _provider.isVoiceAvailable();
    } catch (e) {
      _logger.e('[VoiceToTextNotifier] Error checking availability: $e');
      return false;
    }
  }
}

/// 语音转文本状态 StateNotifier Provider
final voiceToTextStateProvider =
    StateNotifierProvider<VoiceToTextNotifier, VoiceToTextState>((ref) {
  final provider = ref.watch(voiceToTextProvider);
  final notifier = VoiceToTextNotifier(provider);

  // 自动初始化
  notifier.initialize();

  // 设置清理回调
  ref.onDispose(() {
    // 清理会由 VoiceToTextProvider 的清理逻辑处理
  });

  return notifier;
});

/// 便捷 Provider：检查语音识别是否可用
final isVoiceAvailableProvider = FutureProvider<bool>((ref) async {
  final provider = ref.watch(voiceToTextProvider);
  return provider.isVoiceAvailable();
});
