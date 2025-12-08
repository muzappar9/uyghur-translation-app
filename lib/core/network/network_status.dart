import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================
/// Stage 20: 网络状态监控组件
/// ============================================

/// 网络连接状态枚举
enum NetworkStatus {
  online,
  offline,
  unknown,
}

/// 网络状态Provider
final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, NetworkStatus>(
  (ref) => NetworkStatusNotifier(),
);

/// 网络状态管理器
class NetworkStatusNotifier extends StateNotifier<NetworkStatus> {
  Timer? _checkTimer;

  NetworkStatusNotifier() : super(NetworkStatus.online) {
    // 初始化网络状态检查
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    // 每30秒检查一次网络状态
    _checkTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkNetworkStatus(),
    );
  }

  /// 检查网络状态
  Future<void> checkNetworkStatus() async {
    try {
      // 简单的网络检查逻辑
      // 实际应使用connectivity_plus包
      // 这里简化为假定在线
      state = NetworkStatus.online;
    } catch (e) {
      state = NetworkStatus.offline;
    }
  }

  /// 手动设置离线状态
  void setOffline() {
    state = NetworkStatus.offline;
  }

  /// 手动设置在线状态
  void setOnline() {
    state = NetworkStatus.online;
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}

/// 离线状态横幅
class OfflineBanner extends ConsumerWidget {
  final Widget child;

  const OfflineBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: networkStatus == NetworkStatus.offline ? 36 : 0,
          child: networkStatus == NetworkStatus.offline
              ? Container(
                  width: double.infinity,
                  color: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        '您当前处于离线状态',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// 需要网络的Widget包装器
class RequiresNetwork extends ConsumerWidget {
  final Widget child;
  final Widget? offlineWidget;

  const RequiresNetwork({
    super.key,
    required this.child,
    this.offlineWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    if (networkStatus == NetworkStatus.offline) {
      return offlineWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '需要网络连接',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '请检查您的网络设置后重试',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(networkStatusProvider.notifier)
                          .checkNetworkStatus();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
    }

    return child;
  }
}

/// 带离线缓存提示的Widget
class OfflineCacheIndicator extends StatelessWidget {
  final bool isFromCache;
  final DateTime? cacheTime;

  const OfflineCacheIndicator({
    super.key,
    required this.isFromCache,
    this.cacheTime,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFromCache) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 14,
            color: Colors.amber.shade800,
          ),
          const SizedBox(width: 4),
          Text(
            cacheTime != null ? '缓存于 ${_formatTime(cacheTime!)}' : '来自缓存',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${diff.inDays}天前';
    }
  }
}
