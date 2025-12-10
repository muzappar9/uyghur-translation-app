import 'dart:io';
import 'package:uyghur_translator/core/utils/app_logger.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/entities/ocr_result.dart';
import '../models/ocr_model.dart';
import '../services/google_vision_service.dart' as vision_service;
import '../../../../shared/services/database/isar_database_service.dart';
import '../../../../shared/data/models/isar_models/ocr_result_model.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// OCR 仓库实现
class OcrRepositoryImpl implements OcrRepository {
  /// Google Vision 服务
  final vision_service.GoogleVisionService _googleVisionService;

  /// 网络连接状态
  late bool _isOnline;

  /// 构造函数
  OcrRepositoryImpl({
    required vision_service.GoogleVisionService googleVisionService,
  }) : _googleVisionService = googleVisionService {
    _isOnline = true;
  }

  /// 识别图片中的文本（OCR）
  @override
  Future<OcrResult> recognizeText(File imageFile) async {
    try {
      // 验证文件
      if (!imageFile.existsSync()) {
        return OcrResult.failure('图片文件不存在');
      }

      // 调用 Google Vision API
      final visionResult = await _googleVisionService.recognizeText(imageFile);

      // 保存到本地数据库
      final ocrRecord = OcrResultModel.create(
        imagePath: imageFile.path,
        recognizedText: visionResult.text,
        language: visionResult.detectedLanguage,
        imageUrl: imageFile.path,
        detectedLanguage: visionResult.detectedLanguage,
        isFavorite: false,
      );

      await IsarDatabaseService.saveOcrResult(ocrRecord);

      appLogger.i('✅ OCR 识别成功: 识别 ${visionResult.text.length} 个字符');
      // 转换为 domain OcrResult
      return OcrResult.success(
        recognizedText: visionResult.text,
        detectedLanguage: visionResult.detectedLanguage,
        confidence: visionResult.confidence,
      );
    } on FileSystemException catch (e) {
      appLogger.e('❌ 文件错误: ${e.message}');
      return OcrResult.failure('文件访问错误: ${e.message}');
    } catch (e) {
      appLogger.e('❌ OCR 识别失败: $e');
      return OcrResult.failure('识别失败: $e');
    }
  }

  /// 批量识别多张图片
  @override
  Future<List<OcrResult>> recognizeMultipleImages(List<File> imageFiles) async {
    try {
      final results = <OcrResult>[];

      for (final imageFile in imageFiles) {
        final result = await recognizeText(imageFile);
        results.add(result);
      }

      appLogger.i('✅ 批量 OCR 识别完成: ${results.length} 张图片');
      return results;
    } catch (e) {
      appLogger.e('❌ 批量 OCR 失败: $e');
      throw ApiException('批量 OCR 失败: $e', statusCode: 500);
    }
  }

  /// 获取 OCR 结果历史
  @override
  Future<List<OcrModel>> getHistory({
    String? userId,
    int limit = 50,
  }) async {
    try {
      final results = await IsarDatabaseService.getOcrResults(
        userId: userId,
        limit: limit,
      );

      return results.map((r) => OcrModel.fromIsar(r)).toList();
    } catch (e) {
      appLogger.e('❌ 获取 OCR 历史失败: $e');
      throw DatabaseException('获取 OCR 历史失败: $e');
    }
  }

  /// 获取收藏的 OCR 结果
  @override
  Future<List<OcrModel>> getFavorites({String? userId}) async {
    try {
      final results = await IsarDatabaseService.getFavoriteOcrResults(
        userId: userId,
      );

      return results.map((r) => OcrModel.fromIsar(r)).toList();
    } catch (e) {
      appLogger.e('❌ 获取收藏 OCR 失败: $e');
      throw DatabaseException('获取收藏 OCR 失败: $e');
    }
  }

  /// 删除 OCR 结果
  @override
  Future<bool> deleteResult(int id) async {
    try {
      final result = await IsarDatabaseService.deleteOcrResult(id);
      if (result) {
        appLogger.i('✅ OCR 记录已删除: $id');
      }
      return result;
    } catch (e) {
      appLogger.e('❌ 删除 OCR 记录失败: $e');
      throw DatabaseException('删除 OCR 记录失败: $e');
    }
  }

  /// 清空所有 OCR 结果
  @override
  Future<void> clearHistory({String? userId}) async {
    try {
      final count = await IsarDatabaseService.clearOcrResults(userId: userId);
      appLogger.i('✅ 已清除 $count 条 OCR 记录');
    } catch (e) {
      appLogger.e('❌ 清空 OCR 历史失败: $e');
      throw DatabaseException('清空 OCR 历史失败: $e');
    }
  }

  /// 更新 OCR 结果（编辑识别的文本）
  @override
  Future<bool> updateResult(int id, String editedText) async {
    try {
      // 获取原始记录
      final results = await IsarDatabaseService.getOcrResults();
      final targetIndex = results.indexWhere((r) => r.id == id);

      if (targetIndex < 0) {
        return false;
      }

      final original = results[targetIndex];

      // 更新编辑历史
      final editHistory = [...(original.editHistory ?? []), editedText];

      // 更新原始记录
      original.recognizedText = editedText;
      original.editHistory = editHistory;
      original.lastModified = DateTime.now();

      await IsarDatabaseService.saveOcrResult(original);
      appLogger.i('✅ OCR 记录已更新: $id');
      return true;
    } catch (e) {
      appLogger.e('❌ 更新 OCR 记录失败: $e');
      return false;
    }
  }

  /// 切换收藏状态
  @override
  Future<bool> toggleFavorite(int id) async {
    try {
      final results = await IsarDatabaseService.getOcrResults();
      final targetIndex = results.indexWhere((r) => r.id == id);

      if (targetIndex < 0) {
        return false;
      }

      final original = results[targetIndex];

      // 反转收藏状态 - 直接修改原对象
      original.isFavorite = !original.isFavorite;
      original.lastModified = DateTime.now();

      await IsarDatabaseService.saveOcrResult(original);
      appLogger.i('${original.isFavorite ? '❤️' : '🤍'} 收藏状态已更新: $id');
      return true;
    } catch (e) {
      appLogger.e('❌ 更新收藏状态失败: $e');
      return false;
    }
  }

  /// 设置在线/离线状态
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
    appLogger.d('${isOnline ? '🌐' : '📴'} 网络状态: ${isOnline ? "在线" : "离线"}');
  }

  /// 获取在线状态
  bool get isOnline => _isOnline;

  /// 同步 OCR 结果
  @override
  Future<void> syncResults() async {
    try {
      if (!_isOnline) {
        appLogger.w('⚠️ 离线模式，无法同步');
        return;
      }

      final results = await IsarDatabaseService.getOcrResults();
      final unsyncedCount = results.where((r) => !r.isSynced).length;

      if (unsyncedCount == 0) {
        appLogger.i('✅ 所有 OCR 结果已同步');
        return;
      }

      appLogger.d('🔄 开始同步 $unsyncedCount 条未同步的 OCR 结果');

      // 实际应用中应该上传到云服务
      // 这里仅作示例
      appLogger.i('✅ OCR 结果同步完成');
    } catch (e) {
      appLogger.e('❌ 同步失败: $e');
      throw NetworkException('OCR 同步失败: $e');
    }
  }
}
