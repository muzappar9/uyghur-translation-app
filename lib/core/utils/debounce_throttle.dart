import 'dart:async';
import 'package:flutter/foundation.dart';

/// ============================================
/// Stage 21: 防抖和节流工具
/// ============================================

/// 防抖器 - 延迟执行，每次调用重置计时器
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// 执行防抖操作
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// 取消待执行的操作
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 是否有待执行的操作
  bool get isPending => _timer?.isActive ?? false;

  /// 释放资源
  void dispose() {
    cancel();
  }
}

/// 带返回值的防抖器
class DebouncerWithValue<T> {
  final Duration delay;
  Timer? _timer;
  Completer<T>? _completer;

  DebouncerWithValue({this.delay = const Duration(milliseconds: 300)});

  /// 执行防抖操作并返回Future
  Future<T> run(Future<T> Function() action) {
    _timer?.cancel();
    _completer?.completeError(Exception('Debounce cancelled'));

    _completer = Completer<T>();
    final completer = _completer!;

    _timer = Timer(delay, () async {
      try {
        final result = await action();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _completer?.completeError(Exception('Debounce cancelled'));
    _completer = null;
  }

  void dispose() {
    cancel();
  }
}

/// 节流器 - 限制执行频率，在时间窗口内只执行一次
class Throttler {
  final Duration interval;
  DateTime? _lastExecutionTime;
  Timer? _trailingTimer;
  bool _isThrottled = false;

  Throttler({this.interval = const Duration(milliseconds: 300)});

  /// 执行节流操作（leading: 首次立即执行）
  void run(
    VoidCallback action, {
    bool leading = true,
    bool trailing = false,
  }) {
    final now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= interval) {
      if (leading) {
        _lastExecutionTime = now;
        action();
      }
      _isThrottled = true;

      if (trailing) {
        _trailingTimer?.cancel();
        _trailingTimer = Timer(interval, () {
          _isThrottled = false;
          action();
          _lastExecutionTime = DateTime.now();
        });
      } else {
        Timer(interval, () {
          _isThrottled = false;
        });
      }
    }
  }

  /// 是否正在节流中
  bool get isThrottled => _isThrottled;

  /// 重置节流状态
  void reset() {
    _lastExecutionTime = null;
    _isThrottled = false;
    _trailingTimer?.cancel();
    _trailingTimer = null;
  }

  void dispose() {
    _trailingTimer?.cancel();
    _trailingTimer = null;
  }
}

/// 带返回值的节流器
class ThrottlerWithValue<T> {
  final Duration interval;
  DateTime? _lastExecutionTime;
  T? _lastResult;
  bool _isThrottled = false;

  ThrottlerWithValue({this.interval = const Duration(milliseconds: 300)});

  /// 执行节流操作
  Future<T?> run(Future<T> Function() action) async {
    final now = DateTime.now();

    if (_lastExecutionTime == null ||
        now.difference(_lastExecutionTime!) >= interval) {
      _lastExecutionTime = now;
      _isThrottled = true;

      try {
        _lastResult = await action();
        return _lastResult;
      } finally {
        Timer(interval, () {
          _isThrottled = false;
        });
      }
    }

    return _lastResult;
  }

  bool get isThrottled => _isThrottled;

  void reset() {
    _lastExecutionTime = null;
    _lastResult = null;
    _isThrottled = false;
  }
}

/// 搜索防抖器（专用于搜索场景）
class SearchDebouncer {
  final Duration delay;
  final int minLength;
  Timer? _timer;
  String _lastQuery = '';

  SearchDebouncer({
    this.delay = const Duration(milliseconds: 400),
    this.minLength = 1,
  });

  /// 执行搜索
  void search(String query, void Function(String query) onSearch) {
    _timer?.cancel();

    // 如果查询相同，不执行
    if (query == _lastQuery) return;

    // 如果查询太短，清空结果
    if (query.length < minLength) {
      _lastQuery = query;
      onSearch('');
      return;
    }

    _timer = Timer(delay, () {
      _lastQuery = query;
      onSearch(query);
    });
  }

  /// 立即搜索（跳过防抖）
  void searchImmediately(String query, void Function(String query) onSearch) {
    _timer?.cancel();
    _lastQuery = query;

    if (query.length >= minLength) {
      onSearch(query);
    } else {
      onSearch('');
    }
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}

/// 批量操作聚合器
class BatchAggregator<T> {
  final Duration delay;
  final int maxBatchSize;
  final void Function(List<T> items) onBatch;

  Timer? _timer;
  final List<T> _pendingItems = [];

  BatchAggregator({
    this.delay = const Duration(milliseconds: 100),
    this.maxBatchSize = 50,
    required this.onBatch,
  });

  /// 添加项目
  void add(T item) {
    _pendingItems.add(item);

    if (_pendingItems.length >= maxBatchSize) {
      _flush();
      return;
    }

    _timer?.cancel();
    _timer = Timer(delay, _flush);
  }

  /// 添加多个项目
  void addAll(List<T> items) {
    _pendingItems.addAll(items);

    if (_pendingItems.length >= maxBatchSize) {
      _flush();
      return;
    }

    _timer?.cancel();
    _timer = Timer(delay, _flush);
  }

  void _flush() {
    if (_pendingItems.isEmpty) return;

    final items = List<T>.from(_pendingItems);
    _pendingItems.clear();
    _timer?.cancel();
    _timer = null;

    onBatch(items);
  }

  /// 立即执行所有待处理项
  void flush() {
    _flush();
  }

  /// 待处理项数量
  int get pendingCount => _pendingItems.length;

  void dispose() {
    _timer?.cancel();
    _pendingItems.clear();
  }
}

/// 重试包装器
class RetryWrapper {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool Function(dynamic error)? shouldRetry;

  RetryWrapper({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.shouldRetry,
  });

  /// 执行带重试的操作
  Future<T> execute<T>(
    Future<T> Function() operation, {
    void Function(int attempt, Duration delay)? onRetry,
    void Function(dynamic error)? onError,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        final canRetry = shouldRetry?.call(e) ?? true;

        if (!canRetry || attempts >= maxRetries) {
          onError?.call(e);
          rethrow;
        }

        onRetry?.call(attempts, delay);

        await Future.delayed(delay);

        // 计算下一次延迟（指数退避）
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier)
              .toInt()
              .clamp(0, maxDelay.inMilliseconds),
        );
      }
    }
  }
}

