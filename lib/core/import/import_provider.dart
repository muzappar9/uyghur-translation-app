/// 数据导入 Provider
///
/// 管理数据导入状态
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'import_service.dart';
import 'import_formats.dart';

/// 导入服务 Provider
final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});

/// 导入状态
enum ImportStatus {
  /// 空闲
  idle,

  /// 选择文件中
  selectingFile,

  /// 预览中
  previewing,

  /// 导入中
  importing,

  /// 完成
  completed,

  /// 错误
  error,
}

/// 导入状态数据
class ImportState {
  final ImportStatus status;
  final String? filename;
  final String? content;
  final ImportFormat? format;
  final ImportPreview? preview;
  final ImportOptions options;
  final int progress;
  final int total;
  final String? progressMessage;
  final ImportResult? result;
  final String? error;

  const ImportState({
    this.status = ImportStatus.idle,
    this.filename,
    this.content,
    this.format,
    this.preview,
    this.options = const ImportOptions(),
    this.progress = 0,
    this.total = 0,
    this.progressMessage,
    this.result,
    this.error,
  });

  ImportState copyWith({
    ImportStatus? status,
    String? filename,
    String? content,
    ImportFormat? format,
    ImportPreview? preview,
    ImportOptions? options,
    int? progress,
    int? total,
    String? progressMessage,
    ImportResult? result,
    String? error,
  }) {
    return ImportState(
      status: status ?? this.status,
      filename: filename ?? this.filename,
      content: content ?? this.content,
      format: format ?? this.format,
      preview: preview ?? this.preview,
      options: options ?? this.options,
      progress: progress ?? this.progress,
      total: total ?? this.total,
      progressMessage: progressMessage ?? this.progressMessage,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }

  double get progressPercent {
    if (total == 0) return 0;
    return progress / total;
  }

  bool get isLoading =>
      status == ImportStatus.importing || status == ImportStatus.previewing;
  bool get hasResult => result != null;
  bool get hasError => error != null;
}

/// 导入状态 Provider
final importStateProvider = NotifierProvider<ImportNotifier, ImportState>(
  ImportNotifier.new,
);

/// 导入状态管理
class ImportNotifier extends Notifier<ImportState> {
  @override
  ImportState build() {
    return const ImportState();
  }

  /// 设置文件内容
  Future<void> setFileContent(String filename, String content) async {
    final service = ref.read(importServiceProvider);

    // 检测格式
    final format = service.detectFormat(filename, content);

    if (format == null) {
      state = state.copyWith(
        status: ImportStatus.error,
        error: '无法识别文件格式',
      );
      return;
    }

    state = state.copyWith(
      status: ImportStatus.previewing,
      filename: filename,
      content: content,
      format: format,
    );

    // 生成预览
    final preview = await service.previewImport(content, format);

    if (preview.hasError) {
      state = state.copyWith(
        status: ImportStatus.error,
        error: preview.error,
      );
    } else {
      state = state.copyWith(
        status: ImportStatus.idle,
        preview: preview,
      );
    }
  }

  /// 设置导入选项
  void setOptions(ImportOptions options) {
    state = state.copyWith(options: options);
  }

  /// 开始导入
  Future<void> startImport({ImportType type = ImportType.translations}) async {
    if (state.content == null || state.format == null) {
      state = state.copyWith(
        status: ImportStatus.error,
        error: '没有可导入的文件',
      );
      return;
    }

    state = state.copyWith(
      status: ImportStatus.importing,
      progress: 0,
      total: state.preview?.totalCount ?? 0,
    );

    final service = ref.read(importServiceProvider);

    try {
      ImportResult result;

      switch (type) {
        case ImportType.translations:
        case ImportType.favorites:
          result = await service.importTranslations(
            state.content!,
            state.format!,
            options: state.options,
            onProgress: (current, total, message) {
              state = state.copyWith(
                progress: current,
                total: total,
                progressMessage: message,
              );
            },
          );
          break;
        case ImportType.dictionary:
          result = await service.importDictionary(
            state.content!,
            state.format!,
            options: state.options,
            onProgress: (current, total, message) {
              state = state.copyWith(
                progress: current,
                total: total,
                progressMessage: message,
              );
            },
          );
          break;
        case ImportType.settings:
          // TODO: 实现设置导入
          result = ImportResult.error('设置导入暂未实现');
          break;
      }

      state = state.copyWith(
        status: result.success ? ImportStatus.completed : ImportStatus.error,
        result: result,
        error: result.success ? null : result.errors.firstOrNull,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        error: '导入失败: $e',
      );
    }
  }

  /// 重置状态
  void reset() {
    state = const ImportState();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(
      status: ImportStatus.idle,
      error: null,
    );
  }
}

/// 导入进度 Provider
final importProgressProvider = Provider<double>((ref) {
  final state = ref.watch(importStateProvider);
  return state.progressPercent;
});

/// 是否正在导入 Provider
final isImportingProvider = Provider<bool>((ref) {
  final state = ref.watch(importStateProvider);
  return state.isLoading;
});
