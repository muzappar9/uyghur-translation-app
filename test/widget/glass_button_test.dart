/// GlassButton Widget Tests
/// 测试 GlassButton 组件的基本功能和样式
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/widgets/glass_button.dart';
import 'test_helpers.dart';

void main() {
  group('GlassButton Widget Tests', () {
    testWidgets('渲染基本 GlassButton', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: GlassButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(GlassButton), findsOneWidget);
    });

    testWidgets('GlassButton 显示图标', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: GlassButton(
              text: 'Icon Button',
              icon: Icons.translate,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.translate), findsOneWidget);
    });

    testWidgets('GlassButton 响应点击事件', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: GlassButton(
              text: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('GlassButton 禁用状态不响应点击', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: GlassButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassButton));
      await tester.pumpAndSettle();

      expect(pressed, false);
    });

    testWidgets('GlassButton 显示加载状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: GlassButton(
              text: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('GlassButton 在深色模式下正常渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        createDarkTestableWidget(
          child: Scaffold(
            body: GlassButton(
              text: 'Dark Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(GlassButton), findsOneWidget);
    });

    testWidgets('GlassButton 应用自定义模糊度', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: GlassButton(
              text: 'Custom Blur',
              blurSigma: 20.0,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<GlassButton>(find.byType(GlassButton));
      expect(button.blurSigma, 20.0);
    });
  });
}
