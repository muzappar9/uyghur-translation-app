/// 数据导入格式
///
/// 定义支持的导入格式和解析器
library;

import 'dart:convert';

/// 导入格式
enum ImportFormat {
  /// JSON 格式
  json('JSON', '.json', 'application/json'),

  /// CSV 格式
  csv('CSV', '.csv', 'text/csv'),

  /// 文本格式（一行一条）
  text('文本', '.txt', 'text/plain'),

  /// TMX 翻译记忆格式
  tmx('TMX', '.tmx', 'application/x-tmx');

  final String displayName;
  final String extension;
  final String mimeType;

  const ImportFormat(this.displayName, this.extension, this.mimeType);

  /// 从文件扩展名检测格式
  static ImportFormat? fromExtension(String ext) {
    final normalized = ext.toLowerCase();
    for (final format in values) {
      if (normalized == format.extension ||
          normalized == format.extension.substring(1)) {
        return format;
      }
    }
    return null;
  }
}

/// 导入的翻译条目
class ImportedEntry {
  final String sourceText;
  final String targetText;
  final String? sourceLang;
  final String? targetLang;
  final DateTime? timestamp;
  final bool? isFavorite;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const ImportedEntry({
    required this.sourceText,
    required this.targetText,
    this.sourceLang,
    this.targetLang,
    this.timestamp,
    this.isFavorite,
    this.notes,
    this.metadata,
  });

