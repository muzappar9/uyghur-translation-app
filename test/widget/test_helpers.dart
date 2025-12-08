/// Widget Test Helpers
/// 提供 Widget 测试所需的辅助函数和包装器
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 创建一个简单的测试包装器
Widget createSimpleTestableWidget({
  required Widget child,
  List<Override>? overrides,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: child,
    ),
  );
}

/// 创建深色模式测试包装器
Widget createDarkTestableWidget({
  required Widget child,
  List<Override>? overrides,
}) {
  return createSimpleTestableWidget(
    child: child,
    overrides: overrides,
    themeMode: ThemeMode.dark,
  );
}

/// Mock Navigator Observer 用于跟踪导航
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
  }
}

/// 等待所有动画完成
Future<void> pumpAndSettle(WidgetTester tester, {Duration? duration}) async {
  await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
}

/// 查找包含特定文本的 Widget
Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains(text) == true,
  );
}

/// 执行点击并等待
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// 输入文本并等待
Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}
