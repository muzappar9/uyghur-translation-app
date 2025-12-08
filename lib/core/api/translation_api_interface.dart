/// 翻译API接口 - Stage 13: 抽象API层
///
/// 这个抽象接口允许在不同翻译提供商之间切换：
/// - 第三方API（Google、DeepL、OpenAI等）
/// - 自托管模型（本地服务器）
/// - 离线模式
///
/// 使用方法：
/// 1. 实现此接口创建新的翻译提供商
/// 2. 通过配置文件或环境变量选择提供商
/// 3. 注册到依赖注入容器
library;

/// 翻译API响应
class TranslationApiResponse {
  final bool success;
  final String? translatedText;
  final String? errorMessage;
  final String? errorCode;
  final Map<String, dynamic>? metadata;
  final Duration? responseTime;

  const TranslationApiResponse({
    required this.success,
    this.translatedText,
    this.errorMessage,
    this.errorCode,
    this.metadata,
    this.responseTime,
  });

  factory TranslationApiResponse.success({
    required String translatedText,
    Map<String, dynamic>? metadata,
    Duration? responseTime,
  }) {
    return TranslationApiResponse(
      success: true,
      translatedText: translatedText,
      metadata: metadata,
      responseTime: responseTime,
    );
  }

  factory TranslationApiResponse.failure({
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    return TranslationApiResponse(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      metadata: metadata,
    );
  }
}

/// 批量翻译API响应
class BatchTranslationApiResponse {
  final bool success;
  final List<TranslationApiResponse> results;
  final String? errorMessage;
  final Duration? totalResponseTime;

  const BatchTranslationApiResponse({
    required this.success,
    required this.results,
    this.errorMessage,
    this.totalResponseTime,
  });
}

/// 支持的语言信息
class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;
  final bool isSourceSupported;
  final bool isTargetSupported;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isSourceSupported = true,
    this.isTargetSupported = true,
  });
}

/// API提供商信息
class TranslationApiInfo {
  final String providerId;
  final String providerName;
  final String version;
  final bool supportsOffline;
  final bool supportsBatch;
  final bool supportsDetectLanguage;
  final int? maxTextLength;
  final int? maxBatchSize;
  final List<SupportedLanguage> supportedLanguages;

  const TranslationApiInfo({
    required this.providerId,
    required this.providerName,
    required this.version,
    this.supportsOffline = false,
    this.supportsBatch = true,
    this.supportsDetectLanguage = true,
    this.maxTextLength,
    this.maxBatchSize,
    this.supportedLanguages = const [],
  });
}

/// 翻译API抽象接口
///
/// 所有翻译提供商必须实现此接口
abstract class TranslationApiInterface {
  /// 获取API提供商信息
  TranslationApiInfo get apiInfo;

  /// 检查API是否可用
  Future<bool> isAvailable();

  /// 翻译单个文本
  Future<TranslationApiResponse> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// 批量翻译多个文本
  Future<BatchTranslationApiResponse> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// 检测文本语言
  Future<String?> detectLanguage(String text);

  /// 获取支持的语言列表
  Future<List<SupportedLanguage>> getSupportedLanguages();

  /// 验证API配置
  Future<bool> validateConfiguration();

  /// 释放资源
  Future<void> dispose();
}

/// 翻译API配置
class TranslationApiConfig {
  final String providerId;
  final String? apiKey;
  final String? apiEndpoint;
  final String? model;
  final Duration timeout;
  final int maxRetries;
  final Map<String, dynamic> customConfig;

  const TranslationApiConfig({
    required this.providerId,
    this.apiKey,
    this.apiEndpoint,
    this.model,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.customConfig = const {},
  });

  /// 从环境变量创建配置
  factory TranslationApiConfig.fromEnvironment({
    required String providerId,
    Map<String, String>? env,
  }) {
    final environment = env ?? const {};

    return TranslationApiConfig(
      providerId: providerId,
      apiKey: environment['${providerId.toUpperCase()}_API_KEY'],
      apiEndpoint: environment['${providerId.toUpperCase()}_API_ENDPOINT'],
      timeout: Duration(
        seconds: int.tryParse(
              environment['${providerId.toUpperCase()}_TIMEOUT'] ?? '30',
            ) ??
            30,
      ),
      maxRetries: int.tryParse(
            environment['${providerId.toUpperCase()}_MAX_RETRIES'] ?? '3',
          ) ??
          3,
    );
  }

  /// 从Map创建配置
  factory TranslationApiConfig.fromMap(Map<String, dynamic> map) {
    return TranslationApiConfig(
      providerId: map['providerId'] as String,
      apiKey: map['apiKey'] as String?,
      apiEndpoint: map['apiEndpoint'] as String?,
      model: map['model'] as String?,
      timeout: Duration(seconds: map['timeout'] as int? ?? 30),
      maxRetries: map['maxRetries'] as int? ?? 3,
      customConfig: map['customConfig'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'apiKey': apiKey,
      'apiEndpoint': apiEndpoint,
      'model': model,
      'timeout': timeout.inSeconds,
      'maxRetries': maxRetries,
      'customConfig': customConfig,
    };
  }
}
