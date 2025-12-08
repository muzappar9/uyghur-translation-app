import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uyghur_translator/shared/services/storage/preference_service.dart';
import 'package:logger/logger.dart';

part 'settings_provider.freezed.dart';

/// 应用设置状态
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default('en') String sourceLanguage,
    @Default('ug') String targetLanguage,
    @Default(true) bool enableVoiceInput,
    @Default(true) bool enableOcr,
    @Default(true) bool enableNotifications,
    @Default(true) bool enableOfflineMode,
    @Default(false) bool darkMode,
    @Default('system') String theme,
    @Default(null) String? selectedVoice,
    @Default(1.0) double voiceSpeed,
    @Default(null) String? error,
  }) = _SettingsState;
}

/// 应用设置 StateNotifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final PreferenceService _preferenceService;
  final Logger _logger = Logger();

  SettingsNotifier(this._preferenceService) : super(const SettingsState()) {
    _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      // PreferenceService 存储的是稀化的语言，源语言和目标语言
      // 在应用程序内需要分开上下文管理
      final appLanguage = _preferenceService.getLanguage();

      state = state.copyWith(
        sourceLanguage: appLanguage,
        targetLanguage: appLanguage == 'zh' ? 'ug' : 'zh',
      );

      _logger.i('Settings loaded successfully');
    } catch (e) {
      _logger.e('Failed to load settings: $e');
      state = state.copyWith(error: 'Failed to load settings: $e');
    }
  }

  /// 设置源语言
  Future<void> setSourceLanguage(String language) async {
    try {
      // 源语言是背景語言，存储到 PreferenceService
      await _preferenceService.setLanguage(language);
      state = state.copyWith(sourceLanguage: language);
      _logger.i('Source language set to: $language');
    } catch (e) {
      _logger.e('Failed to set source language: $e');
      state = state.copyWith(error: 'Failed to set source language: $e');
    }
  }

  /// 设置目标语言
  Future<void> setTargetLanguage(String language) async {
    try {
      // 目标语言需要存储到五体应用中的会话是五体或难体选择
      // 暂不序列化到 PreferenceService，在 Riverpod 状态中维持
      state = state.copyWith(targetLanguage: language);
      _logger.i('Target language set to: $language');
    } catch (e) {
      _logger.e('Failed to set target language: $e');
      state = state.copyWith(error: 'Failed to set target language: $e');
    }
  }

  /// 启用/禁用语音输入
  Future<void> setVoiceInputEnabled(bool enabled) async {
    try {
      state = state.copyWith(enableVoiceInput: enabled);
      _logger.i('Voice input enabled: $enabled');
    } catch (e) {
      _logger.e('Failed to set voice input: $e');
      state = state.copyWith(error: 'Failed to set voice input: $e');
    }
  }

  /// 启用/禁用OCR
  Future<void> setOcrEnabled(bool enabled) async {
    try {
      state = state.copyWith(enableOcr: enabled);
      _logger.i('OCR enabled: $enabled');
    } catch (e) {
      _logger.e('Failed to set OCR: $e');
      state = state.copyWith(error: 'Failed to set OCR: $e');
    }
  }

  /// 启用/禁用通知
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      state = state.copyWith(enableNotifications: enabled);
      _logger.i('Notifications enabled: $enabled');
    } catch (e) {
      _logger.e('Failed to set notifications: $e');
      state = state.copyWith(error: 'Failed to set notifications: $e');
    }
  }

  /// 启用/禁用离线模式
  Future<void> setOfflineModeEnabled(bool enabled) async {
    try {
      state = state.copyWith(enableOfflineMode: enabled);
      _logger.i('Offline mode enabled: $enabled');
    } catch (e) {
      _logger.e('Failed to set offline mode: $e');
      state = state.copyWith(error: 'Failed to set offline mode: $e');
    }
  }

  /// 设置深色模式
  Future<void> setDarkMode(bool enabled) async {
    try {
      state = state.copyWith(darkMode: enabled);
      _logger.i('Dark mode enabled: $enabled');
    } catch (e) {
      _logger.e('Failed to set dark mode: $e');
      state = state.copyWith(error: 'Failed to set dark mode: $e');
    }
  }

  /// 设置主题
  Future<void> setTheme(String theme) async {
    try {
      state = state.copyWith(theme: theme);
      _logger.i('Theme set to: $theme');
    } catch (e) {
      _logger.e('Failed to set theme: $e');
      state = state.copyWith(error: 'Failed to set theme: $e');
    }
  }

  /// 设置语音
  Future<void> setSelectedVoice(String? voice) async {
    try {
      state = state.copyWith(selectedVoice: voice);
      _logger.i('Voice set to: $voice');
    } catch (e) {
      _logger.e('Failed to set voice: $e');
      state = state.copyWith(error: 'Failed to set voice: $e');
    }
  }

  /// 设置语音速度
  Future<void> setVoiceSpeed(double speed) async {
    try {
      if (speed < 0.5 || speed > 2.0) {
        throw ArgumentError('Voice speed must be between 0.5 and 2.0');
      }
      state = state.copyWith(voiceSpeed: speed);
      _logger.i('Voice speed set to: $speed');
    } catch (e) {
      _logger.e('Failed to set voice speed: $e');
      state = state.copyWith(error: 'Failed to set voice speed: $e');
    }
  }

  /// 重置为默认设置
  Future<void> resetToDefaults() async {
    try {
      state = const SettingsState();
      _logger.i('Settings reset to defaults');
    } catch (e) {
      _logger.e('Failed to reset settings: $e');
      state = state.copyWith(error: 'Failed to reset settings: $e');
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 预设服务 Provider
final preferenceServiceProvider = Provider<PreferenceService>((ref) {
  return PreferenceService();
});

/// 应用设置 Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final preferenceService = ref.watch(preferenceServiceProvider);
  return SettingsNotifier(preferenceService);
});

/// 源语言 Provider
final sourceLanguageProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.sourceLanguage;
});

/// 目标语言 Provider
final targetLanguageProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.targetLanguage;
});

/// 应用主题 Provider
final appThemeProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.theme;
});

/// 深色模式 Provider
final darkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.darkMode;
});

/// 离线模式启用状态 Provider
final offlineModeEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.enableOfflineMode;
});
