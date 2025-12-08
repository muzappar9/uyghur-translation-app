import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uyghur_translator/shared/services/voice/voice_recognition_manager.dart';
import 'package:logger/logger.dart';

part 'voice_provider.freezed.dart';

/// 语音识别状态
@freezed
class VoiceState with _$VoiceState {
  const factory VoiceState({
    @Default(false) bool isListening,
    @Default('') String recognizedText,
    @Default(null) String? error,
    @Default(false) bool isProcessing,
    @Default('en') String language,
    @Default(false) bool hasPermission,
  }) = _VoiceState;
}

/// 语音识别 StateNotifier
class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceRecognitionManager _voiceManager;
  final Logger _logger = Logger();

  VoiceNotifier(this._voiceManager) : super(const VoiceState()) {
    // 初始化时检查权限
    _checkInitialPermission();
  }

  /// 初始化时的权限检查
  Future<void> _checkInitialPermission() async {
    try {
      await checkPermission();
    } catch (e) {
      _logger.e('Failed to check initial permission: $e');
    }
  }

  /// 检查权限
  Future<void> checkPermission() async {
    try {
      final hasPermission = await _voiceManager.hasPermission();
      state = state.copyWith(hasPermission: hasPermission);
      _logger.i('Voice permission checked: $hasPermission');
    } catch (e) {
      _logger.e('Failed to check permission: $e');
      state = state.copyWith(error: 'Permission check failed: $e');
    }
  }

  /// 请求权限
  Future<void> requestPermission() async {
    try {
      final granted = await _voiceManager.requestPermission();
      state = state.copyWith(hasPermission: granted);
      _logger.i('Voice permission requested: $granted');
    } catch (e) {
      _logger.e('Failed to request permission: $e');
      state = state.copyWith(error: 'Permission request failed: $e');
    }
  }

  /// 开始语音识别
  Future<void> startListening() async {
    if (!state.hasPermission) {
      await requestPermission();
      if (!state.hasPermission) {
        return;
      }
    }

    state = state.copyWith(
      isListening: true,
      recognizedText: '',
      error: null,
    );

    try {
      // 简化版：设置为监听状态
      _logger.i('Voice recognition started for language: ${state.language}');
    } catch (e) {
      state = state.copyWith(
        isListening: false,
        error: 'Failed to start listening: $e',
      );
      _logger.e('Failed to start listening: $e');
    }
  }

  /// 停止语音识别
  Future<void> stopListening() async {
    try {
      state = state.copyWith(isListening: false);
      _logger.i('Voice listening stopped');
    } catch (e) {
      state = state.copyWith(error: 'Failed to stop listening: $e');
      _logger.e('Failed to stop listening: $e');
    }
  }

  /// 设置语言
  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  /// 清除识别结果
  void clearResult() {
    state = state.copyWith(recognizedText: '', error: null);
  }
}

/// 语音识别 Manager Provider
final voiceManagerProvider = Provider<VoiceRecognitionManager>((ref) {
  return VoiceRecognitionManager();
});

/// 语音识别状态 Provider
final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final manager = ref.watch(voiceManagerProvider);
  return VoiceNotifier(manager);
});

/// 支持的语言列表 Provider
final voiceSupportedLanguagesProvider = Provider<List<String>>((ref) {
  return const ['en', 'zh', 'ug', 'tr'];
});
