/// 键盘快捷键定义
///
/// 定义应用中的所有键盘快捷键
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 快捷键意图
abstract class AppIntent extends Intent {
  const AppIntent();
}

/// 翻译意图
class TranslateIntent extends AppIntent {
  const TranslateIntent();
}

/// 清空意图
class ClearIntent extends AppIntent {
  const ClearIntent();
}

/// 复制意图
class CopyIntent extends AppIntent {
  const CopyIntent();
}

/// 粘贴意图
class PasteIntent extends AppIntent {
  const PasteIntent();
}

/// 交换语言意图
class SwapLanguagesIntent extends AppIntent {
  const SwapLanguagesIntent();
}

/// 保存意图
class SaveIntent extends AppIntent {
  const SaveIntent();
}

/// 收藏意图
class FavoriteIntent extends AppIntent {
  const FavoriteIntent();
}

/// 搜索意图
class SearchIntent extends AppIntent {
  const SearchIntent();
}

/// 设置意图
class SettingsIntent extends AppIntent {
  const SettingsIntent();
}

/// 历史意图
class HistoryIntent extends AppIntent {
  const HistoryIntent();
}

/// 字典意图
class DictionaryIntent extends AppIntent {
  const DictionaryIntent();
}

/// 语音输入意图
class VoiceInputIntent extends AppIntent {
  const VoiceInputIntent();
}

/// 相机意图
class CameraIntent extends AppIntent {
  const CameraIntent();
}

/// 导出意图
class ExportIntent extends AppIntent {
  const ExportIntent();
}

/// 撤销意图
class UndoIntent extends AppIntent {
  const UndoIntent();
}

/// 重做意图
class RedoIntent extends AppIntent {
  const RedoIntent();
}

/// 全选意图
class SelectAllIntent extends AppIntent {
  const SelectAllIntent();
}

/// 帮助意图
class HelpIntent extends AppIntent {
  const HelpIntent();
}

/// 返回/关闭意图
class GoBackIntent extends AppIntent {
  const GoBackIntent();
}

/// 导航到指定页面意图
class NavigateToIntent extends AppIntent {
  final String route;
  const NavigateToIntent(this.route);
}

/// 快捷键定义
class AppShortcuts {
  AppShortcuts._();

  /// 翻译 (Ctrl/Cmd + Enter)
  static final translate = SingleActivator(
    LogicalKeyboardKey.enter,
    control: !_isMac,
    meta: _isMac,
  );

  /// 清空 (Ctrl/Cmd + Backspace)
  static final clear = SingleActivator(
    LogicalKeyboardKey.backspace,
    control: !_isMac,
    meta: _isMac,
  );

  /// 复制 (Ctrl/Cmd + C)
  static final copy = SingleActivator(
    LogicalKeyboardKey.keyC,
    control: !_isMac,
    meta: _isMac,
  );

  /// 粘贴 (Ctrl/Cmd + V)
  static final paste = SingleActivator(
    LogicalKeyboardKey.keyV,
    control: !_isMac,
    meta: _isMac,
  );

  /// 保存 (Ctrl/Cmd + S)
  static final save = SingleActivator(
    LogicalKeyboardKey.keyS,
    control: !_isMac,
    meta: _isMac,
  );

  /// 交换语言 (Ctrl/Cmd + Shift + S)
  static final swapLanguages = SingleActivator(
    LogicalKeyboardKey.keyS,
    control: !_isMac,
    meta: _isMac,
    shift: true,
  );

  /// 收藏 (Ctrl/Cmd + D)
  static final favorite = SingleActivator(
    LogicalKeyboardKey.keyD,
    control: !_isMac,
    meta: _isMac,
  );

  /// 搜索 (Ctrl/Cmd + F)
  static final search = SingleActivator(
    LogicalKeyboardKey.keyF,
    control: !_isMac,
    meta: _isMac,
  );

  /// 设置 (Ctrl/Cmd + ,)
  static final settings = SingleActivator(
    LogicalKeyboardKey.comma,
    control: !_isMac,
    meta: _isMac,
  );

