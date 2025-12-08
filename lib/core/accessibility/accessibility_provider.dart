/// 辅助功能 Provider
///
/// 管理辅助功能状态和设置
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'accessibility_settings.dart';

/// 辅助功能 Provider
final accessibilityProvider =
    NotifierProvider<AccessibilityNotifier, AccessibilitySettings>(
  AccessibilityNotifier.new,
);

/// 辅助功能状态管理
class AccessibilityNotifier extends Notifier<AccessibilitySettings> {
  static const String _storageKey = 'accessibility_settings';
  Box? _box;

  @override
  AccessibilitySettings build() {
    _initStorage();
    return AccessibilitySettings.defaults;
  }

  Future<void> _initStorage() async {
    try {
      if (Hive.isBoxOpen('app_preferences')) {
        _box = Hive.box('app_preferences');
      } else {
        _box = await Hive.openBox('app_preferences');
      }
      await _loadSettings();
    } catch (e) {
      // 存储初始化失败，使用默认设置
    }
  }

  Future<void> _loadSettings() async {
    try {
      final json = _box?.get(_storageKey) as String?;
      if (json != null) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        state = AccessibilitySettings.fromJson(data);
      }
    } catch (e) {
      // 加载失败，使用默认设置
    }
  }

  Future<void> _saveSettings() async {
    try {
      final json = jsonEncode(state.toJson());
      await _box?.put(_storageKey, json);
    } catch (e) {
      // 保存失败
    }
  }

  /// 设置字体大小
  Future<void> setFontSize(FontSizePreset preset) async {
    state = state.copyWith(fontSize: preset);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置粗体文字
  Future<void> setBoldText(bool enabled) async {
    state = state.copyWith(boldText: enabled);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置对比度
  Future<void> setContrast(ContrastPreset preset) async {
    state = state.copyWith(contrast: preset);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置动画偏好
  Future<void> setAnimation(AnimationPreset preset) async {
    state = state.copyWith(animation: preset);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置屏幕阅读器优化
  Future<void> setScreenReaderOptimized(bool enabled) async {
    state = state.copyWith(screenReaderOptimized: enabled);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置触摸目标放大
  Future<void> setLargerTouchTargets(bool enabled) async {
    state = state.copyWith(largerTouchTargets: enabled);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置减少透明度
  Future<void> setReduceTransparency(bool enabled) async {
    state = state.copyWith(reduceTransparency: enabled);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置焦点高亮
  Future<void> setHighlightFocus(bool enabled) async {
    state = state.copyWith(highlightFocus: enabled);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置语音反馈
  Future<void> setVoiceFeedback(bool enabled) async {
    state = state.copyWith(voiceFeedback: enabled);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置触觉反馈
  Future<void> setHapticFeedback(bool enabled) async {
    state = state.copyWith(hapticFeedback: enabled);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 设置色盲模式
  Future<void> setColorBlindMode(ColorBlindMode mode) async {
    state = state.copyWith(colorBlindMode: mode);
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 重置为默认设置
  Future<void> reset() async {
    state = AccessibilitySettings.defaults;
    await _saveSettings();
    _provideHapticFeedback();
  }

  /// 从系统检测设置
  Future<void> detectSystemSettings() async {
    // 检测系统辅助功能设置
    // 这些值需要从平台通道获取
    // TODO: 实现平台检测
  }

  void _provideHapticFeedback() {
    if (state.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }
}

/// 是否启用减弱动画
final reduceMotionProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.animation != AnimationPreset.normal;
});

/// 动画时长倍数
final animationDurationFactorProvider = Provider<double>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.animationDurationFactor;
});

/// 字体缩放因子
final fontScaleProvider = Provider<double>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.fontSize.scaleFactor;
});

/// 最小触摸目标尺寸
final minTouchTargetProvider = Provider<double>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.minTouchTargetSize;
});

/// 是否启用触觉反馈
final hapticFeedbackEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilityProvider);
  return settings.hapticFeedback;
});
