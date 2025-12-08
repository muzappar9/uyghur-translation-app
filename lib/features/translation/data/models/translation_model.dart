import '../../../../shared/data/models/isar_models/translation_history_model.dart';

/// 翻译模型
class TranslationModel {
  /// 记录 ID
  final int id;

  /// 原始文本
  final String sourceText;

  /// 翻译文本
  final String translatedText;

  /// 源语言
  final String sourceLanguage;

  /// 目标语言
  final String targetLanguage;

  /// 翻译时间
  final DateTime timestamp;

  /// 用户 ID
  final String? userId;

  /// 是否已同步
  final bool isSynced;

  /// 构造函数
  const TranslationModel({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.userId,
    this.isSynced = false,
  });

  /// 从 Isar 模型转换
  factory TranslationModel.fromIsar(TranslationHistoryModel isar) {
    return TranslationModel(
      id: isar.id,
      sourceText: isar.sourceText,
      translatedText: isar.translatedText,
      sourceLanguage: isar.sourceLanguage,
      targetLanguage: isar.targetLanguage,
      timestamp: isar.timestamp,
      userId: isar.userId,
      isSynced: isar.isSynced,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'isSynced': isSynced,
    };
  }

  @override
  String toString() {
    return 'TranslationModel(id: $id, source: "$sourceText", target: "$translatedText")';
  }
}