  /// 历史 (Ctrl/Cmd + H)
  static final history = SingleActivator(
    LogicalKeyboardKey.keyH,
    control: !_isMac,
    meta: _isMac,
  );

  /// 字典 (Ctrl/Cmd + Shift + D)
  static final dictionary = SingleActivator(
    LogicalKeyboardKey.keyD,
    control: !_isMac,
    meta: _isMac,
    shift: true,
  );

  /// 语音输入 (Ctrl/Cmd + M)
  static final voiceInput = SingleActivator(
    LogicalKeyboardKey.keyM,
    control: !_isMac,
    meta: _isMac,
  );

  /// 相机 (Ctrl/Cmd + Shift + C)
  static final camera = SingleActivator(
    LogicalKeyboardKey.keyC,
    control: !_isMac,
    meta: _isMac,
    shift: true,
  );

  /// 导出 (Ctrl/Cmd + E)
  static final export = SingleActivator(
    LogicalKeyboardKey.keyE,
    control: !_isMac,
    meta: _isMac,
  );

  /// 撤销 (Ctrl/Cmd + Z)
  static final undo = SingleActivator(
    LogicalKeyboardKey.keyZ,
    control: !_isMac,
    meta: _isMac,
  );

  /// 重做 (Ctrl/Cmd + Shift + Z / Ctrl/Cmd + Y)
  static final redo = SingleActivator(
    LogicalKeyboardKey.keyZ,
    control: !_isMac,
    meta: _isMac,
    shift: true,
  );

  /// 全选 (Ctrl/Cmd + A)
  static final selectAll = SingleActivator(
    LogicalKeyboardKey.keyA,
    control: !_isMac,
    meta: _isMac,
  );

  /// 帮助 (F1)
  static const help = SingleActivator(LogicalKeyboardKey.f1);

  /// 返回 (Escape)
  static const goBack = SingleActivator(LogicalKeyboardKey.escape);

  /// 导航到首页 (Alt + 1)
  static const navigateHome =
      SingleActivator(LogicalKeyboardKey.digit1, alt: true);

  /// 导航到历史 (Alt + 2)
  static const navigateHistory =
      SingleActivator(LogicalKeyboardKey.digit2, alt: true);

  /// 导航到字典 (Alt + 3)
  static const navigateDictionary =
      SingleActivator(LogicalKeyboardKey.digit3, alt: true);

  /// 导航到设置 (Alt + 4)
  static const navigateSettings =
      SingleActivator(LogicalKeyboardKey.digit4, alt: true);

  static bool get _isMac {
    // 简化检测，实际应使用 Platform
    return false;
  }

