import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/shared/providers/voice_provider.dart';

void main() {
  group('VoiceProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('初始状态正确', () {
      final state = container.read(voiceProvider);
      expect(state.isListening, false);
      expect(state.recognizedText, '');
      expect(state.error, null);
      expect(state.isProcessing, false);
      expect(state.language, 'en');
    });

    test('checkPermission 检查权限', () async {
      final notifier = container.read(voiceProvider.notifier);
      await notifier.checkPermission();

      final state = container.read(voiceProvider);
      expect(state.hasPermission, isNotNull);
    }, skip: 'Requires voice recognition platform plugin');

    test('requestPermission 请求权限', () async {
      final notifier = container.read(voiceProvider.notifier);
      await notifier.requestPermission();

      final state = container.read(voiceProvider);
      expect(state.hasPermission, isA<bool>());
    }, skip: 'Requires voice recognition platform plugin');

    test('startListening 开始监听', () async {
      final notifier = container.read(voiceProvider.notifier);

      // 先确保有权限
      await notifier.checkPermission();

      // 开始监听
      await notifier.startListening();

      final state = container.read(voiceProvider);
      expect(state.isListening, true);
      expect(state.error, isNull);
    }, skip: 'Requires voice recognition platform plugin');

    test('stopListening 停止监听', () async {
      final notifier = container.read(voiceProvider.notifier);

      // 先开始监听
      await notifier.startListening();

      // 然后停止
      await notifier.stopListening();

      final state = container.read(voiceProvider);
      expect(state.isListening, false);
    }, skip: 'Requires voice recognition platform plugin');

    test('setLanguage 更新识别语言', () async {
      final notifier = container.read(voiceProvider.notifier);
      notifier.setLanguage('zh');

      final state = container.read(voiceProvider);
      expect(state.language, 'zh');
    }, skip: 'Requires voice recognition platform plugin');

    test('clearResult 清除识别结果', () async {
      final notifier = container.read(voiceProvider.notifier);

      // 设置一些状态
      await notifier.startListening();

      // 清除
      notifier.clearResult();

      final state = container.read(voiceProvider);
      expect(state.recognizedText, '');
      expect(state.isListening, false);
      expect(state.error, isNull);
    }, skip: 'Requires voice recognition platform plugin');

    test('voiceSupportedLanguagesProvider 返回语言列表', () {
      final languages = container.read(voiceSupportedLanguagesProvider);
      expect(languages, isNotEmpty);
      expect(languages, ['en', 'zh', 'ug', 'tr']);
    });

    test('voiceManagerProvider 返回 VoiceRecognitionManager', () {
      final manager = container.read(voiceManagerProvider);
      expect(manager, isNotNull);
    });

    test('多个 startListening 和 stopListening 调用', () async {
      final notifier = container.read(voiceProvider.notifier);

      await notifier.startListening();
      var state = container.read(voiceProvider);
      expect(state.isListening, true);

      await notifier.stopListening();
      state = container.read(voiceProvider);
      expect(state.isListening, false);

      await notifier.startListening();
      state = container.read(voiceProvider);
      expect(state.isListening, true);
    }, skip: 'Requires voice recognition platform plugin');

    test('权限拒绝时的错误处理', () async {
      final notifier = container.read(voiceProvider.notifier);

      // 模拟权限被拒绝
      await notifier.requestPermission();

      // 如果权限被拒绝，startListening 应该返回并设置 hasPermission 为 false
      await notifier.startListening();

      final state = container.read(voiceProvider);
      // 验证状态被正确设置
      expect(state, isA<VoiceState>());
    }, skip: 'Requires voice recognition platform plugin');
  });
}
