import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../services/ocr/ocr_recognition_service.dart';
import '../services/translation_service.dart';

/// 图片转文本提供者
///
/// 这个提供者处理 OCR 识别流程，包括：
/// 1. 开始 OCR 识别
/// 2. 获取识别结果
/// 3. 触发自动翻译
/// 4. 处理错误和重试
class ImageToTextProvider {
  final OCRRecognitionService _ocrService;
  final TranslationService _translationService;
  final Logger _logger = Logger();

  ImageToTextProvider(this._ocrService, this._translationService);

  /// 初始化 OCR 服务
  ///
  /// 返回 true 表示初始化成功
  Future<bool> initialize() async {
    try {
      _logger.i('[ImageToText] Initializing image to text provider');

      final success = await _ocrService.initialize();
      if (!success) {
        _logger.e('[ImageToText] Failed to initialize OCR service');
        return false;
      }

      _logger.i('[ImageToText] ✓ Image to text provider initialized');
      return true;
    } catch (e) {
      _logger.e('[ImageToText] Error initializing: $e');
      return false;
    }
  }

  /// 从图片文件识别文本并自动翻译
  ///
  /// 参数：
  /// - [imagePath] 图片文件路径
  /// - [sourceLanguage] 原始语言（如 'zh' 表示中文）
  /// - [targetLanguage] 翻译目标语言（如 'ug' 表示维吾尔语）
  /// - [recognitionLanguage] 识别语言（如 'auto' 自动检测）
  /// - [onRecognizing] 识别进度回调
  /// - [onRecognized] 识别完成的回调（接收识别文本）
  /// - [onTranslating] 翻译中的回调
  /// - [onTranslated] 翻译完成的回调（接收翻译结果）
  /// - [onError] 错误回调
  Future<void> startImageToText({
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
    String recognitionLanguage = 'auto',
    required Function() onRecognizing,
    required Function(String) onRecognized,
    required Function() onTranslating,
    required Function(String) onTranslated,
    required Function(String) onError,
  }) async {
    try {
      _logger.i(
          '[ImageToText] Starting image to text: $imagePath → $sourceLanguage/$targetLanguage');

      // 检查 OCR 是否可用
      final isAvailable = await _ocrService.isAvailable();
      if (!isAvailable) {
        onError('OCR 识别不可用');
        return;
      }

      // 开始识别
      onRecognizing();

      final recognizedText = await _ocrService.recognizeFromFile(
        imagePath,
        language: recognitionLanguage,
      );

      _logger.i('[ImageToText] Recognition complete: $recognizedText');
      onRecognized(recognizedText);

      // 自动触发翻译
      _translateRecognizedText(
        text: recognizedText,
        sourceLang: sourceLanguage,
        targetLang: targetLanguage,
        onTranslating: onTranslating,
        onTranslated: onTranslated,
        onError: onError,
      );
    } catch (e) {
      _logger.e('[ImageToText] Error starting image to text: $e');
      onError('启动 OCR 识别失败: $e');
    }
  }

  /// 从图片字节识别文本并自动翻译
  ///
  /// 参数：
  /// - [imageBytes] 图片字节数据
  /// - [sourceLanguage] 原始语言
  /// - [targetLanguage] 翻译目标语言
  /// - [recognitionLanguage] 识别语言
  /// - [onRecognizing] 识别进度回调
  /// - [onRecognized] 识别完成回调
  /// - [onTranslating] 翻译进度回调
  /// - [onTranslated] 翻译完成回调
  /// - [onError] 错误回调
  Future<void> startImageToTextFromBytes({
    required List<int> imageBytes,
    required String sourceLanguage,
    required String targetLanguage,
    String recognitionLanguage = 'auto',
    required Function() onRecognizing,
    required Function(String) onRecognized,
    required Function() onTranslating,
    required Function(String) onTranslated,
    required Function(String) onError,
  }) async {
    try {
      _logger.i('[ImageToText] Starting image to text from bytes');

      // 检查 OCR 是否可用
      final isAvailable = await _ocrService.isAvailable();
      if (!isAvailable) {
        onError('OCR 识别不可用');
        return;
      }

      // 开始识别
      onRecognizing();

      final recognizedText = await _ocrService.recognizeFromBytes(
        imageBytes,
        language: recognitionLanguage,
      );

      _logger.i('[ImageToText] Recognition complete from bytes');
      onRecognized(recognizedText);

      // 自动触发翻译
      _translateRecognizedText(
        text: recognizedText,
        sourceLang: sourceLanguage,
        targetLang: targetLanguage,
        onTranslating: onTranslating,
        onTranslated: onTranslated,
        onError: onError,
      );
    } catch (e) {
      _logger.e('[ImageToText] Error starting image to text from bytes: $e');
      onError('启动 OCR 识别失败: $e');
    }
  }