/// 函数缓存（Memoization）
class Memoize<K, V> {
  final Map<K, V> _cache = {};
  final V Function(K) _compute;
  final int? maxSize;

  Memoize(this._compute, {this.maxSize});

  V call(K key) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final value = _compute(key);

    // 如果有大小限制，移除最旧的
    if (maxSize != null && _cache.length >= maxSize!) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = value;
    return value;
  }

  void clear() => _cache.clear();
  void remove(K key) => _cache.remove(key);
  bool containsKey(K key) => _cache.containsKey(key);
  int get size => _cache.length;
}

/// 异步函数缓存
class AsyncMemoize<K, V> {
  final Map<K, V> _cache = {};
  final Map<K, Future<V>> _pending = {};
  final Future<V> Function(K) _compute;
  final int? maxSize;

  AsyncMemoize(this._compute, {this.maxSize});

  Future<V> call(K key) async {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    if (_pending.containsKey(key)) {
      return _pending[key]!;
    }

    final future = _compute(key);
    _pending[key] = future;

    try {
      final value = await future;

      if (maxSize != null && _cache.length >= maxSize!) {
        _cache.remove(_cache.keys.first);
      }

      _cache[key] = value;
      return value;
    } finally {
      _pending.remove(key);
    }
  }

  void clear() {
    _cache.clear();
    _pending.clear();
  }

  void remove(K key) => _cache.remove(key);
  bool containsKey(K key) => _cache.containsKey(key);
  int get size => _cache.length;
}
