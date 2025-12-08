/// 数据导出模块
///
/// 支持格式:
/// - CSV
/// - JSON
/// - TXT
/// - Markdown
///
/// 使用示例:
/// ```dart
/// final exportManager = ref.read(exportManagerProvider.notifier);
///
/// final result = await exportManager.exportTranslations(
///   data: translations,
///   format: ExportFormat.csv,
///   share: true,
/// );
/// ```

library export;

export 'export_service.dart';
export 'export_providers.dart';
