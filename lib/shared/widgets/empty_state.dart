import 'package:flutter/material.dart';

/// 空状态 Widget - 用于显示列表为空、搜索无结果等情况
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onAction;
  final String? actionButtonLabel;
  final EdgeInsets padding;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.onAction,
    this.actionButtonLabel,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalIconColor = iconColor ?? theme.colorScheme.secondary;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: finalIconColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionButtonLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionButtonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 历史记录为空
  static Widget history({VoidCallback? onAction}) {
    return EmptyStateWidget(
      title: '暂无翻译历史',
      subtitle: '开始进行翻译以查看历史记录',
      icon: Icons.history,
      onAction: onAction,
      actionButtonLabel: onAction != null ? '新建翻译' : null,
    );
  }

  /// 搜索结果为空
  static Widget searchResults({
    String? query,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      title: '未找到结果',
      subtitle: query != null ? '没有找到"$query"的相关内容' : '未找到匹配的内容',
      icon: Icons.search_off,
      onAction: onRetry,
      actionButtonLabel: onRetry != null ? '重新搜索' : null,
    );
  }

  /// 收藏列表为空
  static Widget favorites({VoidCallback? onAction}) {
    return EmptyStateWidget(
      title: '暂无收藏',
      subtitle: '收藏您喜欢的翻译结果',
      icon: Icons.favorite_border,
      onAction: onAction,
      actionButtonLabel: onAction != null ? '浏览翻译' : null,
    );
  }

  /// 自定义空状态
  static Widget custom({
    required String title,
    String? subtitle,
    IconData icon = Icons.inbox_outlined,
  }) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle,
      icon: icon,
    );
  }
}
