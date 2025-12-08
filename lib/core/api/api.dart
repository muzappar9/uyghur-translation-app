/// 翻译API核心模块
///
/// 提供可切换的翻译API架构：
/// - Mock API (开发测试)
/// - Self-Hosted API (自托管模型)
/// - 更多提供商 (待实现)
///
/// 使用示例:
/// ```dart
/// // 切换API提供商
/// final manager = ref.read(translationApiManagerProvider.notifier);
/// await manager.switchProvider(TranslationApiProvider.mock);
///
/// // 执行翻译
/// final result = await manager.translate(
///   text: 'Hello',
///   sourceLanguage: 'en',
///   targetLanguage: 'ug',
/// );
/// ```

library translation_api;

// 核心接口
export 'translation_api_interface.dart';

// 工厂和Provider
export 'translation_api_factory.dart';

// API提供商实现
export 'providers/mock_translation_api.dart';
export 'providers/self_hosted_translation_api.dart';
