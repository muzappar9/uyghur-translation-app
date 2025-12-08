/// GlassCard Widget Tests
/// 测试 GlassCard 组件的基本功能和样式
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/widgets/glass_card.dart';
import 'test_helpers.dart';

void main() {
  group('GlassCard Widget Tests', () {
    testWidgets('渲染基本 GlassCard', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: GlassCard(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('GlassCard 应用自定义模糊度', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: GlassCard(
              blurSigma: 20.0,
              child: Text('Blur Test'),
            ),
          ),
        ),
      );

      final glassCard = tester.widget<GlassCard>(find.byType(GlassCard));
      expect(glassCard.blurSigma, 20.0);
    });

    testWidgets('GlassCard 应用自定义圆角', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: GlassCard(
              borderRadius: 32.0,
              child: Text('Radius Test'),
            ),
          ),
        ),
      );

      final glassCard = tester.widget<GlassCard>(find.byType(GlassCard));
      expect(glassCard.borderRadius, 32.0);
    });

    testWidgets('GlassCard 应用自定义内边距', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: GlassCard(
              padding: EdgeInsets.all(24),
              child: Text('Padding Test'),
            ),
          ),
        ),
      );

      final glassCard = tester.widget<GlassCard>(find.byType(GlassCard));
      expect(glassCard.padding, const EdgeInsets.all(24));
    });

    testWidgets('GlassCard 在深色模式下正常渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        createDarkTestableWidget(
          child: const Scaffold(
            body: GlassCard(
              child: Text('Dark Mode Test'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
      expect(find.text('Dark Mode Test'), findsOneWidget);
    });

    testWidgets('GlassCard 应用自定义背景颜色', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Scaffold(
            body: GlassCard(
              backgroundColor: Colors.blue.withValues(alpha: 0.5),
              child: const Text('Color Test'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassCard), findsOneWidget);
    });
  });
}
