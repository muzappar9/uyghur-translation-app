import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uyghur_translator/core/error/error_handler.dart'
    as app_error_handler;
import 'package:uyghur_translator/core/exceptions/app_exceptions.dart';

/// 腾讯云翻译服务
/// 支持中文、英文、维吾尔语等多语言翻译
/// 文档: https://cloud.tencent.com/document/product/551
class TencentTranslationService {
  final Dio _dio;
  final Logger _logger = Logger();

  // 腾讯云API配置（保留以供未来使用）
  // static const String _endpoint = 'https://tmt.tencentcloudapi.com';
  // static const String _service = 'tmt';
  // static const String _action = 'TextTranslate';
  // static const String _version = '2018-03-21';
  // static const String _region = 'ap-beijing';

  // 模拟使用（生产环境需要真实密钥）
  final String secretId;
  final String secretKey;
  final String projectId;

  TencentTranslationService({
    required this.secretId,
    required this.secretKey,
    required this.projectId,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('TencentTranslation Request: ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) {
          _logger.e('TencentTranslation Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// 翻译文本
  /// 支持的语言对: zh ↔ en, zh ↔ ug, en ↔ ug 等
  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      // 验证输入
      if (text.isEmpty) {
        throw ValidationException('text', 'Translation text cannot be empty');
      }

      if (text.length > 5000) {
        throw ValidationException(
            'text', 'Translation text exceeds 5000 characters');
      }

      // 标准化语言代码
      final source = _normalizeLanguageCode(sourceLang);
      final target = _normalizeLanguageCode(targetLang);

      _logger.i('Translating: "$text" from $source to $target');

      // TODO: 生产环境应使用真实的API请求和签名
      // 当前使用Mock实现来演示流程
      final result = await _translateMock(text, source, target);

      _logger.i('Translation result: "$result"');
      return result;
    } catch (e, stackTrace) {
      final errorMessage =
          app_error_handler.ErrorHandler().handleException(e, stackTrace);
      _logger.e('Translation failed: $errorMessage');
      rethrow;
    }
  }

  /// Mock 翻译实现（生产环境需替换为真实API调用）
  Future<String> _translateMock(
      String text, String source, String target) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 示例翻译数据库
    const mockData = {
      'hello': {
        'en-zh': '你好',
        'en-ug': 'سلام',
        'zh-en': 'Hello',
        'zh-ug': 'سلام',
        'ug-en': 'Hello',
        'ug-zh': '你好',
      },
      'good morning': {
        'en-zh': '早上好',
        'en-ug': 'خەيسەتسىز',
        'zh-en': 'Good morning',
        'ug-en': 'Good morning',
      },
      'thank you': {
        'en-zh': '谢谢',
        'en-ug': 'رەھمەت',
        'zh-en': 'Thank you',
        'ug-en': 'Thank you',
      },
      'how are you': {
        'en-zh': '你好吗',
        'en-ug': 'سىز قانداق؟',
        'zh-en': 'How are you?',
        'ug-en': 'How are you?',
      },
      'i love flutter': {
        'en-zh': '我喜欢Flutter',
        'en-ug': 'مەن Flutterنى يېقتۈرمەن',
        'zh-en': 'I love Flutter',
        'ug-en': 'I love Flutter',
      },
    };

    final key = text.toLowerCase().trim();
    final langPair = '$source-$target';

    if (mockData.containsKey(key) && mockData[key]!.containsKey(langPair)) {
      return mockData[key]![langPair]!;
    }

    // 如果没有找到精确匹配，返回原文（标记为未翻译）
    return '[${text.trim()}]';
  }

  /// 标准化语言代码
  /// 支持: zh, en, ug, auto
  String _normalizeLanguageCode(String code) {
    final normalized = code.toLowerCase().trim();

    const supportedLanguages = {
      'zh': 'zh', // 中文
      'en': 'en', // 英文
      'ug': 'ug', // 维吾尔语
      'auto': 'auto', // 自动检测
      'chinese': 'zh',
      'english': 'en',
      'uyghur': 'ug',
    };

    return supportedLanguages[normalized] ?? 'auto';
  }

  /// 构建腾讯云API签名（TC3-HMAC-SHA256）
  /// 保留以供未来使用，实际环境中需要根据官方文档实现
  // String _buildSignature(
  //   String secretKey,
  //   String payload,
  //   String timestamp,
  // ) {
  //   // 生成签名逻辑
  //   // 这里简化处理，生产环境需要按照腾讯云官方文档实现
  //   final bytes = utf8.encode(payload);
  //   return sha256.convert(bytes).toString();
  // }

  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return ['zh', 'en', 'ug', 'auto'];
  }

  /// 获取支持的语言对
  List<Map<String, String>> getSupportedLanguagePairs() {
    return [
      {'source': 'auto', 'target': 'zh', 'name': '自动→中文'},
      {'source': 'auto', 'target': 'en', 'name': '自动→英文'},
      {'source': 'auto', 'target': 'ug', 'name': '自动→维吾尔语'},
      {'source': 'zh', 'target': 'en', 'name': '中文→英文'},
      {'source': 'zh', 'target': 'ug', 'name': '中文→维吾尔语'},
      {'source': 'en', 'target': 'zh', 'name': '英文→中文'},
      {'source': 'en', 'target': 'ug', 'name': '英文→维吾尔语'},
      {'source': 'ug', 'target': 'zh', 'name': '维吾尔语→中文'},
      {'source': 'ug', 'target': 'en', 'name': '维吾尔语→英文'},
    ];
  }
}

/// 翻译异常
class TranslationException implements Exception {
  final String message;
  TranslationException(this.message);

  @override
  String toString() => 'TranslationException: $message';
}
