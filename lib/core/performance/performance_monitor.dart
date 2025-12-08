import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// ============================================
/// Stage 21: 性能监控系统
/// ============================================

/// 性能指标类型
enum MetricType {
  frameTime,
  buildTime,
  layoutTime,
  paintTime,
  memoryUsage,
  networkLatency,
  cacheHitRate,
  custom,
}

/// 性能指标数据点
class MetricDataPoint {
  final MetricType type;
  final double value;
  final DateTime timestamp;
  final String? label;
  final Map<String, dynamic>? metadata;

  MetricDataPoint({
    required this.type,
    required this.value,
    DateTime? timestamp,
    this.label,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 性能统计
class MetricStats {
  final MetricType type;
  final List<double> values;

  MetricStats(this.type, this.values);

  double get min => values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b);
  double get max => values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
  double get avg =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  double get p50 => _percentile(50);
  double get p90 => _percentile(90);
  double get p99 => _percentile(99);

  double _percentile(int p) {
    if (values.isEmpty) return 0;
    final sorted = List<double>.from(values)..sort();
    final index = ((p / 100) * sorted.length).floor();
    return sorted[index.clamp(0, sorted.length - 1)];
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'count': values.length,
        'min': min.toStringAsFixed(2),
        'max': max.toStringAsFixed(2),
        'avg': avg.toStringAsFixed(2),
        'p50': p50.toStringAsFixed(2),
        'p90': p90.toStringAsFixed(2),
        'p99': p99.toStringAsFixed(2),
      };
}

/// 性能监控器
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<MetricType, List<MetricDataPoint>> _metrics = {};
  final Map<String, Stopwatch> _timers = {};
  final int _maxDataPoints = 1000;

  bool _isEnabled = true;
  bool _isFrameMonitoringEnabled = false;

  /// 启用/禁用监控
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// 记录指标
  void record(MetricType type, double value,
      {String? label, Map<String, dynamic>? metadata}) {
    if (!_isEnabled) return;

    _metrics.putIfAbsent(type, () => []);

    _metrics[type]!.add(MetricDataPoint(
      type: type,
      value: value,
      label: label,
      metadata: metadata,
    ));

    // 限制数据点数量
    if (_metrics[type]!.length > _maxDataPoints) {
      _metrics[type]!.removeAt(0);
    }
  }

  /// 开始计时
  void startTimer(String name) {
    if (!_isEnabled) return;
    _timers[name] = Stopwatch()..start();
  }

  /// 结束计时并记录
  double endTimer(String name, {MetricType type = MetricType.custom}) {
    if (!_isEnabled) return 0;

    final stopwatch = _timers.remove(name);
    if (stopwatch == null) return 0;

    stopwatch.stop();
    final elapsed = stopwatch.elapsedMicroseconds / 1000; // 毫秒
    record(type, elapsed, label: name);
    return elapsed;
  }

  /// 测量异步操作
  Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation, {
    MetricType type = MetricType.custom,
  }) async {
    if (!_isEnabled) return operation();

    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      record(type, stopwatch.elapsedMicroseconds / 1000, label: name);
    }
  }

  /// 测量同步操作
  T measureSync<T>(
    String name,
    T Function() operation, {
    MetricType type = MetricType.custom,
  }) {
    if (!_isEnabled) return operation();

    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      record(type, stopwatch.elapsedMicroseconds / 1000, label: name);
    }
  }

  /// 启动帧监控
  void startFrameMonitoring() {
    if (_isFrameMonitoringEnabled) return;
    _isFrameMonitoringEnabled = true;

    SchedulerBinding.instance.addTimingsCallback(_handleTimings);
  }

  /// 停止帧监控
  void stopFrameMonitoring() {
    if (!_isFrameMonitoringEnabled) return;
    _isFrameMonitoringEnabled = false;

    SchedulerBinding.instance.removeTimingsCallback(_handleTimings);
  }

  void _handleTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration.inMicroseconds / 1000;
      final rasterDuration = timing.rasterDuration.inMicroseconds / 1000;
      final totalDuration = timing.totalSpan.inMicroseconds / 1000;

      record(MetricType.buildTime, buildDuration);
      record(MetricType.paintTime, rasterDuration);
      record(MetricType.frameTime, totalDuration);
    }
  }

  /// 获取指标统计
  MetricStats? getStats(MetricType type) {
    final data = _metrics[type];
    if (data == null || data.isEmpty) return null;

    return MetricStats(type, data.map((d) => d.value).toList());
  }

  /// 获取所有统计
  Map<String, MetricStats> getAllStats() {
    return Map.fromEntries(
      _metrics.entries.where((e) => e.value.isNotEmpty).map((e) => MapEntry(
            e.key.name,
            MetricStats(e.key, e.value.map((d) => d.value).toList()),
          )),
    );
  }

  /// 获取最近N个数据点
  List<MetricDataPoint> getRecentData(MetricType type, int count) {
    final data = _metrics[type];
    if (data == null) return [];

    final start = (data.length - count).clamp(0, data.length);
    return data.sublist(start);
  }

  /// 清除指标数据
  void clear() {
    _metrics.clear();
    _timers.clear();
  }

  /// 生成性能报告
  Map<String, dynamic> generateReport() {
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'isEnabled': _isEnabled,
      'isFrameMonitoringEnabled': _isFrameMonitoringEnabled,
      'metrics': {},
    };

    for (final entry in _metrics.entries) {
      if (entry.value.isNotEmpty) {
        final stats =
            MetricStats(entry.key, entry.value.map((d) => d.value).toList());
        report['metrics'][entry.key.name] = stats.toJson();
      }
    }

    return report;
  }
}

