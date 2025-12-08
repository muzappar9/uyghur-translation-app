import 'dart:io';
import 'dart:async';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Vision API OCR 识别结果（内部使用）
class VisionOcrResult {
  final String text;
  final String detectedLanguage;
  final List<String> recognizedLanguages;
  final double confidence;
  final DateTime timestamp;

  VisionOcrResult({
    required this.text,
    required this.detectedLanguage,
    required this.recognizedLanguages,
    this.confidence = 0.9,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 创建错误结果
  factory VisionOcrResult.error(String message) {
    return VisionOcrResult(
      text: '❌ Error: $message',
      detectedLanguage: 'unknown',
      recognizedLanguages: [],
      confidence: 0.0,
    );
  }

  /// 创建空结果
  factory VisionOcrResult.empty() {
    return VisionOcrResult(
      text: '',
      detectedLanguage: '',
      recognizedLanguages: [],
      confidence: 0.0,
    );
  }

  bool get isEmpty => text.isEmpty;

  bool get isError => text.startsWith('❌');
}

/// Google Vision OCR 服务
/// 提供图像文字识别功能
class GoogleVisionService {
  late final TextRecognizer _textRecognizer;

  GoogleVisionService() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  /// 识别图像中的文本
  ///
  /// [imageFile]: 图像文件
  ///
  /// 返回 [OcrResult] 对象
  /// 如果失败，返回包含错误信息的 OcrResult
  Future<VisionOcrResult> recognizeText(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        throw FileSystemException('Image file not found: ${imageFile.path}');
      }

      // 创建 InputImage
      final inputImage = InputImage.fromFile(imageFile);

      // 执行文字识别
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return VisionOcrResult.empty();
      }

      // 检测语言
      final detectedLanguage = _detectLanguage(recognizedText.text);
      final recognizedLanguages = _extractLanguages(recognizedText.text);

      // 计算置信度（基于检测到的文字块数和分数）
      double totalConfidence = 0.0;
      int blockCount = recognizedText.blocks.length;

      if (blockCount > 0) {
        for (final block in recognizedText.blocks) {
          for (final line in block.lines) {
            totalConfidence += line.confidence ?? 0.9;
          }
        }
        totalConfidence = totalConfidence / blockCount;
      } else {
        totalConfidence = 0.9;
      }

      return VisionOcrResult(
        text: recognizedText.text,
        detectedLanguage: detectedLanguage,
        recognizedLanguages: recognizedLanguages,
        confidence: totalConfidence,
      );
    } on FileSystemException catch (e) {
      throw FileSystemException(e.toString());
    } catch (e) {
      throw ApiException('OCR recognition failed: ${e.toString()}');
    }
  }

  /// 识别多个图像中的文本
  ///
  /// [imagePaths]: 图像文件路径列表
  ///
  /// 返回识别结果列表
  Future<List<VisionOcrResult>> recognizeMultipleImages(
    List<String> imagePaths,
  ) async {
    final results = <VisionOcrResult>[];

    for (final path in imagePaths) {
      try {
        final file = File(path);
        final result = await recognizeText(file);
        results.add(result);
      } catch (e) {
        results.add(VisionOcrResult.error('Failed to process $path: $e'));
      }
    }

    return results;
  }

  /// 从 URL 识别文本
  ///
  /// [imageUrl]: 图像 URL
  ///
  /// 注意：此方法需要先下载图像，在实际应用中需要网络权限
  Future<VisionOcrResult> recognizeTextFromUrl(String imageUrl) async {
    try {
      throw UnimplementedError(
        'URL-based OCR requires network access and is not implemented in this version. '
        'Use recognizeText() with a File instead.',
      );
    } catch (e) {
      throw ApiException('URL recognition failed: ${e.toString()}');
    }
  }

  /// 检测图像中的语言
  ///
  /// [imageFile]: 图像文件
  ///
  /// 返回检测到的语言代码列表
  Future<List<String>> detectLanguagesInImage(File imageFile) async {
    try {
      final result = await recognizeText(imageFile);
      return result.recognizedLanguages;
    } catch (e) {
      throw ApiException('Language detection failed: ${e.toString()}');
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await _textRecognizer.close();
  }

  // === 辅助方法 ===

  /// 检测文本语言
  String _detectLanguage(String text) {
    if (text.isEmpty) return 'unknown';

    // 根据字符范围检测语言
    if (_containsArabicScript(text)) {
      if (_containsUyghurCharacters(text)) {
        return 'ug'; // 维吾尔语
      }
      return 'ar'; // 阿拉伯语
    }

    if (_containsChinese(text)) {
      return 'zh';
    }

    if (_containsCyrillic(text)) {
      return 'ru';
    }

    if (_containsLatin(text)) {
      return 'en'; // 简化，实际应检查更多特征
    }

    return 'unknown';
  }

  /// 提取文本中识别到的语言列表
  List<String> _extractLanguages(String text) {
    final languages = <String>{};

    if (_containsArabicScript(text)) {
      if (_containsUyghurCharacters(text)) {
        languages.add('ug');
      } else {
        languages.add('ar');
      }
    }

    if (_containsChinese(text)) {
      languages.add('zh');
    }

    if (_containsCyrillic(text)) {
      languages.add('ru');
    }

    if (_containsLatin(text)) {
      languages.add('en');
    }

    return languages.toList();
  }

  // === 字符检测辅助方法 ===

  bool _containsChinese(String text) {
    final chineseRegex = RegExp(r'[\u4E00-\u9FFF]');
    return chineseRegex.hasMatch(text);
  }

  bool _containsArabicScript(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  bool _containsUyghurCharacters(String text) {
    final uyghurRegex = RegExp(r'[\u06C7\u06C8\u0686\u06AD]');
    return uyghurRegex.hasMatch(text);
  }

  bool _containsCyrillic(String text) {
    final cyrillicRegex = RegExp(r'[\u0400-\u04FF]');
    return cyrillicRegex.hasMatch(text);
  }

  bool _containsLatin(String text) {
    final latinRegex = RegExp(r'[a-zA-Z]');
    return latinRegex.hasMatch(text);
  }
}
