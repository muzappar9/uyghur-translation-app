/// Sync Status Indicator
///
/// UI components for displaying sync status and progress
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/sync/sync_service.dart';
import '../core/animations/app_animations.dart';

/// Sync status colors
class _SyncColors {
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color syncing = Color(0xFF007AFF);
  static const Color offline = Color(0xFF8E8E93);
}

/// Sync status indicator widget
class SyncStatusIndicator extends ConsumerWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(syncStateProvider);

    return asyncState.when(
      data: (syncState) => _buildIndicator(context, syncState),
      loading: () => _buildLoadingIndicator(),
      error: (_, __) => _buildErrorIndicator(),
    );
  }

  Widget _buildIndicator(BuildContext context, SyncState syncState) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.decelerate,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(syncState.status).withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBackgroundColor(syncState.status).withAlpha(50),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(syncState.status),
            if (showDetails) ...[
              const SizedBox(width: 8),
              Text(
                _getStatusText(syncState.status),
                style: TextStyle(
                  color: _getBackgroundColor(syncState.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child:
          const Icon(Icons.error_outline, size: 16, color: _SyncColors.error),
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    final color = _getBackgroundColor(status);

    switch (status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );
      case SyncStatus.success:
        return Icon(Icons.cloud_done, size: 16, color: color);
      case SyncStatus.failed:
        return Icon(Icons.cloud_off, size: 16, color: color);
      case SyncStatus.waitingForNetwork:
        return Icon(Icons.cloud_outlined, size: 16, color: color);
      case SyncStatus.idle:
        return Icon(Icons.cloud_queue, size: 16, color: color);
    }
  }

  Color _getBackgroundColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return _SyncColors.syncing;
      case SyncStatus.success:
        return _SyncColors.success;
      case SyncStatus.failed:
        return _SyncColors.error;
      case SyncStatus.waitingForNetwork:
        return _SyncColors.offline;
      case SyncStatus.idle:
        return _SyncColors.warning;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.failed:
        return 'Sync Error';
      case SyncStatus.waitingForNetwork:
        return 'Offline';
      case SyncStatus.idle:
        return 'Ready';
    }
  }
}

/// Mini sync indicator for app bar
class MiniSyncIndicator extends ConsumerWidget {
  const MiniSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(syncStateProvider);

    return asyncState.when(
      data: (syncState) => AnimatedSwitcher(
        duration: AppAnimations.fast,
        child: _buildIcon(syncState.status),
      ),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) =>
          const Icon(Icons.error_outline, size: 20, color: _SyncColors.error),
    );
  }

  Widget _buildIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return const SizedBox(
          key: ValueKey('syncing'),
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(_SyncColors.syncing),
          ),
        );
      case SyncStatus.success:
        return const Icon(
          key: ValueKey('success'),
          Icons.cloud_done,
          size: 20,
          color: _SyncColors.success,
        );
      case SyncStatus.failed:
        return const Icon(
          key: ValueKey('failed'),
          Icons.cloud_off,
          size: 20,
          color: _SyncColors.error,
        );
      case SyncStatus.waitingForNetwork:
        return const Icon(
          key: ValueKey('waiting'),
          Icons.cloud_outlined,
          size: 20,
          color: _SyncColors.offline,
        );
      case SyncStatus.idle:
        return const Icon(
          key: ValueKey('idle'),
          Icons.cloud_queue,
          size: 20,
          color: _SyncColors.warning,
        );
    }
  }
}
