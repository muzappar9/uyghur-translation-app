/// 键盘快捷键 Provider
///
/// 提供键盘快捷键状态管理
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'keyboard_shortcuts.dart';

/// 自定义快捷键状态
class CustomShortcuts {
  final Map<String, ShortcutActivator> customBindings;
  final bool enabled;

  const CustomShortcuts({
    this.customBindings = const {},
    this.enabled = true,
  });

  CustomShortcuts copyWith({
    Map<String, ShortcutActivator>? customBindings,
    bool? enabled,
  }) {
    return CustomShortcuts(
      customBindings: customBindings ?? this.customBindings,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'customBindings': customBindings.map(
          (key, value) => MapEntry(key, _serializeActivator(value)),
        ),
        'enabled': enabled,
      };

  factory CustomShortcuts.fromJson(Map<String, dynamic> json) {
    final bindings = (json['customBindings'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
              key, _deserializeActivator(value as Map<String, dynamic>)),
        ) ??
        {};

    return CustomShortcuts(
      customBindings: bindings,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> _serializeActivator(ShortcutActivator activator) {
    if (activator is SingleActivator) {
      return {
        'type': 'single',
        'key': activator.trigger.keyId,
        'control': activator.control,
        'meta': activator.meta,
        'alt': activator.alt,
        'shift': activator.shift,
      };
    }
    return {};
  }

  static ShortcutActivator _deserializeActivator(Map<String, dynamic> json) {
    if (json['type'] == 'single') {
      return SingleActivator(
        LogicalKeyboardKey(json['key'] as int),
        control: json['control'] as bool? ?? false,
        meta: json['meta'] as bool? ?? false,
        alt: json['alt'] as bool? ?? false,
        shift: json['shift'] as bool? ?? false,
      );
    }
    return const SingleActivator(LogicalKeyboardKey.escape);
  }
}

/// 自定义快捷键 Provider
final customShortcutsProvider =
    NotifierProvider<CustomShortcutsNotifier, CustomShortcuts>(
  CustomShortcutsNotifier.new,
);

/// 自定义快捷键管理
class CustomShortcutsNotifier extends Notifier<CustomShortcuts> {
  static const String _storageKey = 'custom_shortcuts';
  Box? _box;

  @override
  CustomShortcuts build() {
    _initStorage();
    return const CustomShortcuts();
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
      // 存储初始化失败
    }
  }

  Future<void> _loadSettings() async {
    try {
      final json = _box?.get(_storageKey) as String?;
      if (json != null) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        state = CustomShortcuts.fromJson(data);
      }
    } catch (e) {
      // 加载失败
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

  /// 设置自定义快捷键
  Future<void> setCustomShortcut(
    String action,
    ShortcutActivator activator,
  ) async {
    final newBindings =
        Map<String, ShortcutActivator>.from(state.customBindings);
    newBindings[action] = activator;
    state = state.copyWith(customBindings: newBindings);
    await _saveSettings();
  }

  /// 移除自定义快捷键
  Future<void> removeCustomShortcut(String action) async {
    final newBindings =
        Map<String, ShortcutActivator>.from(state.customBindings);
    newBindings.remove(action);
    state = state.copyWith(customBindings: newBindings);
    await _saveSettings();
  }

  /// 启用/禁用快捷键
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _saveSettings();
  }

  /// 重置为默认
  Future<void> reset() async {
    state = const CustomShortcuts();
    await _saveSettings();
  }
}

/// 最终快捷键绑定 Provider
final finalShortcutBindingsProvider =
    Provider<Map<ShortcutActivator, Intent>>((ref) {
  final customShortcuts = ref.watch(customShortcutsProvider);

  if (!customShortcuts.enabled) {
    return {};
  }

  // 获取默认快捷键
  final defaults = <String, ShortcutActivator>{
    'translate': AppShortcuts.translate,
    'clear': AppShortcuts.clear,
    'copy': AppShortcuts.copy,
    'paste': AppShortcuts.paste,
    'save': AppShortcuts.save,
    'swapLanguages': AppShortcuts.swapLanguages,
    'favorite': AppShortcuts.favorite,
    'search': AppShortcuts.search,
    'settings': AppShortcuts.settings,
    'history': AppShortcuts.history,
    'dictionary': AppShortcuts.dictionary,
    'voiceInput': AppShortcuts.voiceInput,
    'camera': AppShortcuts.camera,
    'export': AppShortcuts.export,
    'undo': AppShortcuts.undo,
    'redo': AppShortcuts.redo,
    'selectAll': AppShortcuts.selectAll,
    'help': AppShortcuts.help,
    'goBack': AppShortcuts.goBack,
  };

  // 应用自定义快捷键
  final merged = Map<String, ShortcutActivator>.from(defaults);
  merged.addAll(customShortcuts.customBindings);

  // 构建最终绑定
  return {
    merged['translate']!: const TranslateIntent(),
    merged['clear']!: const ClearIntent(),
    merged['copy']!: const CopyIntent(),
    merged['paste']!: const PasteIntent(),
    merged['save']!: const SaveIntent(),
    merged['swapLanguages']!: const SwapLanguagesIntent(),
    merged['favorite']!: const FavoriteIntent(),
    merged['search']!: const SearchIntent(),
    merged['settings']!: const SettingsIntent(),
    merged['history']!: const HistoryIntent(),
    merged['dictionary']!: const DictionaryIntent(),
    merged['voiceInput']!: const VoiceInputIntent(),
    merged['camera']!: const CameraIntent(),
    merged['export']!: const ExportIntent(),
    merged['undo']!: const UndoIntent(),
    merged['redo']!: const RedoIntent(),
    merged['selectAll']!: const SelectAllIntent(),
    merged['help']!: const HelpIntent(),
    merged['goBack']!: const GoBackIntent(),
  };
});
