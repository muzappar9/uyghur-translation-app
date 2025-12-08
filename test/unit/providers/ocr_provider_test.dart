import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/shared/providers/ocr_provider.dart';

void main() {
  group('OcrProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('初始状态正确', () {
      final state = container.read(ocrProvider);
      expect(state.imagePath, null);
      expect(state.recognizedText, '');
      expect(state.error, null);
      expect(state.isProcessing, false);
      expect(state.language, 'en');
    });

    test('checkPermission 检查权限', () async {
      final notifier = container.read(ocrProvider.notifier);
      await notifier.checkPermission();

      final state = container.read(ocrProvider);
      expect(state.hasPermission, isNotNull);
    }, skip: 'Requires OCR platform plugin');

    test('requestPermission 请求权限', () async {
      final notifier = container.read(ocrProvider.notifier);
      await notifier.requestPermission();

      final state = container.read(ocrProvider);
      expect(state.hasPermission, isA<bool>());
    }, skip: 'Requires OCR platform plugin');

    test('recognizeFromFile 从文件识别', () async {
      final notifier = container.read(ocrProvider.notifier);

      // 先确保有权限
      await notifier.checkPermission();

      // 从文件识别
      await notifier.recognizeFromFile('test_image.jpg');

      final state = container.read(ocrProvider);
      expect(state.imagePath, 'test_image.jpg');
      expect(state.isProcessing, false);
      expect(state.error, isNull);
    }, skip: 'Requires OCR platform plugin');

    test('recognizeFromBytes 从字节数据识别', () async {
      final notifier = container.read(ocrProvider.notifier);

      // 先确保有权限
      await notifier.checkPermission();

      // 从字节识别
      final bytes = [1, 2, 3, 4, 5];
      await notifier.recognizeFromBytes(bytes);

      final state = container.read(ocrProvider);
      expect(state.isProcessing, false);
      expect(state.error, isNull);
    }, skip: 'Requires OCR platform plugin');

    test('setLanguage 更新识别语言', () async {
      final notifier = container.read(ocrProvider.notifier);
      notifier.setLanguage('zh');

      final state = container.read(ocrProvider);
      expect(state.language, 'zh');
    }, skip: 'Requires OCR platform plugin');

    test('clearResult 清除识别结果', () async {
      final notifier = container.read(ocrProvider.notifier);

      // 先识别
      await notifier.checkPermission();
      await notifier.recognizeFromFile('test.jpg');

      // 清除
      notifier.clearResult();

      final state = container.read(ocrProvider);
      expect(state.imagePath, null);
      expect(state.recognizedText, '');
      expect(state.error, isNull);
    }, skip: 'Requires OCR platform plugin');

    test('ocrSupportedLanguagesProvider 返回语言列表', () {
      final languages = container.read(ocrSupportedLanguagesProvider);
      expect(languages, isNotEmpty);
      expect(languages, ['en', 'zh', 'ug', 'tr']);
    });

    test('ocrManagerProvider 返回 OCRRecognitionManager', () {
      final manager = container.read(ocrManagerProvider);
      expect(manager, isNotNull);
    });

    test('多个 recognizeFromFile 调用', () async {
      final notifier = container.read(ocrProvider.notifier);

      await notifier.checkPermission();

      await notifier.recognizeFromFile('image1.jpg');
      var state = container.read(ocrProvider);
      expect(state.imagePath, 'image1.jpg');

      await notifier.recognizeFromFile('image2.jpg');
      state = container.read(ocrProvider);
      expect(state.imagePath, 'image2.jpg');
    }, skip: 'Requires OCR platform plugin');

    test('权限拒绝时的处理', () async {
      final notifier = container.read(ocrProvider.notifier);

      // 请求权限
      await notifier.requestPermission();

      // 尝试识别
      await notifier.recognizeFromFile('test.jpg');

      // 验证状态被正确设置
      final state = container.read(ocrProvider);
      expect(state, isA<OcrState>());
    }, skip: 'Requires OCR platform plugin');

    test('处理空文件路径', () async {
      final notifier = container.read(ocrProvider.notifier);

      await notifier.checkPermission();
      await notifier.recognizeFromFile('');

      final state = container.read(ocrProvider);
      expect(state.imagePath, '');
    }, skip: 'Requires OCR platform plugin');

    test('处理空字节数据', () async {
      final notifier = container.read(ocrProvider.notifier);

      await notifier.checkPermission();
      await notifier.recognizeFromBytes([]);

      final state = container.read(ocrProvider);
      expect(state.isProcessing, false);
    }, skip: 'Requires OCR platform plugin');
  });
}
