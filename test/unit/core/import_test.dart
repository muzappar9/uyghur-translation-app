/// 数据导入模块测试
///
/// 测试数据导入功能
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/core/import/import_formats.dart';
import 'package:uyghur_translator/core/import/import_service.dart';
import 'package:uyghur_translator/core/import/import_provider.dart';

void main() {
  group('ImportFormat', () {
    test('fromExtension should detect JSON', () {
      expect(ImportFormat.fromExtension('.json'), ImportFormat.json);
      expect(ImportFormat.fromExtension('json'), ImportFormat.json);
    });

    test('fromExtension should detect CSV', () {
      expect(ImportFormat.fromExtension('.csv'), ImportFormat.csv);
      expect(ImportFormat.fromExtension('csv'), ImportFormat.csv);
    });

    test('fromExtension should detect TXT', () {
      expect(ImportFormat.fromExtension('.txt'), ImportFormat.text);
    });

    test('fromExtension should detect TMX', () {
      expect(ImportFormat.fromExtension('.tmx'), ImportFormat.tmx);
    });

    test('fromExtension should return null for unknown', () {
      expect(ImportFormat.fromExtension('.xyz'), null);
    });
  });

  group('ImportedEntry', () {
    test('should create from JSON', () {
      final entry = ImportedEntry.fromJson({
        'sourceText': 'Hello',
        'targetText': '你好',
        'sourceLang': 'en',
        'targetLang': 'zh',
      });

      expect(entry.sourceText, 'Hello');
      expect(entry.targetText, '你好');
      expect(entry.sourceLang, 'en');
      expect(entry.targetLang, 'zh');
    });

    test('should handle alternative field names', () {
      final entry = ImportedEntry.fromJson({
        'source': 'Hello',
        'target': '你好',
        'source_lang': 'en',
        'target_lang': 'zh',
      });

      expect(entry.sourceText, 'Hello');
      expect(entry.targetText, '你好');
    });

    test('should serialize to JSON', () {
      const entry = ImportedEntry(
        sourceText: 'Hello',
        targetText: '你好',
        sourceLang: 'en',
        targetLang: 'zh',
      );

      final json = entry.toJson();
      expect(json['sourceText'], 'Hello');
      expect(json['targetText'], '你好');
    });
  });

  group('ImportedDictionaryEntry', () {
    test('should create from JSON', () {
      final entry = ImportedDictionaryEntry.fromJson({
        'word': 'apple',
        'definition': '苹果',
        'language': 'en',
        'phonetic': '/ˈæpl/',
      });

      expect(entry.word, 'apple');
      expect(entry.definition, '苹果');
      expect(entry.phonetic, '/ˈæpl/');
    });

    test('should handle meaning as definition', () {
      final entry = ImportedDictionaryEntry.fromJson({
        'word': 'apple',
        'meaning': '苹果',
      });

      expect(entry.definition, '苹果');
    });
  });

  group('JsonImportParser', () {
    test('should parse array of translations', () {
      final content = jsonEncode([
        {'sourceText': 'Hello', 'targetText': '你好'},
        {'sourceText': 'World', 'targetText': '世界'},
      ]);

      final entries = JsonImportParser.parseTranslations(content);

      expect(entries.length, 2);
      expect(entries[0].sourceText, 'Hello');
      expect(entries[1].sourceText, 'World');
    });

    test('should parse object with translations field', () {
      final content = jsonEncode({
        'translations': [
          {'sourceText': 'Hello', 'targetText': '你好'},
        ],
      });

      final entries = JsonImportParser.parseTranslations(content);

      expect(entries.length, 1);
      expect(entries[0].sourceText, 'Hello');
    });

    test('should parse object with data field', () {
      final content = jsonEncode({
        'data': [
          {'sourceText': 'Hello', 'targetText': '你好'},
        ],
      });

      final entries = JsonImportParser.parseTranslations(content);

      expect(entries.length, 1);
    });

    test('should parse single entry object', () {
      final content = jsonEncode({
        'sourceText': 'Hello',
        'targetText': '你好',
      });

      final entries = JsonImportParser.parseTranslations(content);

      expect(entries.length, 1);
      expect(entries[0].sourceText, 'Hello');
    });
  });

  group('CsvImportParser', () {
    test('should parse CSV with header', () {
      const content = '''source,target
Hello,你好
World,世界''';

      final entries = CsvImportParser.parseTranslations(content);

      expect(entries.length, 2);
      expect(entries[0].sourceText, 'Hello');
      expect(entries[0].targetText, '你好');
    });

    test('should handle quoted fields', () {
      const content = '''source,target
"Hello, World","你好，世界"''';

      final entries = CsvImportParser.parseTranslations(content);

      expect(entries.length, 1);
      expect(entries[0].sourceText, 'Hello, World');
    });

    test('should detect column names', () {
      const content = '''sourceText,targetText,sourceLang,targetLang
Hello,你好,en,zh''';

      final entries = CsvImportParser.parseTranslations(content);

      expect(entries.length, 1);
      expect(entries[0].sourceLang, 'en');
      expect(entries[0].targetLang, 'zh');
    });

    test('should parse without header', () {
      const content = '''Hello,你好
World,世界''';

      final entries =
          CsvImportParser.parseTranslations(content, hasHeader: false);

      expect(entries.length, 2);
    });

    test('should skip empty lines', () {
      const content = '''source,target

Hello,你好

World,世界
''';

      final entries = CsvImportParser.parseTranslations(content);

      expect(entries.length, 2);
    });
  });

  group('TextImportParser', () {
    test('should parse tab-separated lines', () {
      const content = '''Hello\t你好
World\t世界''';

      final entries = TextImportParser.parseTranslations(content);

      expect(entries.length, 2);
      expect(entries[0].sourceText, 'Hello');
      expect(entries[0].targetText, '你好');
    });

    test('should parse pipe-separated lines', () {
      const content = '''Hello | 你好
World | 世界''';

      final entries = TextImportParser.parseTranslations(content);

      expect(entries.length, 2);
    });

    test('should parse arrow-separated lines', () {
      const content = '''Hello -> 你好
World -> 世界''';

      final entries = TextImportParser.parseTranslations(content);

      expect(entries.length, 2);
    });

    test('should skip unparseable lines', () {
      const content = '''Hello\t你好
This line has no separator
World\t世界''';

      final entries = TextImportParser.parseTranslations(content);

      expect(entries.length, 2);
    });
  });

  group('ImportResult', () {
    test('should create error result', () {
      final result = ImportResult.error('Something went wrong');

      expect(result.success, false);
      expect(result.errors, contains('Something went wrong'));
    });

    test('summary should include all counts', () {
      const result = ImportResult(
        success: true,
        totalCount: 100,
        importedCount: 95,
        skippedCount: 3,
        errorCount: 2,
        duration: Duration(milliseconds: 500),
      );

      final summary = result.summary;
      expect(summary, contains('100'));
      expect(summary, contains('95'));
      expect(summary, contains('3'));
      expect(summary, contains('2'));
      expect(summary, contains('500ms'));
    });
  });

  group('ImportService', () {
    late ImportService service;

    setUp(() {
      service = ImportService();
    });

    test('detectFormat should detect JSON from content', () {
      expect(
        service.detectFormat('data', '[{"a": 1}]'),
        ImportFormat.json,
      );
      expect(
        service.detectFormat('data', '{"a": 1}'),
        ImportFormat.json,
      );
    });

    test('detectFormat should detect from extension first', () {
      expect(
        service.detectFormat('data.json', 'not json'),
        ImportFormat.json,
      );
    });

    test('previewImport should return preview data', () async {
      final content = jsonEncode([
        {'sourceText': 'Hello', 'targetText': '你好'},
        {'sourceText': 'World', 'targetText': '世界'},
        {'sourceText': 'Test', 'targetText': '测试'},
      ]);

      final preview = await service.previewImport(content, ImportFormat.json);

      expect(preview.totalCount, 3);
      expect(preview.previewEntries.length, 3);
      expect(preview.hasError, false);
    });

    test('previewImport should limit preview count', () async {
      final content = jsonEncode(List.generate(
          20, (i) => {'sourceText': 'Text $i', 'targetText': '文本 $i'}));

      final preview = await service.previewImport(
        content,
        ImportFormat.json,
        maxPreviewCount: 5,
      );

      expect(preview.totalCount, 20);
      expect(preview.previewEntries.length, 5);
    });

    test('importTranslations should import JSON data', () async {
      final content = jsonEncode([
        {'sourceText': 'Hello', 'targetText': '你好'},
        {'sourceText': 'World', 'targetText': '世界'},
      ]);

      final result = await service.importTranslations(
        content,
        ImportFormat.json,
      );

      expect(result.success, true);
      expect(result.totalCount, 2);
      expect(result.importedCount, 2);
    });

    test('importTranslations should skip invalid entries', () async {
      final content = jsonEncode([
        {'sourceText': 'Hello', 'targetText': '你好'},
        {'sourceText': '', 'targetText': ''}, // Invalid
        {'sourceText': 'World', 'targetText': '世界'},
      ]);

      final result = await service.importTranslations(
        content,
        ImportFormat.json,
        options: const ImportOptions(validateData: true),
      );

      expect(result.success, true);
      expect(result.importedCount, 2);
      expect(result.skippedCount, 1);
    });

    test('importTranslations should call progress callback', () async {
      final content = jsonEncode(List.generate(
          50, (i) => {'sourceText': 'Text $i', 'targetText': '文本 $i'}));

      final progressUpdates = <int>[];

      await service.importTranslations(
        content,
        ImportFormat.json,
        options: const ImportOptions(batchSize: 10),
        onProgress: (current, total, message) {
          progressUpdates.add(current);
        },
      );

      expect(progressUpdates.isNotEmpty, true);
    });
  });

  group('ImportState', () {
    test('should have correct default values', () {
      const state = ImportState();

      expect(state.status, ImportStatus.idle);
      expect(state.isLoading, false);
      expect(state.hasResult, false);
      expect(state.hasError, false);
      expect(state.progressPercent, 0);
    });

    test('progressPercent should calculate correctly', () {
      const state = ImportState(progress: 50, total: 100);
      expect(state.progressPercent, 0.5);
    });

    test('isLoading should be true during import', () {
      const importing = ImportState(status: ImportStatus.importing);
      const previewing = ImportState(status: ImportStatus.previewing);
      const idle = ImportState(status: ImportStatus.idle);

      expect(importing.isLoading, true);
      expect(previewing.isLoading, true);
      expect(idle.isLoading, false);
    });
  });

  group('ImportProvider', () {
    test('should provide ImportService', () {
      final container = ProviderContainer();

      final service = container.read(importServiceProvider);
      expect(service, isA<ImportService>());

      container.dispose();
    });

    test('importStateProvider should have idle status initially', () {
      final container = ProviderContainer();

      final state = container.read(importStateProvider);
      expect(state.status, ImportStatus.idle);

      container.dispose();
    });

    test('isImportingProvider should reflect state', () {
      final container = ProviderContainer();

      expect(container.read(isImportingProvider), false);

      container.dispose();
    });

    test('importProgressProvider should return progress', () {
      final container = ProviderContainer();

      expect(container.read(importProgressProvider), 0);

      container.dispose();
    });
  });

  group('ImportOptions', () {
    test('should have correct defaults', () {
      const options = ImportOptions();

      expect(options.overwriteExisting, false);
      expect(options.skipDuplicates, true);
      expect(options.validateData, true);
      expect(options.preserveTimestamps, true);
      expect(options.batchSize, 100);
    });
  });
}
