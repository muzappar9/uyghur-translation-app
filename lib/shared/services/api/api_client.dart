import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// HTTP 客户端 - 支持翻译、词典等 API
class ApiClient {
  final Dio _dio;
  final Logger _logger = Logger();
  
  // Mock 翻译数据库
  static const Map<String, Map<String, String>> _mockTranslations = {
    'hello': {
      'en_zh': '你好',
      'en_ug': 'سلام',
      'zh_en': 'Hello',
      'zh_ug': 'سلام',
      'ug_en': 'Hello',
      'ug_zh': '你好',
    },
    'good morning': {
      'en_zh': '早上好',
      'en_ug': 'خەيسەتسىز',
      'zh_en': 'Good morning',
      'ug_en': 'Good morning',
    },
    'thank you': {
      'en_zh': '谢谢',
      'en_ug': 'رەھمەت',
      'zh_en': 'Thank you',
      'ug_en': 'Thank you',
    },
    'how are you': {
      'en_zh': '你好吗',
      'en_ug': 'سىز قانداق؟',
      'zh_en': 'How are you?',
      'ug_en': 'How are you?',
    },
  };

  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('API Request: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// 翻译文本（支持 Mock 数据和真实 API）
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      // 当前使用 Mock 数据（生产环境应连接真实 API）
      final result = _translateMock(text, sourceLang, targetLang);
      
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));
      
      _logger.i('Translation: "$text" ($sourceLang→$targetLang) = "$result"');
      return result;
    } catch (e) {
      _logger.e('Translation error: $e');
      throw TranslationException('翻译失败: $e');
    }
  }

  /// Mock 翻译实现
  String _translateMock(String text, String sourceLang, String targetLang) {
    final key = text.toLowerCase().trim();
    final langPair = '${sourceLang}_$targetLang';
    
    if (_mockTranslations.containsKey(key)) {
      final translation = _mockTranslations[key]![langPair];
      if (translation != null) {
        return translation;
      }
    }
    
    // 如果没有找到，返回原文加标记
    return '[$text]';
  }

  /// 获取词典数据（Mock）
  Future<Map<String, dynamic>> getWordDefinition(String word) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'word': word,
        'phonetic': '/həˈloʊ/',
        'meanings': [
          {
            'partOfSpeech': 'noun',
            'definition': '用作问候语或引起注意的表达',
            'example': 'Hello, how are you?'
          }
        ],
        'translations': {
          'zh': '你好',
          'ug': 'سلام',
        }
      };
    } catch (e) {
      _logger.e('Dictionary error: $e');
      throw ApiException('获取词典失败: $e');
    }
  }

  /// 获取推荐词汇列表（Mock）
  Future<List<String>> getRecommendedWords() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      return ['hello', 'good morning', 'thank you', 'how are you', 'goodbye'];
    } catch (e) {
      _logger.e('Recommended words error: $e');
      throw ApiException('获取推荐词汇失败: $e');
    }
  }

  /// 搜索词汇
  Future<List<String>> searchWords(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final results = _mockTranslations.keys
          .where((word) => word.contains(query.toLowerCase()))
          .toList();
      
      return results;
    } catch (e) {
      _logger.e('Search error: $e');
      throw ApiException('搜索失败: $e');
    }
  }
}

/// 翻译异常
class TranslationException implements Exception {
  final String message;
  TranslationException(this.message);
  
  @override
  String toString() => message;
}

/// API 通用异常
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

/// API 客户端 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
