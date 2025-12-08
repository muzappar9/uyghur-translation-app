/// 翻译历史记录模型
class TranslationHistoryModel {
  final int? id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final bool isSynced;
  final String? userId;

  TranslationHistoryModel({
    this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    DateTime? timestamp,
    this.isSynced = false,
    this.userId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  factory TranslationHistoryModel.fromJson(Map<String, dynamic> json) {
    return TranslationHistoryModel(
      id: json['id'],
      sourceText: json['sourceText'] ?? '',
      translatedText: json['translatedText'] ?? '',
      sourceLanguage: json['sourceLanguage'] ?? 'en',
      targetLanguage: json['targetLanguage'] ?? 'zh',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isSynced: json['isSynced'] ?? false,
      userId: json['userId'],
    );
  }

  @override
  String toString() =>
      'TranslationHistoryModel(src: $sourceLanguage, tgt: $targetLanguage)';
}