  factory ImportedEntry.fromJson(Map<String, dynamic> json) {
    return ImportedEntry(
      sourceText:
          json['sourceText'] as String? ?? json['source'] as String? ?? '',
      targetText:
          json['targetText'] as String? ?? json['target'] as String? ?? '',
      sourceLang:
          json['sourceLang'] as String? ?? json['source_lang'] as String?,
      targetLang:
          json['targetLang'] as String? ?? json['target_lang'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? json['favorite'] as bool?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'sourceText': sourceText,
        'targetText': targetText,
        if (sourceLang != null) 'sourceLang': sourceLang,
        if (targetLang != null) 'targetLang': targetLang,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
        if (isFavorite != null) 'isFavorite': isFavorite,
        if (notes != null) 'notes': notes,
        if (metadata != null) 'metadata': metadata,
      };

  @override
  String toString() => 'ImportedEntry($sourceText -> $targetText)';
}

/// 导入的词典条目
class ImportedDictionaryEntry {
  final String word;
  final String definition;
  final String? language;
  final String? phonetic;
  final List<String>? examples;
  final List<String>? synonyms;
  final List<String>? antonyms;
  final String? partOfSpeech;
  final Map<String, dynamic>? metadata;

  const ImportedDictionaryEntry({
    required this.word,
    required this.definition,
    this.language,
    this.phonetic,
    this.examples,
    this.synonyms,
    this.antonyms,
    this.partOfSpeech,
    this.metadata,
  });

  factory ImportedDictionaryEntry.fromJson(Map<String, dynamic> json) {
    return ImportedDictionaryEntry(
      word: json['word'] as String? ?? '',
      definition:
          json['definition'] as String? ?? json['meaning'] as String? ?? '',
      language: json['language'] as String? ?? json['lang'] as String?,
      phonetic: json['phonetic'] as String?,
      examples: (json['examples'] as List?)?.cast<String>(),
      synonyms: (json['synonyms'] as List?)?.cast<String>(),
      antonyms: (json['antonyms'] as List?)?.cast<String>(),
      partOfSpeech: json['partOfSpeech'] as String? ?? json['pos'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'definition': definition,
        if (language != null) 'language': language,
        if (phonetic != null) 'phonetic': phonetic,
        if (examples != null) 'examples': examples,
        if (synonyms != null) 'synonyms': synonyms,
        if (antonyms != null) 'antonyms': antonyms,
        if (partOfSpeech != null) 'partOfSpeech': partOfSpeech,
        if (metadata != null) 'metadata': metadata,
      };
}

/// 导入结果
class ImportResult {
  final bool success;
  final int totalCount;
  final int importedCount;
  final int skippedCount;
  final int errorCount;
  final List<String> errors;
  final List<String> warnings;
  final Duration duration;

  const ImportResult({
    required this.success,
    required this.totalCount,
    required this.importedCount,
    this.skippedCount = 0,
    this.errorCount = 0,
    this.errors = const [],
    this.warnings = const [],
    this.duration = Duration.zero,
  });

  factory ImportResult.error(String message) {
    return ImportResult(
      success: false,
      totalCount: 0,
      importedCount: 0,
      errors: [message],
    );
  }

  String get summary {
    final buffer = StringBuffer();
    buffer.writeln('导入结果:');
    buffer.writeln('- 总数: $totalCount');
    buffer.writeln('- 成功: $importedCount');
    if (skippedCount > 0) buffer.writeln('- 跳过: $skippedCount');
    if (errorCount > 0) buffer.writeln('- 错误: $errorCount');
    buffer.writeln('- 耗时: ${duration.inMilliseconds}ms');
    return buffer.toString();
  }
}

/// 导入选项
class ImportOptions {
  /// 是否覆盖已存在的条目
  final bool overwriteExisting;

  /// 是否跳过重复项
  final bool skipDuplicates;

  /// 是否验证数据
  final bool validateData;

  /// 默认源语言
  final String? defaultSourceLang;

  /// 默认目标语言
  final String? defaultTargetLang;

  /// 是否保留时间戳
  final bool preserveTimestamps;

  /// 批量大小
  final int batchSize;

  const ImportOptions({
    this.overwriteExisting = false,
    this.skipDuplicates = true,
    this.validateData = true,
    this.defaultSourceLang,
    this.defaultTargetLang,
    this.preserveTimestamps = true,
    this.batchSize = 100,
  });
}

/// JSON 解析器
class JsonImportParser {
  /// 解析翻译记录
  static List<ImportedEntry> parseTranslations(String content) {
    final dynamic data = jsonDecode(content);

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => ImportedEntry.fromJson(item))
          .toList();
    } else if (data is Map<String, dynamic>) {
      // 可能是包含 translations 字段的对象
      if (data.containsKey('translations')) {
        final translations = data['translations'] as List;
        return translations
            .whereType<Map<String, dynamic>>()
            .map((item) => ImportedEntry.fromJson(item))
            .toList();
      } else if (data.containsKey('data')) {
        final dataList = data['data'] as List;
        return dataList
            .whereType<Map<String, dynamic>>()
            .map((item) => ImportedEntry.fromJson(item))
            .toList();
      } else {
        // 单个条目
        return [ImportedEntry.fromJson(data)];
      }
    }

    return [];
  }

  /// 解析词典条目
  static List<ImportedDictionaryEntry> parseDictionary(String content) {
    final dynamic data = jsonDecode(content);

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((item) => ImportedDictionaryEntry.fromJson(item))
          .toList();
    } else if (data is Map<String, dynamic>) {
      if (data.containsKey('entries') || data.containsKey('words')) {
        final entries = (data['entries'] ?? data['words']) as List;
        return entries
            .whereType<Map<String, dynamic>>()
            .map((item) => ImportedDictionaryEntry.fromJson(item))
            .toList();
      } else {
        return [ImportedDictionaryEntry.fromJson(data)];
      }
    }

    return [];
  }
}

/// CSV 解析器
class CsvImportParser {
  /// 解析翻译记录
  static List<ImportedEntry> parseTranslations(
    String content, {
    String delimiter = ',',
    bool hasHeader = true,
  }) {
    final lines = const LineSplitter().convert(content);
    if (lines.isEmpty) return [];

    final entries = <ImportedEntry>[];
    var startIndex = 0;

    // 列索引
    var sourceIndex = 0;
    var targetIndex = 1;
    var sourceLangIndex = -1;
    var targetLangIndex = -1;
    var notesIndex = -1;

    if (hasHeader && lines.isNotEmpty) {
      final header = _parseCsvLine(lines[0], delimiter);
      startIndex = 1;

      // 检测列
      for (var i = 0; i < header.length; i++) {
        final col = header[i].toLowerCase().trim();
        if (col.contains('source') && !col.contains('lang')) {
          sourceIndex = i;
        } else if (col.contains('target') && !col.contains('lang')) {
          targetIndex = i;
        } else if (col.contains('source') && col.contains('lang')) {
          sourceLangIndex = i;
        } else if (col.contains('target') && col.contains('lang')) {
          targetLangIndex = i;
        } else if (col.contains('note')) {
          notesIndex = i;
        }
      }
    }

    for (var i = startIndex; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final fields = _parseCsvLine(line, delimiter);
      if (fields.length <= sourceIndex || fields.length <= targetIndex) {
        continue;
      }

      final source = fields[sourceIndex].trim();
      final target = fields[targetIndex].trim();

      if (source.isEmpty || target.isEmpty) continue;

      entries.add(ImportedEntry(
        sourceText: source,
        targetText: target,
        sourceLang: sourceLangIndex >= 0 && fields.length > sourceLangIndex
            ? fields[sourceLangIndex].trim()
            : null,
        targetLang: targetLangIndex >= 0 && fields.length > targetLangIndex
            ? fields[targetLangIndex].trim()
            : null,
        notes: notesIndex >= 0 && fields.length > notesIndex
            ? fields[notesIndex].trim()
            : null,
      ));
    }

    return entries;
  }