/// Widget构建性能追踪
class BuildProfiler extends StatefulWidget {
  final String name;
  final Widget child;
  final bool enabled;

  const BuildProfiler({
    super.key,
    required this.name,
    required this.child,
    this.enabled = true,
  });

  @override
  State<BuildProfiler> createState() => _BuildProfilerState();
}

class _BuildProfilerState extends State<BuildProfiler> {
  final _monitor = PerformanceMonitor();

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return _monitor.measureSync(
      'build_${widget.name}',
      () => widget.child,
      type: MetricType.buildTime,
    );
  }
}

/// 性能监控扩展
extension PerformanceMonitorExtension on Widget {
  /// 包装widget以监控性能
  Widget withPerformanceMonitoring(String name, {bool enabled = true}) {
    return BuildProfiler(
      name: name,
      enabled: enabled,
      child: this,
    );
  }
}

/// 内存使用监控
class MemoryMonitor {
  static final MemoryMonitor _instance = MemoryMonitor._internal();
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();

  Timer? _monitorTimer;
  final _monitor = PerformanceMonitor();

  /// 开始内存监控
  void start({Duration interval = const Duration(seconds: 5)}) {
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(interval, (_) {
      _recordMemoryUsage();
    });
  }

  /// 停止内存监控
  void stop() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  void _recordMemoryUsage() {
    // 注意: 在Flutter中获取精确内存使用需要平台特定代码
    // 这里记录一个占位值，实际应用中应使用dart:developer的Service扩展
    // 或者平台特定的内存API
    _monitor.record(
      MetricType.memoryUsage,
      0, // 占位符
      label: 'memory_snapshot',
    );
  }

  /// 记录特定操作的内存影响
  Future<T> trackMemoryImpact<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    // 记录操作前后的内存差异（需要平台特定实现）
    final result = await action();
    return result;
  }
}

/// 网络性能追踪
class NetworkPerformanceTracker {
  static final NetworkPerformanceTracker _instance =
      NetworkPerformanceTracker._internal();
  factory NetworkPerformanceTracker() => _instance;
  NetworkPerformanceTracker._internal();

  final _monitor = PerformanceMonitor();

  /// 追踪网络请求
  Future<T> trackRequest<T>(
    String endpoint,
    Future<T> Function() request,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await request();
    } finally {
      stopwatch.stop();
      _monitor.record(
        MetricType.networkLatency,
        stopwatch.elapsedMilliseconds.toDouble(),
        label: endpoint,
      );
    }
  }

  /// 获取网络延迟统计
  MetricStats? getLatencyStats() {
    return _monitor.getStats(MetricType.networkLatency);
  }
}
