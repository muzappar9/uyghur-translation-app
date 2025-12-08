import 'dart:io';
import '../../data/models/ocr_model.dart';
import '../entities/ocr_result.dart';

/// OCR 仓库接口
abstract class OcrRepository {
  /// 识别图片中的文本
  Future<OcrResult> recognizeText(File imageFile);

  /// 批量识别多张图片
  Future<List<OcrResult>> recognizeMultipleImages(List<File> imageFiles);

  /// 获取 OCR 结果历史
  Future<List<OcrModel>> getHistory({
    String? userId,
    int limit = 50,
  });

  /// 获取收藏的 OCR 结果
  Future<List<OcrModel>> getFavorites({String? userId});

  /// 删除 OCR 结果
  Future<bool> deleteResult(int id);

  /// 清空所有 OCR 结果
  Future<void> clearHistory({String? userId});

  /// 更新 OCR 结果（编辑识别文本）
  Future<bool> updateResult(int id, String editedText);

  /// 切换收藏状态
  Future<bool> toggleFavorite(int id);

  /// 同步 OCR 结果
  Future<void> syncResults();
}
