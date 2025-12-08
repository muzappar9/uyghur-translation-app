import 'dart:async';
import 'package:translator/translator.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// Google Translate 服务
/// 提供文本翻译功能
class GoogleTranslateService {
  final GoogleTranslator _translator = GoogleTranslator();

  /// 翻译文本
  ///
  /// [text]: 要翻译的文本
  /// [sourceLanguage]: 源语言代码 (例如: 'en', 'zh', 'ug')
  /// [targetLanguage]: 目标语言代码
  ///
  /// 返回翻译后的文本
  /// 如果翻译失败，抛出 [ApiException]
  Future<String> translate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      if (text.isEmpty) {
        return ''; // 空文本直接返回
      }

      // 使用 translator 包进行翻译
      final translation = await _translator.translate(
        text,
        from: sourceLanguage,
        to: targetLanguage,
      );

      return translation.toString();
    } on TimeoutException catch (_) {
      throw ApiException('Translation request timeout');
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      }
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Translation failed: ${e.toString()}');
    }
  }

  /// 检测文本语言
  ///
  /// [text]: 要检测的文本
  ///
  /// 返回语言代码列表
  Future<String> detectLanguage(String text) async {
    try {
      if (text.isEmpty) {
        return 'unknown';
      }

      // translator 包没有内置的语言检测，使用启发式方法
      // 在生产环境中应使用 Google Language API

      // 简单的启发式检测（基于字符范围）
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

      // 默认英文
      return 'en';
    } catch (e) {
      throw ApiException('Language detection failed: ${e.toString()}');
    }
  }

  /// 获取支持的语言列表
  ///
  /// 返回支持的语言代码列表
  Future<Map<String, String>> getAvailableLanguages() async {
    // 返回常用语言列表
    return const {
      'en': 'English',
      'zh': 'Chinese Simplified',
      'zh-TW': 'Chinese Traditional',
      'ug': 'Uyghur',
      'ar': 'Arabic',
      'ru': 'Russian',
      'tr': 'Turkish',
      'fr': 'French',
      'de': 'German',
      'es': 'Spanish',
      'ja': 'Japanese',
      'ko': 'Korean',
    };
  }

  /// 批量翻译文本
  ///
  /// [texts]: 要翻译的文本列表
  /// [sourceLanguage]: 源语言代码
  /// [targetLanguage]: 目标语言代码
  ///
  /// 返回翻译后的文本列表
  Future<List<String>> translateBatch(
    List<String> texts,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final results = <String>[];

      for (final text in texts) {
        final translation =
            await translate(text, sourceLanguage, targetLanguage);
        results.add(translation);
      }

      return results;
    } catch (e) {
      throw ApiException('Batch translation failed: ${e.toString()}');
    }
  }

  // === 辅助方法 ===

  /// 检查文本是否包含中文字符
  bool _containsChinese(String text) {
    final chineseRegex = RegExp(r'[\u4E00-\u9FFF]');
    return chineseRegex.hasMatch(text);
  }

  /// 检查文本是否包含阿拉伯文字
  bool _containsArabicScript(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text);
  }

  /// 检查文本是否包含维吾尔语特定字符
  bool _containsUyghurCharacters(String text) {
    // 维吾尔语特定的阿拉伯字符
    final uyghurRegex = RegExp(r'[\u06C7\u06C8\u0686\u06AD]');
    return uyghurRegex.hasMatch(text);
  }

  /// 检查文本是否包含西里尔字母
  bool _containsCyrillic(String text) {
    final cyrillicRegex = RegExp(r'[\u0400-\u04FF]');
    return cyrillicRegex.hasMatch(text);
  }
}
