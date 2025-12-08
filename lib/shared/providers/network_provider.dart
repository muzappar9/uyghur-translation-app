import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// 网络连接状态
enum NetworkStatus {
  online, // 在线
  offline, // 离线
  unknown, // 未知
}

/// 网络连接监听 Notifier
class NetworkConnectivityNotifier extends AsyncNotifier<NetworkStatus> {
  final _logger = Logger();
  late Connectivity _connectivity;

  @override
  Future<NetworkStatus> build() async {
    _connectivity = Connectivity();

    // 获取初始网络状态
    final result = await _connectivity.checkConnectivity();
    final status = _mapConnectivityResult(result);

    // 监听网络变化
    _connectivity.onConnectivityChanged.listen((result) {
      final newStatus = _mapConnectivityResult(result);
      if (newStatus != state.value) {
        state = AsyncValue.data(newStatus);
        _logger.i('Network status changed: $newStatus');
      }
    });

    return status;
  }

  /// 将 ConnectivityResult 转换为 NetworkStatus
  NetworkStatus _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return NetworkStatus.online;
      case ConnectivityResult.none:
        return NetworkStatus.offline;
      default:
        return NetworkStatus.unknown;
    }
  }

  /// 获取当前网络状态
  NetworkStatus? getCurrentStatus() {
    return state.whenData((status) => status).value;
  }
}

/// 网络连接状态 Provider
final networkConnectivityProvider =
    AsyncNotifierProvider<NetworkConnectivityNotifier, NetworkStatus>(
        NetworkConnectivityNotifier.new);
