import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../translation_api_interface.dart';

/// 自托管模型翻译API实现
///
/// 适用于：
/// - 本地部署的LLM模型
/// - 私有云部署的翻译服务
/// - 自研翻译引擎
///
/// 配置选项：
/// - apiEndpoint: API服务地址
/// - apiKey: 认证密钥（可选）
/// - modelId: 使用的模型ID
/// - customHeaders: 自定义HTTP头
class SelfHostedTranslationApi implements TranslationApiInterface {
  final Dio _dio;
  final Logger _logger = Logger();
  final SelfHostedApiConfig _config;
  bool _isInitialized = false;

  SelfHostedTranslationApi({
    required SelfHostedApiConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _config.apiEndpoint ?? '',
      connectTimeout: _config.timeout,
      receiveTimeout: _config.timeout,
      headers: {
        'Content-Type': 'application/json',
        if (_config.apiKey != null) 'Authorization': 'Bearer ${_config.apiKey}',
        ..._config.customHeaders,
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('🌐 Self-hosted API Request: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('✅ Self-hosted API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ Self-hosted API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  @override
  TranslationApiInfo get apiInfo => TranslationApiInfo(
        providerId: 'self_hosted',
        providerName: _config.providerName ?? 'Self-Hosted Translation API',
        version: _config.version ?? '1.0.0',
        supportsOffline: false,
        supportsBatch: _config.supportsBatch,
        supportsDetectLanguage: _config.supportsDetectLanguage,
        maxTextLength: _config.maxTextLength,
        maxBatchSize: _config.maxBatchSize,
        supportedLanguages: _config.supportedLanguages,
      );

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _dio.get(
        _config.healthCheckEndpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      _isInitialized = response.statusCode == 200;
      return _isInitialized;
    } catch (e) {
      _logger.w('Self-hosted API not available: $e');
      return false;
    }
  }

  @override
  Future<TranslationApiResponse> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 验证输入
      if (text.isEmpty) {
        return TranslationApiResponse.failure(
          errorMessage: '翻译文本不能为空',
          errorCode: 'EMPTY_TEXT',
        );
      }

      // 构建请求体（支持自定义格式）
      final requestBody =
          _buildRequestBody(text, sourceLanguage, targetLanguage);

      // 发送翻译请求
      final response = await _dio.post(
        _config.translateEndpoint,
        data: requestBody,
      );

      // 解析响应（支持自定义解析器）
      final translatedText = _parseTranslationResponse(response.data);

      stopwatch.stop();

      return TranslationApiResponse.success(
        translatedText: translatedText,
        responseTime: stopwatch.elapsed,
        metadata: {
          'provider': 'self_hosted',
          'modelId': _config.modelId,
          'endpoint': _config.apiEndpoint,
        },
      );
    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioError(e);
    } catch (e) {
      stopwatch.stop();
      return TranslationApiResponse.failure(
        errorMessage: '翻译请求失败: $e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<BatchTranslationApiResponse> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (_config.supportsBatch) {
      // 使用批量API
      try {
        final requestBody = {
          'texts': texts,
          'source_language': sourceLanguage,
          'target_language': targetLanguage,
          if (_config.modelId != null) 'model': _config.modelId,
          ..._config.additionalParams,
        };

        final response = await _dio.post(
          _config.batchTranslateEndpoint ?? _config.translateEndpoint,
          data: requestBody,
        );

        final results = _parseBatchResponse(response.data, texts.length);
        stopwatch.stop();

        return BatchTranslationApiResponse(
          success: results.every((r) => r.success),
          results: results,
          totalResponseTime: stopwatch.elapsed,
        );
      } catch (e) {
        stopwatch.stop();
        return BatchTranslationApiResponse(
          success: false,
          results: [],
          errorMessage: '批量翻译失败: $e',
        );
      }
    } else {
      // 逐个翻译
      final results = <TranslationApiResponse>[];
      for (final text in texts) {
        final result = await translate(
          text: text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
        results.add(result);
      }

      stopwatch.stop();
      return BatchTranslationApiResponse(
        success: results.every((r) => r.success),
        results: results,
        totalResponseTime: stopwatch.elapsed,
      );
    }
  }

  @override
  Future<String?> detectLanguage(String text) async {
    if (!_config.supportsDetectLanguage) {
      return null;
    }

    try {
      final response = await _dio.post(
        _config.detectLanguageEndpoint ?? '/detect',
        data: {'text': text},
      );

      return response.data['language'] as String?;
    } catch (e) {
      _logger.w('Language detection failed: $e');
      return null;
    }
  }

  @override
  Future<List<SupportedLanguage>> getSupportedLanguages() async {
    if (_config.supportedLanguages.isNotEmpty) {
      return _config.supportedLanguages;
    }

    try {
      final response = await _dio.get('/languages');
      final languages = (response.data['languages'] as List)
          .map((l) => SupportedLanguage(
                code: l['code'] as String,
                name: l['name'] as String,
                nativeName: l['native_name'] as String? ?? l['name'] as String,
              ))
          .toList();
      return languages;
    } catch (e) {
      _logger.w('Failed to get supported languages: $e');
      return [];
    }
  }

  @override
  Future<bool> validateConfiguration() async {
    // 检查必要配置
    if (_config.apiEndpoint == null || _config.apiEndpoint!.isEmpty) {
      _logger.e('API endpoint is required');
      return false;
    }

    // 测试连接
    return await isAvailable();
  }

  @override
  Future<void> dispose() async {
    _dio.close();
    _isInitialized = false;
  }

  /// 构建请求体
  Map<String, dynamic> _buildRequestBody(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) {
    if (_config.requestFormatter != null) {
      return _config.requestFormatter!(text, sourceLanguage, targetLanguage);
    }

    return {
      'text': text,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      if (_config.modelId != null) 'model': _config.modelId,
      ..._config.additionalParams,
    };
  }

  /// 解析翻译响应
  String _parseTranslationResponse(dynamic responseData) {
    if (_config.responseParser != null) {
      return _config.responseParser!(responseData);
    }

    // 默认解析逻辑
    if (responseData is Map) {
      return responseData['translation'] as String? ??
          responseData['translated_text'] as String? ??
          responseData['result'] as String? ??
          responseData['text'] as String? ??
          '';
    }

    return responseData.toString();
  }

  /// 解析批量响应
  List<TranslationApiResponse> _parseBatchResponse(
    dynamic responseData,
    int expectedCount,
  ) {
    if (responseData is Map && responseData.containsKey('translations')) {
      final translations = responseData['translations'] as List;
      return translations.map((t) {
        if (t is String) {
          return TranslationApiResponse.success(translatedText: t);
        } else if (t is Map) {
          return TranslationApiResponse.success(
            translatedText: t['text'] as String? ?? '',
          );
        }
        return TranslationApiResponse.failure(errorMessage: '无效响应格式');
      }).toList();
    }

    return [];
  }

  /// 处理Dio错误
  TranslationApiResponse _handleDioError(DioException error) {
    String errorMessage;
    String errorCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = '连接超时';
        errorCode = 'CONNECTION_TIMEOUT';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = '发送超时';
        errorCode = 'SEND_TIMEOUT';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = '接收超时';
        errorCode = 'RECEIVE_TIMEOUT';
        break;
      case DioExceptionType.badResponse:
        errorMessage = 'API响应错误: ${error.response?.statusCode}';
        errorCode = 'BAD_RESPONSE';
        break;
      case DioExceptionType.connectionError:
        errorMessage = '网络连接失败';
        errorCode = 'CONNECTION_ERROR';
        break;
      default:
        errorMessage = error.message ?? '未知错误';
        errorCode = 'UNKNOWN_ERROR';
    }

    return TranslationApiResponse.failure(
      errorMessage: errorMessage,
      errorCode: errorCode,
      metadata: {
        'dioErrorType': error.type.name,
        'statusCode': error.response?.statusCode,
      },
    );
  }
}

/// 自托管API配置
class SelfHostedApiConfig extends TranslationApiConfig {
  final String? providerName;
  final String? version;
  final String? modelId;
  final String translateEndpoint;
  final String? batchTranslateEndpoint;
  final String? detectLanguageEndpoint;
  final String healthCheckEndpoint;
  final bool supportsBatch;
  final bool supportsDetectLanguage;
  final int? maxTextLength;
  final int? maxBatchSize;
  final List<SupportedLanguage> supportedLanguages;
  final Map<String, String> customHeaders;
  final Map<String, dynamic> additionalParams;

  /// 自定义请求格式化器
  final Map<String, dynamic> Function(
    String text,
    String sourceLanguage,
    String targetLanguage,
  )? requestFormatter;

  /// 自定义响应解析器
  final String Function(dynamic responseData)? responseParser;

  const SelfHostedApiConfig({
    required String super.apiEndpoint,
    super.apiKey,
    super.timeout,
    super.maxRetries,
    this.providerName,
    this.version,
    this.modelId,
    this.translateEndpoint = '/translate',
    this.batchTranslateEndpoint,
    this.detectLanguageEndpoint,
    this.healthCheckEndpoint = '/health',
    this.supportsBatch = false,
    this.supportsDetectLanguage = false,
    this.maxTextLength,
    this.maxBatchSize,
    this.supportedLanguages = const [],
    this.customHeaders = const {},
    this.additionalParams = const {},
    this.requestFormatter,
    this.responseParser,
  }) : super(
          providerId: 'self_hosted',
        );

  /// 创建用于LLM模型的配置
  factory SelfHostedApiConfig.forLLM({
    required String apiEndpoint,
    required String modelId,
    String? apiKey,
    Duration timeout = const Duration(seconds: 60),
    List<SupportedLanguage> supportedLanguages = const [],
  }) {
    return SelfHostedApiConfig(
      apiEndpoint: apiEndpoint,
      apiKey: apiKey,
      modelId: modelId,
      timeout: timeout,
      supportedLanguages: supportedLanguages,
      translateEndpoint: '/v1/chat/completions',
      healthCheckEndpoint: '/health',
      requestFormatter: (text, source, target) => {
        'model': modelId,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a professional translator. Translate the following text from $source to $target. Only return the translation, no explanations.',
          },
          {
            'role': 'user',
            'content': text,
          },
        ],
        'temperature': 0.3,
        'max_tokens': 2048,
      },
      responseParser: (data) {
        if (data is Map && data.containsKey('choices')) {
          final choices = data['choices'] as List;
          if (choices.isNotEmpty) {
            final choice = choices.first as Map;
            final message = choice['message'] as Map?;
            return message?['content'] as String? ?? '';
          }
        }
        return '';
      },
    );
  }

  /// 创建用于OpenAI兼容API的配置
  ///
  /// 支持 OpenAI、DeepSeek、科大讯飞等兼容 OpenAI 格式的 API
  factory SelfHostedApiConfig.openAICompatible({
    required String apiEndpoint,
    required String apiKey,
    String model = 'gpt-3.5-turbo',
  }) {
    return SelfHostedApiConfig.forLLM(
      apiEndpoint: apiEndpoint,
      apiKey: apiKey,
      modelId: model,
      supportedLanguages: const [
        SupportedLanguage(code: 'en', name: 'English', nativeName: 'English'),
        SupportedLanguage(code: 'zh', name: 'Chinese', nativeName: '中文'),
        SupportedLanguage(code: 'ug', name: 'Uyghur', nativeName: 'ئۇيغۇرچە'),
      ],
    );
  }
}
