/// 离线状态指示器
///
/// 显示网络连接状态的 Widget 组件
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network.dart';
import '../core/animations/app_animations.dart';

/// 离线状态横幅
class OfflineBanner extends ConsumerWidget {
  final Widget child;
  final bool showWhenOnline;

  const OfflineBanner({
    super.key,
    required this.child,
    this.showWhenOnline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityInfoProvider);

    return connectivity.when(
      data: (info) {
        if (info.isOffline) {
          return Column(
            children: [
              _OfflineIndicator(info: info),
              Expanded(child: child),
            ],
          );
        }
        if (showWhenOnline) {
          return Column(
            children: [
              _OnlineIndicator(info: info),
              Expanded(child: child),
            ],
          );
        }
        return child;
      },
      loading: () => child,
      error: (_, __) => Column(
        children: [
          _OfflineIndicator(info: ConnectivityInfo.disconnected()),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _OfflineIndicator extends StatelessWidget {
  final ConnectivityInfo info;

  const _OfflineIndicator({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: AppAnimationDuration.normal,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.errorContainer,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 16,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Text(
              '离线模式 - 部分功能可能不可用',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineIndicator extends StatefulWidget {
  final ConnectivityInfo info;

  const _OnlineIndicator({required this.info});

  @override
  State<_OnlineIndicator> createState() => _OnlineIndicatorState();
}

class _OnlineIndicatorState extends State<_OnlineIndicator> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    // 3秒后自动隐藏
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: AppAnimationDuration.normal,
      opacity: _visible ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: AppAnimationDuration.normal,
        height: _visible ? null : 0,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: _visible ? 8 : 0,
        ),
        color: theme.colorScheme.primaryContainer,
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.info.isWifi ? Icons.wifi : Icons.signal_cellular_alt,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '已连接网络',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 离线状态图标按钮
class OfflineStatusButton extends ConsumerWidget {
  final VoidCallback? onTap;

  const OfflineStatusButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityInfoProvider);
    final theme = Theme.of(context);

    return connectivity.when(
      data: (info) {
        final isOffline = info.isOffline;
        return IconButton(
          onPressed: onTap,
          icon: Icon(
            isOffline ? Icons.cloud_off : Icons.cloud_done,
            color:
                isOffline ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          tooltip: isOffline ? '离线' : '在线',
        );
      },
      loading: () => const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => IconButton(
        onPressed: onTap,
        icon: Icon(
          Icons.cloud_off,
          color: theme.colorScheme.error,
        ),
        tooltip: '网络错误',
      ),
    );
  }
}

/// 同步状态指示器
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineMode = ref.watch(offlineModeProvider);
    final theme = Theme.of(context);

    return offlineMode.when(
      data: (state) {
        if (state.isSyncing) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '同步中...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.hasUnsyncedData) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sync_problem,
                  size: 14,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '${state.pendingSyncCount} 项待同步',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// 网络依赖的 Widget 包装器
class NetworkAwareWidget extends ConsumerWidget {
  final Widget onlineChild;
  final Widget? offlineChild;
  final Widget? loadingChild;

  const NetworkAwareWidget({
    super.key,
    required this.onlineChild,
    this.offlineChild,
    this.loadingChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityInfoProvider);

    return connectivity.when(
      data: (info) {
        if (info.isOffline && offlineChild != null) {
          return offlineChild!;
        }
        return onlineChild;
      },
      loading: () => loadingChild ?? onlineChild,
      error: (_, __) => offlineChild ?? onlineChild,
    );
  }
}

/// 离线占位符
class OfflinePlaceholder extends StatelessWidget {
  final String? message;
  final IconData icon;
  final Widget? action;

  const OfflinePlaceholder({
    super.key,
    this.message,
    this.icon = Icons.cloud_off,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? '您当前处于离线状态',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '请检查网络连接后重试',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
