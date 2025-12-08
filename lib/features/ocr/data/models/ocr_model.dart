import '../../../../shared/data/models/isar_models/ocr_result_model.dart';

/// OCR 模型
class OcrModel {
  /// 记录 ID
  final int id;

  /// 图片 URL
  final String imageUrl;

  /// 识别的文本
  final String recognizedText;

  /// 检测到的语言
  final String detectedLanguage;

  /// 编辑历史
  final List<String> editHistory;

  /// 创建时间
  final DateTime createdAt;

  /// 最后修改时间
  final DateTime? lastModified;

  /// 用户 ID
  final String? userId;

  /// 是否已收藏
  final bool isFavorite;

  /// 是否已同步
  final bool isSynced;

  /// 构造函数
  const OcrModel({
    required this.id,
    required this.imageUrl,
    required this.recognizedText,
    required this.detectedLanguage,
    required this.editHistory,
    required this.createdAt,
    this.lastModified,
    this.userId,
    this.isFavorite = false,
    this.isSynced = false,
  });

  /// 从 Isar 模型转换
  factory OcrModel.fromIsar(OcrResultModel isar) {
    return OcrModel(
      id: isar.id,
      imageUrl: isar.imageUrl,
      recognizedText: isar.recognizedText,
      detectedLanguage: isar.detectedLanguage,
      editHistory: isar.editHistory,
      createdAt: isar.createdAt,
      lastModified: isar.lastModified,
      userId: isar.userId,
      isFavorite: isar.isFavorite,
      isSynced: isar.isSynced,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'recognizedText': recognizedText,
      'detectedLanguage': detectedLanguage,
      'editHistory': editHistory,
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'userId': userId,
      'isFavorite': isFavorite,
      'isSynced': isSynced,
    };
  }

  @override
  String toString() {
    return 'OcrModel(id: $id, language: $detectedLanguage, text: "${recognizedText.substring(0, 30)}...")';
  }
}
