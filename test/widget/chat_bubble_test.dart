/// ChatBubble Widget Tests
/// 测试对话气泡组件
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/widgets/chat_bubble.dart';
import 'test_helpers.dart';

void main() {
  group('ChatBubble Widget Tests', () {
    testWidgets('渲染基本 ChatBubble', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: ChatBubble(
              originalText: '你好',
              translatedText: 'Hello',
            ),
          ),
        ),
      );

      expect(find.byType(ChatBubble), findsOneWidget);
      expect(find.text('你好'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('ChatBubble 左对齐属性正确设置', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: ChatBubble(
              originalText: '你好',
              translatedText: 'Hello',
              isLeft: true,
            ),
          ),
        ),
      );

      final chatBubble = tester.widget<ChatBubble>(find.byType(ChatBubble));
      expect(chatBubble.isLeft, true);
    });

    testWidgets('ChatBubble 右对齐属性正确设置', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: ChatBubble(
              originalText: '你好',
              translatedText: 'Hello',
              isLeft: false,
            ),
          ),
        ),
      );

      final chatBubble = tester.widget<ChatBubble>(find.byType(ChatBubble));
      expect(chatBubble.isLeft, false);
    });

    testWidgets('ChatBubble 在深色模式下正常渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        createDarkTestableWidget(
          child: const Scaffold(
            body: ChatBubble(
              originalText: '你好',
              translatedText: 'Hello',
            ),
          ),
        ),
      );

      expect(find.byType(ChatBubble), findsOneWidget);
    });

    testWidgets('ChatBubble 空文本显示占位符', (WidgetTester tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: ChatBubble(
              originalText: '',
              translatedText: '',
            ),
          ),
        ),
      );

      expect(find.byType(ChatBubble), findsOneWidget);
    });

    testWidgets('ChatBubble 长文本不溢出', (WidgetTester tester) async {
      const longText = '这是一段非常非常长的文本，用来测试 ChatBubble 组件是否能正确处理长文本而不发生溢出';
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Scaffold(
            body: ChatBubble(
              originalText: longText,
              translatedText: longText,
            ),
          ),
        ),
      );

      expect(find.byType(ChatBubble), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
