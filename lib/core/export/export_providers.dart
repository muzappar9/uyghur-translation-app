import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'export_service.dart';

/// 导出服务Provider
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// 导出状态
class ExportState {
  final bool isExporting;
  final ExportResult? lastResult;
  final String? errorMessage;

  const ExportState({
    this.isExporting = false,
    this.lastResult,
    this.errorMessage,
  });

  ExportState copyWith({
    bool? isExporting,
    ExportResult? lastResult,
    String? errorMessage,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      lastResult: lastResult ?? this.lastResult,
      errorMessage: errorMessage,
    );
  }
}

/// 导出管理器
class ExportManager extends Notifier<ExportState> {
  @override
  ExportState build() => const ExportState();

  ExportService get _exportService => ref.read(exportServiceProvider);

  /// 导出翻译历史
  Future<ExportResult> exportTranslations({
    required List<TranslationExportData> data,
    required ExportFormat format,
    String fileName = 'translations',
    bool share = false,
  }) async {
    state = state.copyWith(isExporting: true, errorMessage: null);

    try {
      final options = ExportOptions(
        format: format,
        fileName: fileName,
        includeMetadata: true,
        includeTimestamp: true,
      );

      final result = share
          ? await _exportService.exportAndShare(
              data: data,
              options: options,
              shareText: 'My translation history (${data.length} items)',
            )
          : await _exportService.export(
              data: data,
              options: options,
            );

      state = state.copyWith(
        isExporting: false,
        lastResult: result,
        errorMessage: result.success ? null : result.errorMessage,
      );

      return result;
    } catch (e) {
      final result = ExportResult.failure('Export failed: $e');
      state = state.copyWith(
        isExporting: false,
        lastResult: result,
        errorMessage: e.toString(),
      );
      return result;
    }
  }

  /// 导出词典数据
  Future<ExportResult> exportDictionary({
    required List<DictionaryExportData> data,
    required ExportFormat format,
    String fileName = 'dictionary',
    bool share = false,
  }) async {
    state = state.copyWith(isExporting: true, errorMessage: null);

    try {
      final options = ExportOptions(
        format: format,
        fileName: fileName,
        includeMetadata: true,
        includeTimestamp: true,
      );

      final result = share
          ? await _exportService.exportAndShare(
              data: data,
              options: options,
              shareText: 'My vocabulary list (${data.length} words)',
            )
          : await _exportService.export(
              data: data,
              options: options,
            );

      state = state.copyWith(
        isExporting: false,
        lastResult: result,
        errorMessage: result.success ? null : result.errorMessage,
      );

      return result;
    } catch (e) {
      final result = ExportResult.failure('Export failed: $e');
      state = state.copyWith(
        isExporting: false,
        lastResult: result,
        errorMessage: e.toString(),
      );
      return result;
    }
  }

  /// 重置状态
  void reset() {
    state = const ExportState();
  }
}

/// 导出管理器Provider
final exportManagerProvider = NotifierProvider<ExportManager, ExportState>(
  ExportManager.new,
);

/// 是否正在导出
final isExportingProvider = Provider<bool>((ref) {
  return ref.watch(exportManagerProvider).isExporting;
});

/// 最后导出结果
final lastExportResultProvider = Provider<ExportResult?>((ref) {
  return ref.watch(exportManagerProvider).lastResult;
});
