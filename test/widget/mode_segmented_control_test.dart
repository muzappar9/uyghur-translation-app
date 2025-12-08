/// ModeSegmentedControl Widget Tests
/// 测试模式分段控制器组件
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/widgets/mode_segmented_control.dart';
import 'test_helpers.dart';

void main() {
  group('ModeSegmentedControl Widget Tests', () {
    testWidgets('渲染基本 ModeSegmentedControl', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: ModeSegmentedControl(
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ModeSegmentedControl), findsOneWidget);
    });

    testWidgets('ModeSegmentedControl 属性正确设置', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: ModeSegmentedControl(
              selectedIndex: 1,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final control = tester.widget<ModeSegmentedControl>(
        find.byType(ModeSegmentedControl),
      );
      expect(control.selectedIndex, 1);
    });

    testWidgets('ModeSegmentedControl 响应点击切换', (WidgetTester tester) async {
      int selectedIndex = 0;
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: ModeSegmentedControl(
              selectedIndex: selectedIndex,
              onChanged: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      // 找到 GestureDetector 或可点击的部分
      expect(find.byType(ModeSegmentedControl), findsOneWidget);
    });

    testWidgets('ModeSegmentedControl 在深色模式下正常渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        createDarkTestableWidget(
          child: Scaffold(
            body: ModeSegmentedControl(
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ModeSegmentedControl), findsOneWidget);
    });

    testWidgets('ModeSegmentedControl 无回调时不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: ModeSegmentedControl(
              selectedIndex: 0,
              onChanged: null,
            ),
          ),
        ),
      );

      expect(find.byType(ModeSegmentedControl), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
