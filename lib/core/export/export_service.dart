import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 导出格式
enum ExportFormat {
  /// CSV格式
  csv,

  /// JSON格式
  json,

  /// 纯文本格式
  txt,

  /// Markdown格式
  markdown,
}

/// 导出选项
class ExportOptions {
  final ExportFormat format;
  final String fileName;
  final bool includeMetadata;
  final bool includeTimestamp;
  final String? customSeparator;
  final Encoding encoding;

  const ExportOptions({
    required this.format,
    required this.fileName,
    this.includeMetadata = true,
    this.includeTimestamp = true,
    this.customSeparator,
    this.encoding = utf8,
  });

  /// 获取文件扩展名
  String get fileExtension {
    switch (format) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.json:
        return '.json';
      case ExportFormat.txt:
        return '.txt';
      case ExportFormat.markdown:
        return '.md';
    }
  }

  /// 获取完整文件名
  String get fullFileName => '$fileName$fileExtension';
}

/// 导出结果
class ExportResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final int? exportedCount;
  final int? fileSize;

  const ExportResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    this.exportedCount,
    this.fileSize,
  });

  factory ExportResult.success({
    required String filePath,
    required int exportedCount,
    int? fileSize,
  }) {
    return ExportResult(
      success: true,
      filePath: filePath,
      exportedCount: exportedCount,
      fileSize: fileSize,
    );
  }

  factory ExportResult.failure(String errorMessage) {
    return ExportResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// 可导出数据接口
abstract class Exportable {
  Map<String, dynamic> toExportMap();
  List<String> get csvHeaders;
  List<String> get csvValues;
}

/// 翻译历史导出数据
class TranslationExportData implements Exportable {
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final bool isFavorite;

  const TranslationExportData({
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.isFavorite = false,
  });

  @override
  Map<String, dynamic> toExportMap() {
    return {
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  @override
  List<String> get csvHeaders => [
        'Source Text',
        'Translated Text',
        'Source Language',
        'Target Language',
        'Timestamp',
        'Favorite',
      ];

  @override
  List<String> get csvValues => [
        _escapeCsv(sourceText),
        _escapeCsv(translatedText),
        sourceLanguage,
        targetLanguage,
        timestamp.toIso8601String(),
        isFavorite ? 'Yes' : 'No',
      ];

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

/// 词典导出数据
class DictionaryExportData implements Exportable {
  final String word;
  final String definition;
  final String? phonetic;
  final String? partOfSpeech;
  final List<String> translations;
  final List<String> tags;

  const DictionaryExportData({
    required this.word,
    required this.definition,
    this.phonetic,
    this.partOfSpeech,
    this.translations = const [],
    this.tags = const [],
  });

  @override
  Map<String, dynamic> toExportMap() {
    return {
      'word': word,
      'definition': definition,
      'phonetic': phonetic,
      'partOfSpeech': partOfSpeech,
      'translations': translations,
      'tags': tags,
    };
  }

  @override
  List<String> get csvHeaders => [
        'Word',
        'Definition',
        'Phonetic',
        'Part of Speech',
        'Translations',
        'Tags',
      ];

  @override
  List<String> get csvValues => [
        _escapeCsv(word),
        _escapeCsv(definition),
        phonetic ?? '',
        partOfSpeech ?? '',
        _escapeCsv(translations.join('; ')),
        _escapeCsv(tags.join('; ')),
      ];

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

/// 导出服务
class ExportService {
  final Logger _logger = Logger();

  /// 导出数据
  Future<ExportResult> export<T extends Exportable>({
    required List<T> data,
    required ExportOptions options,
  }) async {
    try {
      if (data.isEmpty) {
        return ExportResult.failure('No data to export');
      }

      _logger.i('📤 Exporting ${data.length} items as ${options.format.name}');

      // 生成导出内容
      final content = _generateContent(data, options);

      // 保存文件
      final filePath = await _saveToFile(content, options);

      final fileSize = await File(filePath).length();

      _logger.i('✅ Export complete: $filePath');

      return ExportResult.success(
        filePath: filePath,
        exportedCount: data.length,
        fileSize: fileSize,
      );
    } catch (e) {
      _logger.e('❌ Export failed: $e');
      return ExportResult.failure('Export failed: $e');
    }
  }

  /// 导出并分享
  Future<ExportResult> exportAndShare<T extends Exportable>({
    required List<T> data,
    required ExportOptions options,
    String? shareText,
  }) async {
    final result = await export(data: data, options: options);

    if (result.success && result.filePath != null) {
      try {
        await Share.shareXFiles(
          [XFile(result.filePath!)],
          text: shareText ?? 'Exported ${result.exportedCount} items',
        );
      } catch (e) {
        _logger.w('Share failed: $e');
      }
    }

    return result;
  }

  /// 生成导出内容
  String _generateContent<T extends Exportable>(
    List<T> data,
    ExportOptions options,
  ) {
    switch (options.format) {
      case ExportFormat.csv:
        return _generateCsv(data, options);
      case ExportFormat.json:
        return _generateJson(data, options);
      case ExportFormat.txt:
        return _generateTxt(data, options);
      case ExportFormat.markdown:
        return _generateMarkdown(data, options);
    }
  }

  /// 生成CSV内容
  String _generateCsv<T extends Exportable>(
    List<T> data,
    ExportOptions options,
  ) {
    final buffer = StringBuffer();
    final separator = options.customSeparator ?? ',';

    // 添加元数据注释
    if (options.includeMetadata) {
      buffer.writeln('# Exported at: ${DateTime.now().toIso8601String()}');
      buffer.writeln('# Total items: ${data.length}');
      buffer.writeln();
    }

    // 添加标题行
    if (data.isNotEmpty) {
      buffer.writeln(data.first.csvHeaders.join(separator));

      // 添加数据行
      for (final item in data) {
        buffer.writeln(item.csvValues.join(separator));
      }
    }

    return buffer.toString();
  }

  /// 生成JSON内容
  String _generateJson<T extends Exportable>(
    List<T> data,
    ExportOptions options,
  ) {
    final exportData = <String, dynamic>{
      if (options.includeMetadata) ...{
        'metadata': {
          'exportedAt': DateTime.now().toIso8601String(),
          'totalItems': data.length,
          'format': 'json',
        },
      },
      'data': data.map((item) => item.toExportMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// 生成纯文本内容
  String _generateTxt<T extends Exportable>(
    List<T> data,
    ExportOptions options,
  ) {
    final buffer = StringBuffer();

    if (options.includeMetadata) {
      buffer.writeln('='.padRight(50, '='));
      buffer.writeln('Export Report');
      buffer.writeln('Date: ${DateTime.now()}');
      buffer.writeln('Items: ${data.length}');
      buffer.writeln('='.padRight(50, '='));
      buffer.writeln();
    }

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final map = item.toExportMap();

      buffer.writeln('--- Item ${i + 1} ---');
      for (final entry in map.entries) {
        buffer.writeln('${entry.key}: ${entry.value}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// 生成Markdown内容
  String _generateMarkdown<T extends Exportable>(
    List<T> data,
    ExportOptions options,
  ) {
    final buffer = StringBuffer();

    // 标题
    buffer.writeln('# Export Data');
    buffer.writeln();

    // 元数据
    if (options.includeMetadata) {
      buffer.writeln('> **Exported at**: ${DateTime.now()}');
      buffer.writeln('> **Total items**: ${data.length}');
      buffer.writeln();
    }

    // 表格
    if (data.isNotEmpty) {
      final headers = data.first.csvHeaders;

      // 表头
      buffer.writeln('| ${headers.join(' | ')} |');
      buffer.writeln('| ${headers.map((_) => '---').join(' | ')} |');

      // 数据行
      for (final item in data) {
        final values = item.csvValues.map((v) => v.replaceAll('|', '\\|'));
        buffer.writeln('| ${values.join(' | ')} |');
      }
    }

    return buffer.toString();
  }

  /// 保存到文件
  Future<String> _saveToFile(String content, ExportOptions options) async {
    final directory = await _getExportDirectory();
    final timestamp = options.includeTimestamp
        ? '_${DateTime.now().millisecondsSinceEpoch}'
        : '';
    final fileName = '${options.fileName}$timestamp${options.fileExtension}';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(content, encoding: options.encoding);

    return filePath;
  }

  /// 获取导出目录
  Future<Directory> _getExportDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('File export not supported on web');
    }

    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }

  /// 列出已导出的文件
  Future<List<FileSystemEntity>> listExportedFiles() async {
    try {
      final directory = await _getExportDirectory();
      return directory.listSync();
    } catch (e) {
      _logger.e('Failed to list exported files: $e');
      return [];
    }
  }

  /// 删除导出文件
  Future<bool> deleteExportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to delete file: $e');
      return false;
    }
  }

  /// 清理所有导出文件
  Future<int> clearAllExports() async {
    try {
      final directory = await _getExportDirectory();
      final files = directory.listSync();
      var count = 0;

      for (final file in files) {
        await file.delete();
        count++;
      }

      return count;
    } catch (e) {
      _logger.e('Failed to clear exports: $e');
      return 0;
    }
  }
}