  /// 获取所有快捷键的描述
  static Map<String, ShortcutDescription> get descriptions => {
        'translate': ShortcutDescription(
          shortcut: translate,
          label: '翻译',
          description: '执行翻译',
          category: ShortcutCategory.translation,
        ),
        'clear': ShortcutDescription(
          shortcut: clear,
          label: '清空',
          description: '清空输入内容',
          category: ShortcutCategory.editing,
        ),
        'copy': ShortcutDescription(
          shortcut: copy,
          label: '复制',
          description: '复制选中内容',
          category: ShortcutCategory.editing,
        ),
        'paste': ShortcutDescription(
          shortcut: paste,
          label: '粘贴',
          description: '粘贴剪贴板内容',
          category: ShortcutCategory.editing,
        ),
        'save': ShortcutDescription(
          shortcut: save,
          label: '保存',
          description: '保存当前翻译',
          category: ShortcutCategory.translation,
        ),
        'swapLanguages': ShortcutDescription(
          shortcut: swapLanguages,
          label: '交换语言',
          description: '交换源语言和目标语言',
          category: ShortcutCategory.translation,
        ),
        'favorite': ShortcutDescription(
          shortcut: favorite,
          label: '收藏',
          description: '添加到收藏',
          category: ShortcutCategory.translation,
        ),
        'search': ShortcutDescription(
          shortcut: search,
          label: '搜索',
          description: '打开搜索',
          category: ShortcutCategory.navigation,
        ),
        'settings': ShortcutDescription(
          shortcut: settings,
          label: '设置',
          description: '打开设置',
          category: ShortcutCategory.navigation,
        ),
        'history': ShortcutDescription(
          shortcut: history,
          label: '历史',
          description: '查看历史记录',
          category: ShortcutCategory.navigation,
        ),
        'dictionary': ShortcutDescription(
          shortcut: dictionary,
          label: '字典',
          description: '打开字典',
          category: ShortcutCategory.navigation,
        ),
        'voiceInput': ShortcutDescription(
          shortcut: voiceInput,
          label: '语音输入',
          description: '开始语音输入',
          category: ShortcutCategory.input,
        ),
        'camera': ShortcutDescription(
          shortcut: camera,
          label: '相机',
          description: '打开相机识别',
          category: ShortcutCategory.input,
        ),
        'export': ShortcutDescription(
          shortcut: export,
          label: '导出',
          description: '导出数据',
          category: ShortcutCategory.data,
        ),
        'undo': ShortcutDescription(
          shortcut: undo,
          label: '撤销',
          description: '撤销上一步操作',
          category: ShortcutCategory.editing,
        ),
        'redo': ShortcutDescription(
          shortcut: redo,
          label: '重做',
          description: '重做已撤销的操作',
          category: ShortcutCategory.editing,
        ),
        'selectAll': ShortcutDescription(
          shortcut: selectAll,
          label: '全选',
          description: '选择所有内容',
          category: ShortcutCategory.editing,
        ),
        'help': const ShortcutDescription(
          shortcut: help,
          label: '帮助',
          description: '显示帮助',
          category: ShortcutCategory.general,
        ),
        'goBack': const ShortcutDescription(
          shortcut: goBack,
          label: '返回',
          description: '返回上一页',
          category: ShortcutCategory.navigation,
        ),
      };
}

/// 快捷键分类
enum ShortcutCategory {
  /// 翻译相关
  translation('翻译'),

  /// 编辑相关
  editing('编辑'),

  /// 导航相关
  navigation('导航'),

  /// 输入相关
  input('输入'),

  /// 数据相关
  data('数据'),

  /// 通用
  general('通用');

  final String displayName;
  const ShortcutCategory(this.displayName);
}

/// 快捷键描述
class ShortcutDescription {
  final ShortcutActivator shortcut;
  final String label;
  final String description;
  final ShortcutCategory category;

  const ShortcutDescription({
    required this.shortcut,
    required this.label,
    required this.description,
    required this.category,
  });

  /// 获取快捷键的显示文本
  String get shortcutText {
    if (shortcut is SingleActivator) {
      final activator = shortcut as SingleActivator;
      final parts = <String>[];

      if (activator.control) parts.add('Ctrl');
      if (activator.meta) parts.add('Cmd');
      if (activator.alt) parts.add('Alt');
      if (activator.shift) parts.add('Shift');

      parts.add(_keyLabel(activator.trigger));

      return parts.join(' + ');
    }
    return '';
  }

  String _keyLabel(LogicalKeyboardKey key) {
    // 特殊键名映射
    final keyMap = {
      LogicalKeyboardKey.enter: 'Enter',
      LogicalKeyboardKey.backspace: '⌫',
      LogicalKeyboardKey.escape: 'Esc',
      LogicalKeyboardKey.comma: ',',
      LogicalKeyboardKey.f1: 'F1',
    };

    if (keyMap.containsKey(key)) {
      return keyMap[key]!;
    }

    // 字母键
    if (key.keyLabel.length == 1) {
      return key.keyLabel.toUpperCase();
    }

    // 数字键
    if (key == LogicalKeyboardKey.digit1) return '1';
    if (key == LogicalKeyboardKey.digit2) return '2';
    if (key == LogicalKeyboardKey.digit3) return '3';
    if (key == LogicalKeyboardKey.digit4) return '4';

    return key.keyLabel;
  }
}
