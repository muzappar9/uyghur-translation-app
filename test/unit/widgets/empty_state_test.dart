import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/widgets/empty_state.dart';

void main() {
  group('EmptyStateConfig Tests', () {
    test('fromType noHistory 返回正确配置', () {
      final config = EmptyStateConfig.fromType(EmptyStateType.noHistory);

      expect(config.icon, Icons.history);
      expect(config.title, '暂无翻译历史');
      expect(config.description, '您的翻译历史将显示在这里');
      expect(config.actionText, '开始翻译');
    });

    test('fromType noFavorites 返回正确配置', () {
      final config = EmptyStateConfig.fromType(EmptyStateType.noFavorites);

      expect(config.icon, Icons.favorite_outline);
      expect(config.title, '暂无收藏');
      expect(config.description, '收藏的翻译将显示在这里');
      expect(config.actionText, '去翻译');
      expect(config.iconColor, Colors.red.shade300);
    });

    test('fromType noSearchResults 返回正确配置', () {
      final config = EmptyStateConfig.fromType(EmptyStateType.noSearchResults);

      expect(config.icon, Icons.search_off);
      expect(config.title, '无搜索结果');
      expect(config.description, '尝试使用其他关键词搜索');
      expect(config.actionText, isNull);
    });

    test('fromType noConnection 返回正确配置', () {
      final config = EmptyStateConfig.fromType(EmptyStateType.noConnection);

      expect(config.icon, Icons.wifi_off);
      expect(config.title, '无网络连接');
      expect(config.description, '请检查您的网络设置');
      expect(config.actionText, '重试');
      expect(config.iconColor, Colors.orange);
    });

    test('fromType loadError 返回正确配置', () {
      final config = EmptyStateConfig.fromType(EmptyStateType.loadError);

      expect(config.icon, Icons.error_outline);
      expect(config.title, '加载失败');
      expect(config.description, '数据加载出错，请稍后重试');
      expect(config.actionText, '重新加载');
      expect(config.iconColor, Colors.red);
    });

    test('fromType generic 返回正确配置', () {
      final config = EmptyStateConfig.fromType(EmptyStateType.generic);

      expect(config.icon, Icons.inbox_outlined);
      expect(config.title, '暂无数据');
      expect(config.description, '这里还没有任何内容');
      expect(config.actionText, isNull);
    });

    test('fromType 支持自定义文本', () {
      final config = EmptyStateConfig.fromType(
        EmptyStateType.noHistory,
        customTitle: '自定义标题',
        customDescription: '自定义描述',
        customActionText: '自定义操作',
      );

      expect(config.title, '自定义标题');
      expect(config.description, '自定义描述');
      expect(config.actionText, '自定义操作');
    });
  });

  group('EmptyStateWidget Tests', () {
    Widget buildTestWidget({
      EmptyStateType type = EmptyStateType.generic,
      EmptyStateConfig? config,
      VoidCallback? onAction,
      bool compact = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            type: type,
            config: config,
            onAction: onAction,
            compact: compact,
          ),
        ),
      );
    }

    testWidgets('显示正确的图标和文本', (tester) async {
      await tester.pumpWidget(buildTestWidget(type: EmptyStateType.noHistory));

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('暂无翻译历史'), findsOneWidget);
      expect(find.text('您的翻译历史将显示在这里'), findsOneWidget);
    });

    testWidgets('有 onAction 时显示操作按钮', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildTestWidget(
        type: EmptyStateType.noHistory,
        onAction: () => tapped = true,
      ));

      expect(find.text('开始翻译'), findsOneWidget);

      await tester.tap(find.text('开始翻译'));
      expect(tapped, isTrue);
    });

    testWidgets('无 actionText 时不显示按钮', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        type: EmptyStateType.noSearchResults,
        onAction: () {},
      ));

      // noSearchResults 没有 actionText
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('紧凑模式使用较小间距', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        type: EmptyStateType.generic,
        compact: true,
      ));

      // 组件应该正常渲染
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('自定义配置优先级高于 type', (tester) async {
      const customConfig = EmptyStateConfig(
        icon: Icons.star,
        title: '自定义标题',
        description: '自定义描述',
      );

      await tester.pumpWidget(buildTestWidget(
        type: EmptyStateType.noHistory,
        config: customConfig,
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('自定义标题'), findsOneWidget);
      expect(find.text('自定义描述'), findsOneWidget);
      // noHistory 的默认图标不应该出现
      expect(find.byIcon(Icons.history), findsNothing);
    });
  });

  group('EmptyStateWidget 命名构造函数 Tests', () {
    testWidgets('noHistory 构造函数正常工作', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget.noHistory(onAction: () {}),
        ),
      ));

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('暂无翻译历史'), findsOneWidget);
    });

    testWidgets('noFavorites 构造函数正常工作', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget.noFavorites(onAction: () {}),
        ),
      ));

      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      expect(find.text('暂无收藏'), findsOneWidget);
    });

    testWidgets('noSearchResults 构造函数正常工作', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget.noSearchResults(),
        ),
      ));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('无搜索结果'), findsOneWidget);
    });

    testWidgets('noConnection 构造函数正常工作', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget.noConnection(onAction: () {}),
        ),
      ));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('无网络连接'), findsOneWidget);
    });

    testWidgets('loadError 构造函数正常工作', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget.loadError(onAction: () {}),
        ),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('加载失败'), findsOneWidget);
    });

    testWidgets('custom 构造函数正常工作', (tester) async {
      const customConfig = EmptyStateConfig(
        icon: Icons.rocket_launch,
        title: '准备发射',
        description: '即将开始',
      );

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget.custom(config: customConfig),
        ),
      ));

      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
      expect(find.text('准备发射'), findsOneWidget);
    });
  });

  group('AnimatedEmptyStateWidget Tests', () {
    testWidgets('动画正常播放', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedEmptyStateWidget(
            type: EmptyStateType.noHistory,
            onAction: () {},
          ),
        ),
      ));

      // 动画开始时
      await tester.pump();

      // 动画进行中
      await tester.pump(const Duration(milliseconds: 300));

      // 动画完成
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
    });
  });

  group('EmptyStateWrapper Tests', () {
    testWidgets('数据为空时显示空状态', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWrapper<List<String>>(
            data: const [],
            emptyType: EmptyStateType.noHistory,
            builder: (data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) => Text(data[i]),
            ),
            animated: false,
          ),
        ),
      ));

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('暂无翻译历史'), findsOneWidget);
    });

    testWidgets('数据存在时显示内容', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWrapper<List<String>>(
            data: const ['Item 1', 'Item 2'],
            emptyType: EmptyStateType.noHistory,
            builder: (data) => Column(
              children: data.map((e) => Text(e)).toList(),
            ),
            animated: false,
          ),
        ),
      ));

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);
    });

    testWidgets('null 数据显示空状态', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWrapper<List<String>>(
            data: null,
            emptyType: EmptyStateType.generic,
            builder: (data) => Text(data.toString()),
            animated: false,
          ),
        ),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('自定义 isEmpty 函数', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWrapper<int>(
            data: 0,
            emptyType: EmptyStateType.generic,
            isEmpty: (data) => data == 0,
            builder: (data) => Text('Value: $data'),
            animated: false,
          ),
        ),
      ));

      // 0 被认为是空
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('Map 为空时显示空状态', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWrapper<Map<String, String>>(
            data: const {},
            emptyType: EmptyStateType.generic,
            builder: (data) => Text(data.toString()),
            animated: false,
          ),
        ),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('String 为空时显示空状态', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWrapper<String>(
            data: '',
            emptyType: EmptyStateType.generic,
            builder: (data) => Text(data),
            animated: false,
          ),
        ),
      ));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });

  group('AsyncEmptyStateWrapper Tests', () {
    testWidgets('加载中显示加载指示器', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AsyncEmptyStateWrapper<List<String>>(
            snapshot: const AsyncSnapshot.waiting(),
            builder: (data) => Text(data.toString()),
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('自定义加载组件', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AsyncEmptyStateWrapper<List<String>>(
            snapshot: const AsyncSnapshot.waiting(),
            loading: const Text('自定义加载中...'),
            builder: (data) => Text(data.toString()),
          ),
        ),
      ));

      expect(find.text('自定义加载中...'), findsOneWidget);
    });

    testWidgets('错误状态显示错误信息', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AsyncEmptyStateWrapper<List<String>>(
            snapshot: AsyncSnapshot.withError(
              ConnectionState.done,
              Exception('测试错误'),
            ),
            builder: (data) => Text(data.toString()),
            onErrorRetry: () {},
          ),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('加载失败'), findsOneWidget);
    });

    testWidgets('数据为空时显示空状态', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AsyncEmptyStateWrapper<List<String>>(
            snapshot: const AsyncSnapshot.withData(ConnectionState.done, []),
            emptyType: EmptyStateType.noHistory,
            builder: (data) => Text(data.toString()),
          ),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('数据存在时显示内容', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AsyncEmptyStateWrapper<List<String>>(
            snapshot: const AsyncSnapshot.withData(
              ConnectionState.done,
              ['Item 1'],
            ),
            builder: (data) => Text(data.first),
          ),
        ),
      ));

      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
