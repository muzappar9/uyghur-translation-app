/// 翻译结果
class TranslationResult {
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isSuccess;
  final String? errorMessage;
  final DateTime timestamp;

  TranslationResult({
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.isSuccess = true,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 成功的翻译结果
  factory TranslationResult.success({
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return TranslationResult(
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isSuccess: true,
    );
  }

  /// 失败的翻译结果
  factory TranslationResult.failure({
    required String errorMessage,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return TranslationResult(
      translatedText: '',
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  /// 离线模式结果
  factory TranslationResult.offline({
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return TranslationResult(
      translatedText: '',
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isSuccess: false,
      errorMessage: 'Offline mode: No translation available',
    );
  }

  @override
  String toString() =>
      'TranslationResult(success: $isSuccess, src: $sourceLanguage, tgt: $targetLanguage)';
}
