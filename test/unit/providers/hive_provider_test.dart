import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uyghur_translator/shared/providers/hive_provider.dart';

void main() {
  group('HiveProvider Tests', () {
    late ProviderContainer container;

    setUpAll(() {
      // Hive 初始化不需要实际的盒子
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // 跳过需要平台插件的测试（在 CI 或纯 Dart 测试环境中）
    test('hiveInitProvider 初始化成功', () async {
      // hiveInitProvider returns void, so just verify no exception is thrown
      // 注意：此测试需要真实设备或配置了 path_provider mock
      await expectLater(
        container.read(hiveInitProvider.future),
        completes,
      );
    }, skip: 'Requires path_provider platform plugin');

    test('userPreferencesBoxProvider 返回有效的Box', () async {
      final box = await container.read(userPreferencesBoxProvider.future);
      expect(box, isNotNull);
      expect(box, isA<Box>());
    }, skip: 'Requires path_provider platform plugin');

    test('appConfigBoxProvider 返回有效的Box', () async {
      final box = await container.read(appConfigBoxProvider.future);
      expect(box, isNotNull);
      expect(box, isA<Box>());
    }, skip: 'Requires path_provider platform plugin');

    test('cacheBoxProvider 返回有效的Box', () async {
      final box = await container.read(cacheBoxProvider.future);
      expect(box, isNotNull);
      expect(box, isA<Box>());
    }, skip: 'Requires path_provider platform plugin');

    test('多个Box可以独立访问', () async {
      final prefs = await container.read(userPreferencesBoxProvider.future);
      final config = await container.read(appConfigBoxProvider.future);
      final cache = await container.read(cacheBoxProvider.future);

      expect(prefs, isNotNull);
      expect(config, isNotNull);
      expect(cache, isNotNull);
    }, skip: 'Requires path_provider platform plugin');

    test('hiveInitProvider 返回Future<void>', () async {
      final future = container.read(hiveInitProvider);
      expect(future, isA<AsyncValue>());
    });
  });
}
