import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uyghur_translator/shared/services/ocr/ocr_recognition_manager.dart';
import 'package:logger/logger.dart';

part 'ocr_provider.freezed.dart';

/// OCR识别状态
@freezed
class OcrState with _$OcrState {
  const factory OcrState({
    @Default(null) String? imagePath,
    @Default('') String recognizedText,
    @Default(null) String? error,
    @Default(false) bool isProcessing,
    @Default('en') String language,
    @Default(false) bool hasPermission,
  }) = _OcrState;
}

/// OCR识别 StateNotifier
class OcrNotifier extends StateNotifier<OcrState> {
  final OCRRecognitionManager _ocrManager;
  final Logger _logger = Logger();

  OcrNotifier(this._ocrManager) : super(const OcrState());

  /// 检查权限
  Future<void> checkPermission() async {
    try {
      final hasPermission = await _ocrManager.hasPermission();
      state = state.copyWith(hasPermission: hasPermission);
      _logger.i('Camera permission checked: $hasPermission');
    } catch (e) {
      _logger.e('Failed to check permission: $e');
      state = state.copyWith(error: 'Permission check failed: $e');
    }
  }

  /// 请求权限
  Future<void> requestPermission() async {
    try {
      final granted = await _ocrManager.requestPermission();
      state = state.copyWith(hasPermission: granted);
      if (!granted) {
        state = state.copyWith(error: 'Camera permission denied');
      }
      _logger.i('Camera permission requested: $granted');
    } catch (e) {
      _logger.e('Failed to request permission: $e');
      state = state.copyWith(error: 'Permission request failed: $e');
    }
  }

  /// 从文件识别OCR
  Future<void> recognizeFromFile(String filePath) async {
    if (!state.hasPermission) {
      await requestPermission();
      if (!state.hasPermission) {
        return;
      }
    }

    state = state.copyWith(
      imagePath: filePath,
      isProcessing: true,
      error: null,
    );

    try {
      final result = await _ocrManager.recognizeFromFile(filePath);

      state = state.copyWith(
        recognizedText: result,
        isProcessing: false,
        error: null,
      );

      _logger.i('OCR recognition successful: "${result.substring(0, 50)}..."');
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Recognition error: $e',
      );
      _logger.e('OCR recognition error: $e');
    }
  }

  /// 从字节识别OCR
  Future<void> recognizeFromBytes(List<int> bytes) async {
    if (!state.hasPermission) {
      await requestPermission();
      if (!state.hasPermission) {
        return;
      }
    }

    state = state.copyWith(
      isProcessing: true,
      error: null,
    );

    try {
      final result = await _ocrManager.recognizeFromBytes(bytes);

      state = state.copyWith(
        recognizedText: result,
        isProcessing: false,
        error: null,
      );

      _logger.i('OCR recognition successful from bytes');
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Recognition error: $e',
      );
      _logger.e('OCR recognition error: $e');
    }
  }

  /// 设置语言
  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  /// 清除识别结果
  void clearResult() {
    state = state.copyWith(
      imagePath: null,
      recognizedText: '',
      error: null,
    );
  }
}

/// OCR识别 Manager Provider
final ocrManagerProvider = Provider<OCRRecognitionManager>((ref) {
  return OCRRecognitionManager();
});

/// OCR识别状态 Provider
final ocrProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  final manager = ref.watch(ocrManagerProvider);
  return OcrNotifier(manager);
});

/// 支持的语言列表 Provider
final ocrSupportedLanguagesProvider = Provider<List<String>>((ref) {
  return const ['en', 'zh', 'ug', 'tr'];
});