  /// 检查 OCR 识别是否可用
  Future<bool> isOCRAvailable() async {
    try {
      return await _ocrService.isAvailable();
    } catch (e) {
      _logger.e('[ImageToText] Error checking availability: $e');
      return false;
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    try {
      _logger.i('[ImageToText] Disposing image to text provider');
      await _ocrService.dispose();
      _logger.i('[ImageToText] ✓ Image to text provider disposed');
    } catch (e) {
      _logger.e('[ImageToText] Error disposing: $e');
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
            .w('[ImageToText] Recognized text is empty, skipping translation');
        return;
      }

      _logger.i('[ImageToText] Translating: $text');
      onTranslating();

      // 触发翻译
      final translatedText = await _translationService.translate(
        text,
        sourceLang,
        targetLang,
      );

      _logger.i('[ImageToText] Translation complete: $translatedText');
      onTranslated(translatedText);
    } catch (e) {
      _logger.e('[ImageToText] Error translating: $e');
      onError('翻译失败: $e');
    }
  }
}

/// 图片转文本提供者的 Riverpod Provider
final imageToTextProvider = Provider<ImageToTextProvider>((ref) {
  final ocrService = ref.watch(ocrRecognitionServiceProvider);
  final translationService = ref.watch(translationServiceProvider);

  final provider = ImageToTextProvider(ocrService, translationService);

  // 设置清理回调
  ref.onDispose(() {
    provider.dispose();
  });

  return provider;
});

/// 图片转文本状态
class ImageToTextState {
  final bool isRecognizing;
  final String recognizedText;
  final bool isTranslating;
  final String translatedText;
  final String? error;

  ImageToTextState({
    this.isRecognizing = false,
    this.recognizedText = '',
    this.isTranslating = false,
    this.translatedText = '',
    this.error,
  });

  ImageToTextState copyWith({
    bool? isRecognizing,
    String? recognizedText,
    bool? isTranslating,
    String? translatedText,
    String? error,
  }) {
    return ImageToTextState(
      isRecognizing: isRecognizing ?? this.isRecognizing,
      recognizedText: recognizedText ?? this.recognizedText,
      isTranslating: isTranslating ?? this.isTranslating,
      translatedText: translatedText ?? this.translatedText,
      error: error ?? this.error,
    );
  }
}

/// 图片转文本状态管理 Notifier
class ImageToTextNotifier extends StateNotifier<ImageToTextState> {
  final ImageToTextProvider _provider;
  final Logger _logger = Logger();

  ImageToTextNotifier(this._provider) : super(ImageToTextState());

  /// 初始化
  Future<bool> initialize() async {
    try {
      return await _provider.initialize();
    } catch (e) {
      _logger.e('[ImageToTextNotifier] Error initializing: $e');
      state = state.copyWith(error: 'Initialization failed: $e');
      return false;
    }
  }

  /// 开始从文件进行图片转文本转换
  Future<void> startImageToText({
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
    String recognitionLanguage = 'auto',
  }) async {
    try {
      state = state.copyWith(isRecognizing: true, error: null);

      await _provider.startImageToText(
        imagePath: imagePath,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        recognitionLanguage: recognitionLanguage,
        onRecognizing: () {
          state = state.copyWith(isRecognizing: true);
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
          _logger.e('[ImageToTextNotifier] Error: $error');
          state = state.copyWith(
            error: error,
            isRecognizing: false,
            isTranslating: false,
          );
        },
      );
    } catch (e) {
      _logger.e('[ImageToTextNotifier] Error starting image to text: $e');
      state = state.copyWith(
        error: 'Failed to start: $e',
        isRecognizing: false,
      );
    }
  }

  /// 开始从字节进行图片转文本转换
  Future<void> startImageToTextFromBytes({
    required List<int> imageBytes,
    required String sourceLanguage,
    required String targetLanguage,
    String recognitionLanguage = 'auto',
  }) async {
    try {
      state = state.copyWith(isRecognizing: true, error: null);

      await _provider.startImageToTextFromBytes(
        imageBytes: imageBytes,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        recognitionLanguage: recognitionLanguage,
        onRecognizing: () {
          state = state.copyWith(isRecognizing: true);
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
          _logger.e('[ImageToTextNotifier] Error: $error');
          state = state.copyWith(
            error: error,
            isRecognizing: false,
            isTranslating: false,
          );
        },
      );
    } catch (e) {
      _logger.e('[ImageToTextNotifier] Error starting: $e');
      state = state.copyWith(
        error: 'Failed to start: $e',
        isRecognizing: false,
      );
    }
  }

  /// 检查 OCR 识别是否可用
  Future<bool> isOCRAvailable() async {
    try {
      return await _provider.isOCRAvailable();
    } catch (e) {
      _logger.e('[ImageToTextNotifier] Error checking availability: $e');
      return false;
    }
  }
}

/// 图片转文本状态 StateNotifier Provider
final imageToTextStateProvider =
    StateNotifierProvider<ImageToTextNotifier, ImageToTextState>((ref) {
  final provider = ref.watch(imageToTextProvider);
  final notifier = ImageToTextNotifier(provider);

  // 自动初始化
  notifier.initialize();

  // 设置清理回调
  ref.onDispose(() {
    // 清理会由 ImageToTextProvider 的清理逻辑处理
  });

  return notifier;
});

/// 便捷 Provider：检查 OCR 识别是否可用
final isOCRAvailableProvider = FutureProvider<bool>((ref) async {
  final provider = ref.watch(imageToTextProvider);
  return provider.isOCRAvailable();
});
