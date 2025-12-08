/// 数据导入服务
///
/// 提供数据导入功能的核心服务
library;

import 'dart:async';
import 'import_formats.dart';

/// 导入类型
enum ImportType {
  /// 翻译历史
  translations,

  /// 词典
  dictionary,

  /// 收藏
  favorites,

  /// 设置
  settings,
}

/// 导入进度回调
typedef ImportProgressCallback = void Function(
    int current, int total, String message);

/// 导入服务
class ImportService {
  /// 从文件内容导入翻译记录
  Future<ImportResult> importTranslations(
    String content,
    ImportFormat format, {
    ImportOptions options = const ImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    final errors = <String>[];
    final warnings = <String>[];
    var importedCount = 0;
    var skippedCount = 0;

    try {
      // 解析内容
      final entries = _parseContent(content, format);
      final totalCount = entries.length;

      if (entries.isEmpty) {
        return ImportResult(
          success: false,
          totalCount: 0,
          importedCount: 0,
          errors: ['未找到可导入的数据'],
          duration: stopwatch.elapsed,
        );
      }

      // 验证数据
      if (options.validateData) {
        final validEntries = <ImportedEntry>[];
        for (var i = 0; i < entries.length; i++) {
          final entry = entries[i];
          final validation = _validateEntry(entry);

          if (validation.isValid) {
            validEntries.add(entry);
          } else {
            warnings.add('第 ${i + 1} 行: ${validation.message}');
            skippedCount++;
          }
        }
        entries
          ..clear()
          ..addAll(validEntries);
      }

      // 应用默认值
      final processedEntries = entries
          .map((e) => ImportedEntry(
                sourceText: e.sourceText,
                targetText: e.targetText,
                sourceLang: e.sourceLang ?? options.defaultSourceLang,
                targetLang: e.targetLang ?? options.defaultTargetLang,
                timestamp: options.preserveTimestamps ? e.timestamp : null,
                isFavorite: e.isFavorite,
                notes: e.notes,
                metadata: e.metadata,
              ))
          .toList();

      // 批量导入
      final batches = _createBatches(processedEntries, options.batchSize);

      for (var batchIndex = 0; batchIndex < batches.length; batchIndex++) {
        final batch = batches[batchIndex];

        onProgress?.call(
          batchIndex * options.batchSize + batch.length,
          totalCount,
          '正在导入第 ${batchIndex + 1}/${batches.length} 批...',
        );

        // 模拟导入到数据库
        // TODO: 实际的数据库导入逻辑
        await Future.delayed(const Duration(milliseconds: 10));

        importedCount += batch.length;
      }

      stopwatch.stop();

      return ImportResult(
        success: true,
        totalCount: totalCount,
        importedCount: importedCount,
        skippedCount: skippedCount,
        errorCount: errors.length,
        errors: errors,
        warnings: warnings,
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return ImportResult(
        success: false,
        totalCount: 0,
        importedCount: importedCount,
        errorCount: 1,
        errors: ['导入失败: $e'],
        duration: stopwatch.elapsed,
      );
    }
  }

  /// 从文件内容导入词典
  Future<ImportResult> importDictionary(
    String content,
    ImportFormat format, {
    ImportOptions options = const ImportOptions(),
    ImportProgressCallback? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    final errors = <String>[];
    final warnings = <String>[];
    var importedCount = 0;
    var skippedCount = 0;

    try {
      // 解析内容
      List<ImportedDictionaryEntry> entries;

      switch (format) {
        case ImportFormat.json:
          entries = JsonImportParser.parseDictionary(content);
          break;
        default:
          return ImportResult.error('不支持的词典导入格式: ${format.displayName}');
      }

      if (entries.isEmpty) {
        return ImportResult(
          success: false,
          totalCount: 0,
          importedCount: 0,
          errors: ['未找到可导入的词典数据'],
          duration: stopwatch.elapsed,
        );
      }

      final totalCount = entries.length;

      // 验证数据
      if (options.validateData) {
        final validEntries = <ImportedDictionaryEntry>[];
        for (var i = 0; i < entries.length; i++) {
          final entry = entries[i];
          if (entry.word.isNotEmpty && entry.definition.isNotEmpty) {
            validEntries.add(entry);
          } else {
            warnings.add('第 ${i + 1} 行: 词条或定义为空');
            skippedCount++;
          }
        }
        entries
          ..clear()
          ..addAll(validEntries);
      }

      // 批量导入
      final batches = _createBatches(entries, options.batchSize);

      for (var batchIndex = 0; batchIndex < batches.length; batchIndex++) {
        final batch = batches[batchIndex];

        onProgress?.call(
          batchIndex * options.batchSize + batch.length,
          totalCount,
          '正在导入第 ${batchIndex + 1}/${batches.length} 批...',
        );

        // 模拟导入到数据库
        // TODO: 实际的数据库导入逻辑
        await Future.delayed(const Duration(milliseconds: 10));

        importedCount += batch.length;
      }

      stopwatch.stop();

      return ImportResult(
        success: true,
        totalCount: totalCount,
        importedCount: importedCount,
        skippedCount: skippedCount,
        errorCount: errors.length,
        errors: errors,
        warnings: warnings,
        duration: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return ImportResult(
        success: false,
        totalCount: 0,
        importedCount: importedCount,
        errorCount: 1,
        errors: ['导入失败: $e'],
        duration: stopwatch.elapsed,
      );
    }
  }

  /// 检测文件格式
  ImportFormat? detectFormat(String filename, String? content) {
    // 首先尝试从扩展名检测
    final ext = filename.split('.').last.toLowerCase();
    final formatFromExt = ImportFormat.fromExtension('.$ext');

    if (formatFromExt != null) {
      return formatFromExt;
    }

    // 尝试从内容检测
    if (content != null) {
      final trimmed = content.trim();

      // JSON
      if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
        return ImportFormat.json;
      }

      // TMX
      if (trimmed.contains('<tmx') || trimmed.contains('<tu>')) {
        return ImportFormat.tmx;
      }

      // CSV（检查是否有逗号分隔）
      final lines = trimmed.split('\n');
      if (lines.isNotEmpty && lines[0].contains(',')) {
        return ImportFormat.csv;
      }

      // 默认文本
      return ImportFormat.text;
    }

    return null;
  }

  /// 预览导入内容
  Future<ImportPreview> previewImport(
    String content,
    ImportFormat format, {
    int maxPreviewCount = 10,
  }) async {
    try {
      final entries = _parseContent(content, format);

      return ImportPreview(
        totalCount: entries.length,
        previewEntries: entries.take(maxPreviewCount).toList(),
        format: format,
        detectedSourceLangs: _detectLanguages(entries, true),
        detectedTargetLangs: _detectLanguages(entries, false),
      );
    } catch (e) {
      return ImportPreview(
        totalCount: 0,
        previewEntries: [],
        format: format,
        error: '解析失败: $e',
      );
    }
  }

  List<ImportedEntry> _parseContent(String content, ImportFormat format) {
    switch (format) {
      case ImportFormat.json:
        return JsonImportParser.parseTranslations(content);
      case ImportFormat.csv:
        return CsvImportParser.parseTranslations(content);
      case ImportFormat.text:
        return TextImportParser.parseTranslations(content);
      case ImportFormat.tmx:
        return TmxImportParser.parseTranslations(content);
    }
  }

  _ValidationResult _validateEntry(ImportedEntry entry) {
    if (entry.sourceText.isEmpty) {
      return const _ValidationResult(false, '源文本为空');
    }
    if (entry.targetText.isEmpty) {
      return const _ValidationResult(false, '目标文本为空');
    }
    if (entry.sourceText.length > 10000) {
      return const _ValidationResult(false, '源文本过长');
    }
    if (entry.targetText.length > 10000) {
      return const _ValidationResult(false, '目标文本过长');
    }
    return const _ValidationResult(true, '');
  }

  List<List<T>> _createBatches<T>(List<T> items, int batchSize) {
    final batches = <List<T>>[];
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      batches.add(items.sublist(i, end));
    }
    return batches;
  }

  Set<String> _detectLanguages(List<ImportedEntry> entries, bool source) {
    final langs = <String>{};
    for (final entry in entries) {
      final lang = source ? entry.sourceLang : entry.targetLang;
      if (lang != null && lang.isNotEmpty) {
        langs.add(lang);
      }
    }
    return langs;
  }
}

class _ValidationResult {
  final bool isValid;
  final String message;

  const _ValidationResult(this.isValid, this.message);
}

/// 导入预览
class ImportPreview {
  final int totalCount;
  final List<ImportedEntry> previewEntries;
  final ImportFormat format;
  final Set<String> detectedSourceLangs;
  final Set<String> detectedTargetLangs;
  final String? error;

  const ImportPreview({
    required this.totalCount,
    required this.previewEntries,
    required this.format,
    this.detectedSourceLangs = const {},
    this.detectedTargetLangs = const {},
    this.error,
  });

  bool get hasError => error != null;
  bool get isEmpty => totalCount == 0;
}
