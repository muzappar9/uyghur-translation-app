/// OCR 识别结果
class OcrResult {
  final bool success;
  final String recognizedText;
  final String detectedLanguage;
  final double confidence;
  final String? errorMessage;
  final DateTime timestamp;

  OcrResult({
    required this.success,
    required this.recognizedText,
    required this.detectedLanguage,
    this.confidence = 0.0,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 成功的 OCR 结果
  factory OcrResult.success({
    required String recognizedText,
    required String detectedLanguage,
    double confidence = 0.9,
  }) {
    return OcrResult(
      success: true,
      recognizedText: recognizedText,
      detectedLanguage: detectedLanguage,
      confidence: confidence,
    );
  }

  /// 失败的 OCR 结果
  factory OcrResult.failure(String errorMessage) {
    return OcrResult(
      success: false,
      recognizedText: '',
      detectedLanguage: '',
      confidence: 0.0,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() =>
      'OcrResult(success: $success, lang: $detectedLanguage, conf: $confidence)';
}
