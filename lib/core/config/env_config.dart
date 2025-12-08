import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';

/// 环境配置类
/// 管理所有应用级别的配置和常量
class EnvConfig {
  // 私有构造函数，防止实例化
  EnvConfig._();

  // === Google APIs ===
  static String get googleTranslateApiKey =>
      dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? '';

  static String get googleVisionApiKey =>
      dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';

  // === DeepSeek API 配置 ===
  static String get deepSeekApiKey => dotenv.env['DEEPSEEK_API_KEY'] ?? '';

  static String get deepSeekApiEndpoint =>
      dotenv.env['DEEPSEEK_API_ENDPOINT'] ?? 'https://api.deepseek.com';

  static String get deepSeekModel =>
      dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-chat';

  // === Firebase 配置 ===
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  static String get firebaseDatabaseUrl =>
      dotenv.env['FIREBASE_DATABASE_URL'] ?? '';

  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // === 应用配置 ===
  static String get appEnvironment =>
      dotenv.env['APP_ENVIRONMENT'] ?? 'development';

  static bool get debugMode =>
      (dotenv.env['DEBUG_MODE'] ?? 'false').toLowerCase() == 'true';

  // === API 端点 ===
  static String get translationApiUrl =>
      dotenv.env['TRANSLATION_API_URL'] ??
      'https://translation.googleapis.com/language/translate/v2';

  static String get visionApiUrl =>
      dotenv.env['VISION_API_URL'] ??
      'https://vision.googleapis.com/v1/images:annotate';

  // === 超时配置 ===
  static int get apiTimeoutMs =>
      int.tryParse(dotenv.env['API_TIMEOUT_MS'] ?? '30000') ?? 30000;

  static int get apiRetryCount =>
      int.tryParse(dotenv.env['API_RETRY_COUNT'] ?? '3') ?? 3;

  // === 便捷方法 ===
  static bool get isProduction => appEnvironment == 'production';

  static bool get isDevelopment => appEnvironment == 'development';

  static Duration get apiTimeout => Duration(milliseconds: apiTimeoutMs);

  /// 验证所有必需的环境变量是否已配置
  static bool validateConfig() {
    final requiredKeys = [
      'GOOGLE_TRANSLATE_API_KEY',
      'GOOGLE_VISION_API_KEY',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_API_KEY',
    ];

    for (final key in requiredKeys) {
      if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
        if (isDevelopment) {
          // 开发环境允许缺失某些密钥（使用 Mock）
          appLogger.w('⚠️ Warning: Missing $key in .env file');
        } else {
          // 生产环境必须所有密钥都存在
          appLogger.e('❌ Error: Missing required key $key in .env file');
          return false;
        }
      }
    }
    return true;
  }
}
