/// 翻译引擎接口 - 定义翻译能力的抽象
/// 支持多种实现：本地模型、远程API、混合方案等
abstract class TranslationEngine {
  /// 翻译文本
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  );

  /// 检查引擎是否可用
  /// 返回 true 表示可以使用（网络连接、模型已加载等）
  Future<bool> isAvailable();

  /// 获取引擎名称
  String get name;

  /// 获取引擎优先级（数字越大优先级越高）
  int get priority;
}

/// Mock 本地翻译引擎实现
/// 可用于开发测试，或作为离线备选方案
class LocalMockTranslationEngine implements TranslationEngine {
  // 模拟翻译数据库
  static const Map<String, Map<String, String>> _translations = {
    'hello': {
      'en_zh': '你好',
      'en_ug': 'سلام',
      'zh_en': 'hello',
      'zh_ug': 'سلام',
      'ug_en': 'hello',
      'ug_zh': '你好',
    },
    'good morning': {
      'en_zh': '早上好',
      'en_ug': 'خەيسەتسىز',
      'zh_en': 'good morning',
      'ug_en': 'good morning',
    },
    'thank you': {
      'en_zh': '谢谢',
      'en_ug': 'رەھمەت',
      'zh_en': 'thank you',
      'ug_en': 'thank you',
    },
    'how are you': {
      'en_zh': '你好吗',
      'en_ug': 'سىز قانداق؟',
      'zh_en': 'how are you?',
      'ug_en': 'how are you?',
    },
    'goodbye': {
      'en_zh': '再见',
      'en_ug': 'خوش بولۇڭ',
      'zh_en': 'goodbye',
      'ug_en': 'goodbye',
    },
  };

  @override
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    final key = text.toLowerCase().trim();
    final langPair = '${sourceLang}_$targetLang';

    if (_translations.containsKey(key)) {
      final result = _translations[key]?[langPair];
      if (result != null) {
        return result;
      }
    }

    // 如果没有匹配的翻译，返回带标记的原文
    // 实际应用中可能会返回错误或使用其他策略
    return '【$text】';
  }

  @override
  Future<bool> isAvailable() async {
    // 本地引擎总是可用的
    return true;
  }

  @override
  String get name => 'Local Mock Translation Engine';

  @override
  int get priority => 1; // 最低优先级
}

/// API 翻译引擎 - 包装翻译 API 接口
/// 可用于 DeepSeek、科大讯飞、腾讯混元等远程翻译服务
class ApiTranslationEngine implements TranslationEngine {
  final dynamic api; // TranslationApi
  final String _name;
  final int _priority;

  ApiTranslationEngine({
    required this.api,
    required String name,
    int priority = 10,
  })  : _name = name,
        _priority = priority;

  @override
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final result = await api.translate(
        text: text,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
      return result.translatedText;
    } catch (e) {
      throw Exception('API translation failed: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // 简单检查 API 是否可访问
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String get name => _name;

  @override
  int get priority => _priority;
}
