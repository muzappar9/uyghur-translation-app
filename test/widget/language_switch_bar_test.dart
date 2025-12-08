/// LanguageSwitchBar Widget Tests
/// 测试语言切换栏组件
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/widgets/language_switch_bar.dart';
import 'test_helpers.dart';

void main() {
  group('LanguageSwitchBar Widget Tests', () {
    testWidgets('渲染基本 LanguageSwitchBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: LanguageSwitchBar(
              sourceLanguage: 'zh',
              targetLanguage: 'ug',
              onSwapTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LanguageSwitchBar), findsOneWidget);
    });

    testWidgets('LanguageSwitchBar 显示源语言和目标语言', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: LanguageSwitchBar(
              sourceLanguage: 'zh',
              targetLanguage: 'ug',
              onSwapTap: () {},
            ),
          ),
        ),
      );

      final bar = tester.widget<LanguageSwitchBar>(find.byType(LanguageSwitchBar));
      expect(bar.sourceLanguage, 'zh');
      expect(bar.targetLanguage, 'ug');
    });

    testWidgets('LanguageSwitchBar 包含交换按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: LanguageSwitchBar(
              sourceLanguage: 'zh',
              targetLanguage: 'ug',
              onSwapTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('LanguageSwitchBar 点击交换按钮触发回调', (WidgetTester tester) async {
      bool swapped = false;
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: LanguageSwitchBar(
              sourceLanguage: 'zh',
              targetLanguage: 'ug',
              onSwapTap: () => swapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();

      expect(swapped, true);
    });

    testWidgets('LanguageSwitchBar 在深色模式下正常渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        createDarkTestableWidget(
          child: Scaffold(
            body: LanguageSwitchBar(
              sourceLanguage: 'zh',
              targetLanguage: 'ug',
              onSwapTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LanguageSwitchBar), findsOneWidget);
    });
  });
}