  static List<String> _parseCsvLine(String line, String delimiter) {
    final fields = <String>[];
    var inQuotes = false;
    var field = StringBuffer();

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == delimiter && !inQuotes) {
        fields.add(field.toString());
        field = StringBuffer();
      } else {
        field.write(char);
      }
    }

    fields.add(field.toString());
    return fields;
  }
}

/// 文本解析器
class TextImportParser {
  /// 解析翻译记录（格式：源文本\t目标文本 或 源文本 | 目标文本）
  static List<ImportedEntry> parseTranslations(String content) {
    final lines = const LineSplitter().convert(content);
    final entries = <ImportedEntry>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // 尝试不同的分隔符
      List<String> parts;
      if (trimmed.contains('\t')) {
        parts = trimmed.split('\t');
      } else if (trimmed.contains(' | ')) {
        parts = trimmed.split(' | ');
      } else if (trimmed.contains('|')) {
        parts = trimmed.split('|');
      } else if (trimmed.contains(' -> ')) {
        parts = trimmed.split(' -> ');
      } else if (trimmed.contains('->')) {
        parts = trimmed.split('->');
      } else {
        continue; // 无法解析
      }

      if (parts.length >= 2) {
        final source = parts[0].trim();
        final target = parts[1].trim();

        if (source.isNotEmpty && target.isNotEmpty) {
          entries.add(ImportedEntry(
            sourceText: source,
            targetText: target,
          ));
        }
      }
    }

    return entries;
  }
}

/// TMX 解析器
class TmxImportParser {
  /// 解析 TMX 文件
  static List<ImportedEntry> parseTranslations(String content) {
    // 简化的 TMX 解析（实际应使用 XML 解析器）
    final entries = <ImportedEntry>[];

    // 匹配 <tu> 翻译单元
    final tuRegex = RegExp(r'<tu[^>]*>(.*?)</tu>', dotAll: true);
    final segRegex = RegExp(r'<seg>(.*?)</seg>', dotAll: true);
    final langRegex = RegExp(r'xml:lang="([^"]*)"');

    for (final tuMatch in tuRegex.allMatches(content)) {
      final tuContent = tuMatch.group(1) ?? '';

      // 查找所有 <tuv> 翻译单元变体
      final tuvRegex = RegExp(r'<tuv[^>]*>(.*?)</tuv>', dotAll: true);
      final variants = <String, String>{};

      for (final tuvMatch in tuvRegex.allMatches(tuContent)) {
        final tuvContent = tuvMatch.group(0) ?? '';
        final langMatch = langRegex.firstMatch(tuvContent);
        final lang = langMatch?.group(1);

        final segMatch = segRegex.firstMatch(tuvContent);
        final seg = segMatch?.group(1)?.trim();

        if (lang != null && seg != null) {
          variants[lang] = seg;
        }
      }

      // 创建条目（假设第一个是源，第二个是目标）
      if (variants.length >= 2) {
        final langs = variants.keys.toList();
        entries.add(ImportedEntry(
          sourceText: variants[langs[0]]!,
          targetText: variants[langs[1]]!,
          sourceLang: langs[0],
          targetLang: langs[1],
        ));
      }
    }

    return entries;
  }
}
