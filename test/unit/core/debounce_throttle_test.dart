/// Stage 21: 防抖节流工具测试
///
/// 测试 Debouncer, Throttler 和其他工具类
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:uyghur_translator/core/utils/debounce_throttle.dart';

void main() {
  group('Debouncer 单元测试', () {
    test('应该延迟执行操作', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int counter = 0;

      debouncer.run(() => counter++);

      // 立即检查，应该还没执行
      expect(counter, equals(0));

      // 等待足够时间
      await Future.delayed(const Duration(milliseconds: 100));

      expect(counter, equals(1));
      debouncer.dispose();
    });

    test('快速连续调用只应执行一次', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int counter = 0;

      // 快速调用三次
      debouncer.run(() => counter++);
      debouncer.run(() => counter++);
      debouncer.run(() => counter++);

      await Future.delayed(const Duration(milliseconds: 100));

      // 只应该执行最后一次
      expect(counter, equals(1));
      debouncer.dispose();
    });

    test('cancel 应取消待执行的操作', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      int counter = 0;

      debouncer.run(() => counter++);
      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(counter, equals(0));
      debouncer.dispose();
    });

    test('isPending 应正确反映状态', () {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));

      expect(debouncer.isPending, isFalse);

      debouncer.run(() {});
      expect(debouncer.isPending, isTrue);

      debouncer.cancel();
      expect(debouncer.isPending, isFalse);

      debouncer.dispose();
    });
  });

  group('Throttler 单元测试', () {
    test('首次调用应立即执行 (leading=true)', () {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));
      int counter = 0;

      throttler.run(() => counter++, leading: true);

      expect(counter, equals(1));
      throttler.dispose();
    });

    test('在节流间隔内的调用应被忽略', () async {
      final throttler = Throttler(interval: const Duration(milliseconds: 100));
      int counter = 0;

      throttler.run(() => counter++);
      throttler.run(() => counter++);
      throttler.run(() => counter++);

      // 在节流间隔内，应该只执行第一次
      expect(counter, equals(1));
      throttler.dispose();
    });

    test('节流间隔后应允许新的调用', () async {
      final throttler = Throttler(interval: const Duration(milliseconds: 50));
      int counter = 0;

      throttler.run(() => counter++);
      expect(counter, equals(1));

      // 等待节流间隔结束
      await Future.delayed(const Duration(milliseconds: 100));

      throttler.run(() => counter++);
      expect(counter, equals(2));

      throttler.dispose();
    });
  });

  group('SearchDebouncer 单元测试', () {
    test('应该防抖搜索请求', () async {
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 50),
        minLength: 1, // 设置为 1 以便所有查询都满足最小长度
      );

      final results = <String>[];

      // 快速输入
      debouncer.search('h', (q) => results.add(q));
      debouncer.search('he', (q) => results.add(q));
      debouncer.search('hel', (q) => results.add(q));
      debouncer.search('hell', (q) => results.add(q));
      debouncer.search('hello', (q) => results.add(q));

      await Future.delayed(const Duration(milliseconds: 100));

      // 只应该有最后一个查询 (防抖效果)
      expect(results.length, equals(1));
      expect(results.first, equals('hello'));

      debouncer.dispose();
    });

    test('短于 minLength 的查询应触发空结果', () async {
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 50),
        minLength: 3,
      );

      final results = <String>[];

      debouncer.search('ab', (q) => results.add(q));

      // 短查询应立即返回空字符串
      expect(results.length, equals(1));
      expect(results.first, equals(''));

      debouncer.dispose();
    });

    test('searchImmediately 应跳过防抖', () {
      final debouncer = SearchDebouncer(
        delay: const Duration(milliseconds: 100),
        minLength: 2,
      );

      final results = <String>[];

      debouncer.searchImmediately('hello', (q) => results.add(q));

      // 应该立即执行
      expect(results.length, equals(1));
      expect(results.first, equals('hello'));

      debouncer.dispose();
    });
  });

  group('BatchAggregator 单元测试', () {
    test('应该在延迟后批量处理', () async {
      final batches = <List<int>>[];
      final aggregator = BatchAggregator<int>(
        delay: const Duration(milliseconds: 50),
        maxBatchSize: 10,
        onBatch: (items) => batches.add(items),
      );

      aggregator.add(1);
      aggregator.add(2);
      aggregator.add(3);

      expect(batches.length, equals(0));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(batches.length, equals(1));
      expect(batches.first, equals([1, 2, 3]));

      aggregator.dispose();
    });

    test('达到最大批次大小应立即触发', () {
      final batches = <List<int>>[];
      final aggregator = BatchAggregator<int>(
        delay: const Duration(milliseconds: 100),
        maxBatchSize: 3,
        onBatch: (items) => batches.add(items),
      );

      aggregator.add(1);
      aggregator.add(2);
      aggregator.add(3);

      // 达到最大大小，应该立即触发
      expect(batches.length, equals(1));
      expect(batches.first, equals([1, 2, 3]));

      aggregator.dispose();
    });

    test('flush 应立即处理待处理项', () {
      final batches = <List<int>>[];
      final aggregator = BatchAggregator<int>(
        delay: const Duration(milliseconds: 100),
        maxBatchSize: 10,
        onBatch: (items) => batches.add(items),
      );

      aggregator.add(1);
      aggregator.add(2);

      expect(batches.length, equals(0));

      aggregator.flush();

      expect(batches.length, equals(1));
      expect(batches.first, equals([1, 2]));

      aggregator.dispose();
    });
  });

  group('RetryWrapper 单元测试', () {
    test('成功操作不应重试', () async {
      final retrier = RetryWrapper(maxRetries: 3);
      int attempts = 0;

      final result = await retrier.execute(() async {
        attempts++;
        return 'success';
      });

      expect(result, equals('success'));
      expect(attempts, equals(1));
    });

    test('失败操作应重试指定次数', () async {
      final retrier = RetryWrapper(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
      );
      int attempts = 0;

      try {
        await retrier.execute(() async {
          attempts++;
          throw Exception('Failed');
        });
      } catch (_) {}

      expect(attempts, equals(3)); // 最多重试 3 次
    });

    test('重试中成功应停止重试', () async {
      final retrier = RetryWrapper(
        maxRetries: 5,
        initialDelay: const Duration(milliseconds: 10),
      );
      int attempts = 0;

      final result = await retrier.execute(() async {
        attempts++;
        if (attempts < 3) throw Exception('Not yet');
        return 'success';
      });

      expect(result, equals('success'));
      expect(attempts, equals(3)); // 第三次成功
    });

    test('onRetry 回调应被调用', () async {
      final retrier = RetryWrapper(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
      );

      final retryAttempts = <int>[];

      try {
        await retrier.execute(
          () async => throw Exception('Failed'),
          onRetry: (attempt, delay) => retryAttempts.add(attempt),
        );
      } catch (_) {}

      expect(retryAttempts.length, equals(2)); // 第一次失败后重试 2 次
    });
  });

  group('Memoize 单元测试', () {
    test('应该缓存函数结果', () {
      int computeCount = 0;
      final memoize = Memoize<int, int>((int x) {
        computeCount++;
        return x * 2;
      });

      expect(memoize(5), equals(10));
      expect(computeCount, equals(1));

      // 相同参数应使用缓存
      expect(memoize(5), equals(10));
      expect(computeCount, equals(1));

      // 不同参数应重新计算
      expect(memoize(10), equals(20));
      expect(computeCount, equals(2));
    });

    test('clear 应清空缓存', () {
      int computeCount = 0;
      final memoize = Memoize<int, int>((int x) {
        computeCount++;
        return x * 2;
      });

      memoize(5);
      memoize.clear();
      memoize(5);

      expect(computeCount, equals(2));
    });

    test('应该遵守 maxSize 限制', () {
      final memoize = Memoize<int, int>(
        (int x) => x * 2,
        maxSize: 2,
      );

      memoize(1);
      memoize(2);
      memoize(3); // 应该淘汰第一个

      expect(memoize.containsKey(1), isFalse);
      expect(memoize.containsKey(2), isTrue);
      expect(memoize.containsKey(3), isTrue);
    });
  });

  group('AsyncMemoize 单元测试', () {
    test('应该缓存异步函数结果', () async {
      int computeCount = 0;
      final asyncMemoize = AsyncMemoize<int, int>((int x) async {
        computeCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return x * 2;
      });

      expect(await asyncMemoize(5), equals(10));
      expect(computeCount, equals(1));

      // 相同参数应使用缓存
      expect(await asyncMemoize(5), equals(10));
      expect(computeCount, equals(1));
    });

    test('并发请求应共享同一个 Future', () async {
      int computeCount = 0;
      final asyncMemoize = AsyncMemoize<int, int>((int x) async {
        computeCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return x * 2;
      });

      // 并发发起多个相同请求
      final futures = [
        asyncMemoize(5),
        asyncMemoize(5),
        asyncMemoize(5),
      ];

      final results = await Future.wait(futures);

      expect(results, equals([10, 10, 10]));
      expect(computeCount, equals(1)); // 只计算一次
    });
  });
}
