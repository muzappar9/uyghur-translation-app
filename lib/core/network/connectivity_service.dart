/// 网络连接服务
///
/// 提供网络状态监测、离线模式检测等功能
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络连接状态
enum NetworkStatus {
  /// 已连接
  connected,

  /// 未连接
  disconnected,

  /// 检测中
  checking,
}

/// 网络连接信息
class ConnectivityInfo {
  final NetworkStatus status;
  final List<ConnectivityResult> connectionTypes;
  final DateTime lastChecked;
  final bool isWifi;
  final bool isMobile;
  final bool isOffline;

  const ConnectivityInfo({
    required this.status,
    required this.connectionTypes,
    required this.lastChecked,
    this.isWifi = false,
    this.isMobile = false,
    this.isOffline = true,
  });

  factory ConnectivityInfo.initial() {
    return ConnectivityInfo(
      status: NetworkStatus.checking,
      connectionTypes: [],
      lastChecked: DateTime.now(),
    );
  }

  factory ConnectivityInfo.connected(List<ConnectivityResult> types) {
    final isWifi = types.contains(ConnectivityResult.wifi);
    final isMobile = types.contains(ConnectivityResult.mobile);
    return ConnectivityInfo(
      status: NetworkStatus.connected,
      connectionTypes: types,
      lastChecked: DateTime.now(),
      isWifi: isWifi,
      isMobile: isMobile,
      isOffline: false,
    );
  }

  factory ConnectivityInfo.disconnected() {
    return ConnectivityInfo(
      status: NetworkStatus.disconnected,
      connectionTypes: [],
      lastChecked: DateTime.now(),
      isOffline: true,
    );
  }

  ConnectivityInfo copyWith({
    NetworkStatus? status,
    List<ConnectivityResult>? connectionTypes,
    DateTime? lastChecked,
    bool? isWifi,
    bool? isMobile,
    bool? isOffline,
  }) {
    return ConnectivityInfo(
      status: status ?? this.status,
      connectionTypes: connectionTypes ?? this.connectionTypes,
      lastChecked: lastChecked ?? this.lastChecked,
      isWifi: isWifi ?? this.isWifi,
      isMobile: isMobile ?? this.isMobile,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

/// 网络连接服务
class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;
  final _statusController = StreamController<ConnectivityInfo>.broadcast();

  ConnectivityInfo _currentInfo = ConnectivityInfo.initial();

  ConnectivityService() : _connectivity = Connectivity();

  /// 当前连接信息
  ConnectivityInfo get currentInfo => _currentInfo;

  /// 是否离线
  bool get isOffline => _currentInfo.isOffline;

  /// 是否在线
  bool get isOnline => !_currentInfo.isOffline;

  /// 连接状态流
  Stream<ConnectivityInfo> get statusStream => _statusController.stream;

  /// 初始化服务
  Future<void> initialize() async {
    try {
      // 检查当前状态 (5.0.x 返回单个 ConnectivityResult)
      final result = await _connectivity.checkConnectivity();
      _updateStatusFromResult(result);

      // 监听状态变化 (onConnectivityChanged 返回单个 ConnectivityResult)
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateStatusFromResult,
        onError: (error) {
          debugPrint('Connectivity error: $error');
          _updateStatusFromResult(ConnectivityResult.none);
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize connectivity: $e');
      _currentInfo = ConnectivityInfo.disconnected();
    }
  }

  void _updateStatusFromResult(ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;
    final types = [result];

    if (hasConnection) {
      _currentInfo = ConnectivityInfo.connected(types);
    } else {
      _currentInfo = ConnectivityInfo.disconnected();
    }

    _statusController.add(_currentInfo);
    debugPrint(
        'Network status: ${_currentInfo.status}, types: ${_currentInfo.connectionTypes}');
  }

  /// 手动检查连接状态
  Future<ConnectivityInfo> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatusFromResult(result);
      return _currentInfo;
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
      return ConnectivityInfo.disconnected();
    }
  }

  /// 释放资源
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// 网络连接服务提供者
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 网络连接状态提供者
final connectivityInfoProvider = StreamProvider<ConnectivityInfo>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// 是否离线提供者
final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityInfoProvider);
  return connectivity.when(
    data: (info) => info.isOffline,
    loading: () => false,
    error: (_, __) => true,
  );
});

/// 网络状态管理器
class ConnectivityNotifier extends AsyncNotifier<ConnectivityInfo> {
  @override
  Future<ConnectivityInfo> build() async {
    final service = ref.watch(connectivityServiceProvider);
    await service.initialize();

    // 监听变化
    service.statusStream.listen((info) {
      state = AsyncValue.data(info);
    });

    return service.currentInfo;
  }

  /// 刷新连接状态
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final service = ref.read(connectivityServiceProvider);
    final info = await service.checkConnectivity();
    state = AsyncValue.data(info);
  }
}

/// 网络连接状态通知提供者
final connectivityNotifierProvider =
    AsyncNotifierProvider<ConnectivityNotifier, ConnectivityInfo>(
  () => ConnectivityNotifier(),
);
