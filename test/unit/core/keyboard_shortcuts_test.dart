/// 键盘快捷键模块测试
///
/// 测试键盘快捷键功能
library;
import 'package:flutter/widgets.dart' show Intent;
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/core/keyboard/keyboard_shortcuts.dart';
import 'package:uyghur_translator/core/keyboard/keyboard_shortcuts_provider.dart';
import 'package:uyghur_translator/core/keyboard/shortcut_manager.dart' as app;

void main() {
  group('AppShortcuts', () {
    test('translate shortcut should use Ctrl+Enter', () {
      final activator = AppShortcuts.translate;
      expect(activator, isA<SingleActivator>());
      expect((activator).trigger, LogicalKeyboardKey.enter);
      expect(activator.control, true);
    });

    test('copy shortcut should use Ctrl+C', () {
      final activator = AppShortcuts.copy;
      expect(activator, isA<SingleActivator>());
      expect((activator).trigger, LogicalKeyboardKey.keyC);
      expect(activator.control, true);
    });

    test('swapLanguages should use Ctrl+Shift+S', () {
      final activator = AppShortcuts.swapLanguages;
      expect(activator, isA<SingleActivator>());
      expect((activator).shift, true);
    });

    test('help should use F1', () {
      const activator = AppShortcuts.help;
      expect((activator).trigger, LogicalKeyboardKey.f1);
    });

    test('goBack should use Escape', () {
      const activator = AppShortcuts.goBack;
      expect((activator).trigger, LogicalKeyboardKey.escape);
    });

    test('descriptions should contain all shortcuts', () {
      final descriptions = AppShortcuts.descriptions;
      
      expect(descriptions.containsKey('translate'), true);
      expect(descriptions.containsKey('copy'), true);
      expect(descriptions.containsKey('paste'), true);
      expect(descriptions.containsKey('save'), true);
      expect(descriptions.containsKey('search'), true);
    });
  });

  group('ShortcutCategory', () {
    test('should have display names', () {
      expect(ShortcutCategory.translation.displayName, '翻译');
      expect(ShortcutCategory.editing.displayName, '编辑');
      expect(ShortcutCategory.navigation.displayName, '导航');
    });
  });

  group('ShortcutDescription', () {
    test('shortcutText should format correctly', () {
      const desc = ShortcutDescription(
        shortcut: SingleActivator(
          LogicalKeyboardKey.keyS,
          control: true,
        ),
        label: '保存',
        description: '保存当前内容',
        category: ShortcutCategory.editing,
      );
      
      expect(desc.shortcutText, 'Ctrl + S');
    });

    test('shortcutText should include shift', () {
      const desc = ShortcutDescription(
        shortcut: SingleActivator(
          LogicalKeyboardKey.keyS,
          control: true,
          shift: true,
        ),
        label: '另存为',
        description: '另存为',
        category: ShortcutCategory.editing,
      );
      
      expect(desc.shortcutText, contains('Shift'));
    });

    test('shortcutText should handle special keys', () {
      const enterDesc = ShortcutDescription(
        shortcut: SingleActivator(LogicalKeyboardKey.enter),
        label: '确认',
        description: '确认',
        category: ShortcutCategory.general,
      );
      expect(enterDesc.shortcutText, 'Enter');

      const escDesc = ShortcutDescription(
        shortcut: SingleActivator(LogicalKeyboardKey.escape),
        label: '取消',
        description: '取消',
        category: ShortcutCategory.general,
      );
      expect(escDesc.shortcutText, 'Esc');
    });
  });

  group('AppIntent', () {
    test('TranslateIntent should be an Intent', () {
      const intent = TranslateIntent();
      expect(intent, isA<Intent>());
    });

    test('NavigateToIntent should store route', () {
      const intent = NavigateToIntent('/settings');
      expect(intent.route, '/settings');
    });
  });

  group('ShortcutManager', () {
    late app.ShortcutManager manager;

    setUp(() {
      manager = app.ShortcutManager();
    });

    test('createBindings should return all shortcuts', () {
      final bindings = manager.createBindings();
      
      expect(bindings.isNotEmpty, true);
      expect(bindings.values.any((i) => i is TranslateIntent), true);
      expect(bindings.values.any((i) => i is CopyIntent), true);
      expect(bindings.values.any((i) => i is GoBackIntent), true);
    });

    test('getGroupedDescriptions should group by category', () {
      final grouped = manager.getGroupedDescriptions();
      
      expect(grouped.containsKey(ShortcutCategory.translation), true);
      expect(grouped.containsKey(ShortcutCategory.editing), true);
      expect(grouped.containsKey(ShortcutCategory.navigation), true);
    });

    test('grouped descriptions should have items', () {
      final grouped = manager.getGroupedDescriptions();
      
      for (final category in grouped.keys) {
        expect(grouped[category]!.isNotEmpty, true);
      }
    });
  });

  group('CustomShortcuts', () {
    test('should have empty bindings by default', () {
      const shortcuts = CustomShortcuts();
      
      expect(shortcuts.customBindings.isEmpty, true);
      expect(shortcuts.enabled, true);
    });

    test('should serialize and deserialize', () {
      const shortcuts = CustomShortcuts(
        customBindings: {},
        enabled: false,
      );
      
      final json = shortcuts.toJson();
      final restored = CustomShortcuts.fromJson(json);
      
      expect(restored.enabled, false);
    });
  });

  group('CustomShortcutsProvider', () {
    // 这些测试需要 Hive 初始化，在单元测试中跳过
    // 应该在集成测试中测试这些功能
    test('providers should be defined', () {
      expect(customShortcutsProvider, isNotNull);
      expect(finalShortcutBindingsProvider, isNotNull);
    });

    test('finalShortcutBindingsProvider should be empty when disabled', () {
      final container = ProviderContainer(
        overrides: [
          customShortcutsProvider.overrideWith(() {
            return _DisabledCustomShortcutsNotifier();
          }),
        ],
      );
      
      final bindings = container.read(finalShortcutBindingsProvider);
      expect(bindings.isEmpty, true);
      
      container.dispose();
    });
  });

  group('shortcutManagerProvider', () {
    test('should provide ShortcutManager', () {
      final container = ProviderContainer();
      
      final manager = container.read(app.shortcutManagerProvider);
      expect(manager, isA<app.ShortcutManager>());
      
      container.dispose();
    });
  });
}

class _DisabledCustomShortcutsNotifier extends Notifier<CustomShortcuts>
    implements CustomShortcutsNotifier {
  @override
  CustomShortcuts build() {
    return const CustomShortcuts(enabled: false);
  }

  @override
  Future<void> setCustomShortcut(String action, ShortcutActivator activator) async {}

  @override
  Future<void> removeCustomShortcut(String action) async {}

  @override
  Future<void> setEnabled(bool enabled) async {}

  @override
  Future<void> reset() async {}
}
