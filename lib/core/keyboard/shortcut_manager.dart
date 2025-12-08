/// 快捷键管理器
///
/// 管理应用中的快捷键绑定
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'keyboard_shortcuts.dart';

/// 快捷键管理器 Provider
final shortcutManagerProvider = Provider<ShortcutManager>((ref) {
  return ShortcutManager();
});

/// 快捷键管理器
class ShortcutManager {
  /// 创建应用快捷键绑定
  Map<ShortcutActivator, Intent> createBindings() {
    return {
      AppShortcuts.translate: const TranslateIntent(),
      AppShortcuts.clear: const ClearIntent(),
      AppShortcuts.copy: const CopyIntent(),
      AppShortcuts.paste: const PasteIntent(),
      AppShortcuts.save: const SaveIntent(),
      AppShortcuts.swapLanguages: const SwapLanguagesIntent(),
      AppShortcuts.favorite: const FavoriteIntent(),
      AppShortcuts.search: const SearchIntent(),
      AppShortcuts.settings: const SettingsIntent(),
      AppShortcuts.history: const HistoryIntent(),
      AppShortcuts.dictionary: const DictionaryIntent(),
      AppShortcuts.voiceInput: const VoiceInputIntent(),
      AppShortcuts.camera: const CameraIntent(),
      AppShortcuts.export: const ExportIntent(),
      AppShortcuts.undo: const UndoIntent(),
      AppShortcuts.redo: const RedoIntent(),
      AppShortcuts.selectAll: const SelectAllIntent(),
      AppShortcuts.help: const HelpIntent(),
      AppShortcuts.goBack: const GoBackIntent(),
      AppShortcuts.navigateHome: const NavigateToIntent('/'),
      AppShortcuts.navigateHistory: const NavigateToIntent('/history'),
      AppShortcuts.navigateDictionary: const NavigateToIntent('/dictionary'),
      AppShortcuts.navigateSettings: const NavigateToIntent('/settings'),
    };
  }

  /// 获取按类别分组的快捷键
  Map<ShortcutCategory, List<ShortcutDescription>> getGroupedDescriptions() {
    final grouped = <ShortcutCategory, List<ShortcutDescription>>{};

    for (final entry in AppShortcuts.descriptions.entries) {
      final category = entry.value.category;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(entry.value);
    }

    return grouped;
  }
}

/// 应用快捷键包装器
class AppShortcutsWrapper extends ConsumerWidget {
  final Widget child;
  final Map<Type, Action<Intent>>? actions;

  const AppShortcutsWrapper({
    super.key,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(shortcutManagerProvider);

    return Shortcuts(
      shortcuts: manager.createBindings(),
      child: Actions(
        actions: actions ?? _defaultActions(context, ref),
        child: child,
      ),
    );
  }

  Map<Type, Action<Intent>> _defaultActions(
      BuildContext context, WidgetRef ref) {
    return {
      GoBackIntent: CallbackAction<GoBackIntent>(
        onInvoke: (_) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          return null;
        },
      ),
      HelpIntent: CallbackAction<HelpIntent>(
        onInvoke: (_) {
          _showHelpDialog(context, ref);
          return null;
        },
      ),
    };
  }

  void _showHelpDialog(BuildContext context, WidgetRef ref) {
    final manager = ref.read(shortcutManagerProvider);
    final grouped = manager.getGroupedDescriptions();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('键盘快捷键'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      entry.key.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...entry.value.map((desc) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(desc.label),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                desc.shortcutText,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 翻译页面的快捷键 Actions
class TranslationShortcutActions extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTranslate;
  final VoidCallback? onClear;
  final VoidCallback? onSwapLanguages;
  final VoidCallback? onSave;
  final VoidCallback? onFavorite;
  final VoidCallback? onCopy;
  final VoidCallback? onVoiceInput;

  const TranslationShortcutActions({
    super.key,
    required this.child,
    this.onTranslate,
    this.onClear,
    this.onSwapLanguages,
    this.onSave,
    this.onFavorite,
    this.onCopy,
    this.onVoiceInput,
  });

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        TranslateIntent: CallbackAction<TranslateIntent>(
          onInvoke: (_) {
            onTranslate?.call();
            return null;
          },
        ),
        ClearIntent: CallbackAction<ClearIntent>(
          onInvoke: (_) {
            onClear?.call();
            return null;
          },
        ),
        SwapLanguagesIntent: CallbackAction<SwapLanguagesIntent>(
          onInvoke: (_) {
            onSwapLanguages?.call();
            return null;
          },
        ),
        SaveIntent: CallbackAction<SaveIntent>(
          onInvoke: (_) {
            onSave?.call();
            return null;
          },
        ),
        FavoriteIntent: CallbackAction<FavoriteIntent>(
          onInvoke: (_) {
            onFavorite?.call();
            return null;
          },
        ),
        CopyIntent: CallbackAction<CopyIntent>(
          onInvoke: (_) {
            onCopy?.call();
            return null;
          },
        ),
        VoiceInputIntent: CallbackAction<VoiceInputIntent>(
          onInvoke: (_) {
            onVoiceInput?.call();
            return null;
          },
        ),
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}

/// 历史页面的快捷键 Actions
class HistoryShortcutActions extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSearch;
  final VoidCallback? onExport;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDelete;

  const HistoryShortcutActions({
    super.key,
    required this.child,
    this.onSearch,
    this.onExport,
    this.onSelectAll,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        SearchIntent: CallbackAction<SearchIntent>(
          onInvoke: (_) {
            onSearch?.call();
            return null;
          },
        ),
        ExportIntent: CallbackAction<ExportIntent>(
          onInvoke: (_) {
            onExport?.call();
            return null;
          },
        ),
        SelectAllIntent: CallbackAction<SelectAllIntent>(
          onInvoke: (_) {
            onSelectAll?.call();
            return null;
          },
        ),
        ClearIntent: CallbackAction<ClearIntent>(
          onInvoke: (_) {
            onDelete?.call();
            return null;
          },
        ),
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}

/// 快捷键提示组件
class ShortcutHint extends StatelessWidget {
  final ShortcutActivator shortcut;
  final String? label;

  const ShortcutHint({
    super.key,
    required this.shortcut,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(100),
        ),
      ),
      child: Text(
        _getShortcutText(),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _getShortcutText() {
    if (shortcut is SingleActivator) {
      final activator = shortcut as SingleActivator;
      final parts = <String>[];

      if (activator.control) parts.add('Ctrl');
      if (activator.meta) parts.add('⌘');
      if (activator.alt) parts.add('Alt');
      if (activator.shift) parts.add('⇧');

      parts.add(_keyLabel(activator.trigger));

      return parts.join('+');
    }
    return label ?? '';
  }

  String _keyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.enter) return '↵';
    if (key == LogicalKeyboardKey.backspace) return '⌫';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key.keyLabel.length == 1) return key.keyLabel.toUpperCase();
    return key.keyLabel;
  }
}
