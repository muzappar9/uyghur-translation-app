import 'env_config.dart';

/// API 密钥管理类
/// 提供安全的密钥访问和验证
class ApiKeys {
  // 私有构造函数
  ApiKeys._();

  // === Google APIs ===
  static const String _googleTranslateApiName = 'GoogleTranslate';
  static const String _googleVisionApiName = 'GoogleVision';

  static String getGoogleTranslateApiKey() {
    final key = EnvConfig.googleTranslateApiKey;
    if (key.isEmpty) {
      throw MissingApiKeyException(_googleTranslateApiName);
    }
    return key;
  }

  static String getGoogleVisionApiKey() {
    final key = EnvConfig.googleVisionApiKey;
    if (key.isEmpty) {
      throw MissingApiKeyException(_googleVisionApiName);
    }
    return key;
  }

  // === DeepSeek API ===
  static const String _deepSeekApiName = 'DeepSeek';

  static String getDeepSeekApiKey() {
    final key = EnvConfig.deepSeekApiKey;
    if (key.isEmpty) {
      throw MissingApiKeyException(_deepSeekApiName);
    }
    return key;
  }

  static String getDeepSeekApiEndpoint() => EnvConfig.deepSeekApiEndpoint;

  static String getDeepSeekModel() => EnvConfig.deepSeekModel;

  /// 检查 DeepSeek API 是否可用
  static bool hasDeepSeekApiKey() => EnvConfig.deepSeekApiKey.isNotEmpty;

  // === Firebase ===
  static const String _firebaseApiName = 'Firebase';

  static Map<String, String> getFirebaseConfig() {
    final config = {
      'projectId': EnvConfig.firebaseProjectId,
      'apiKey': EnvConfig.firebaseApiKey,
      'authDomain': EnvConfig.firebaseAuthDomain,
      'databaseUrl': EnvConfig.firebaseDatabaseUrl,
      'storageBucket': EnvConfig.firebaseStorageBucket,
      'messagingSenderId': EnvConfig.firebaseMessagingSenderId,
      'appId': EnvConfig.firebaseAppId,
    };

    // 检查关键配置项
    if (config['projectId']!.isEmpty || config['apiKey']!.isEmpty) {
      throw MissingApiKeyException(_firebaseApiName);
    }

    return config;
  }

  // === API 端点 ===
  static String getTranslationApiUrl() => EnvConfig.translationApiUrl;

  static String getVisionApiUrl() => EnvConfig.visionApiUrl;

  // === 快速访问 ===
  static bool hasAllRequiredKeys() {
    try {
      getGoogleTranslateApiKey();
      getGoogleVisionApiKey();
      // Firebase 在开发环境可选
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取 API 密钥（带默认值）
  /// 用于 Mock/开发环境
  static String getKeyOrDefault(String keyName, String defaultValue) {
    switch (keyName) {
      case 'google_translate':
        return EnvConfig.googleTranslateApiKey.isEmpty
            ? defaultValue
            : EnvConfig.googleTranslateApiKey;
      case 'google_vision':
        return EnvConfig.googleVisionApiKey.isEmpty
            ? defaultValue
            : EnvConfig.googleVisionApiKey;
      default:
        return defaultValue;
    }
  }
}

/// 缺失 API 密钥异常
class MissingApiKeyException implements Exception {
  final String apiName;

  MissingApiKeyException(this.apiName);

  @override
  String toString() => '❌ Missing API key for: $apiName. '
      'Please check your .env file.';
}
