import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ocr_repository_impl.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../data/services/google_vision_service.dart';

/// Google Vision 服务提供者
final googleVisionServiceProvider = Provider<GoogleVisionService>((ref) {
  return GoogleVisionService();
});

/// OCR 仓库提供者
final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  final googleVisionService = ref.watch(googleVisionServiceProvider);

  return OcrRepositoryImpl(
    googleVisionService: googleVisionService,
  );
});

/// 识别图片文本
final recognizeTextProvider =
    FutureProvider.family<dynamic, File>((ref, imageFile) async {
  final repository = ref.watch(ocrRepositoryProvider);
  return repository.recognizeText(imageFile);
});

/// 批量识别图片
final recognizeMultipleProvider =
    FutureProvider.family<dynamic, List<File>>((ref, imageFiles) async {
  final repository = ref.watch(ocrRepositoryProvider);
  return repository.recognizeMultipleImages(imageFiles);
});

/// 获取 OCR 历史
final ocrHistoryProvider = FutureProvider.family<
    dynamic,
    ({
      String? userId,
      int limit,
    })>((ref, params) async {
  final repository = ref.watch(ocrRepositoryProvider);
  return repository.getHistory(
    userId: params.userId,
    limit: params.limit,
  );
});

/// 获取收藏的 OCR 结果
final ocrFavoritesProvider =
    FutureProvider.family<dynamic, String?>((ref, userId) async {
  final repository = ref.watch(ocrRepositoryProvider);
  return repository.getFavorites(userId: userId);
});

/// 同步 OCR 结果
final syncOcrProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(ocrRepositoryProvider);
  return repository.syncResults();
});
