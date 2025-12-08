/// 字体选择器 Widget
/// 提供 Alkatip 和汉语字体的可视化选择界面
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/fonts/font_config.dart';
import '../core/fonts/font_config_provider.dart';

/// Alkatip 字体选择器
class AlkatipFontSelector extends ConsumerWidget {
  final bool showTitle;
  final EdgeInsets? padding;

  const AlkatipFontSelector({
    super.key,
    this.showTitle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFont = ref.watch(uyghurFontProvider);
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle) ...[
            Text(
              '维吾尔语字体',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // 字体网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AlkatipFont.values.length,
            itemBuilder: (context, index) {
              final font = AlkatipFont.values[index];
              final isSelected = font == currentFont;

              return _FontOptionCard(
                fontFamily: font.fontFamily,
                displayName: font.displayNameZh,
                secondaryName: font.displayNameUg,
                isSelected: isSelected,
                onTap: () {
                  ref.read(fontConfigProvider.notifier).setUyghurFont(font);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 汉语字体选择器
class ChineseFontSelector extends ConsumerWidget {
  final bool showTitle;
  final EdgeInsets? padding;

  const ChineseFontSelector({
    super.key,
    this.showTitle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFont = ref.watch(chineseFontProvider);
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle) ...[
            Text(
              '汉语字体',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // 字体列表
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ChineseFont.values.length,
            itemBuilder: (context, index) {
              final font = ChineseFont.values[index];
              final isSelected = font == currentFont;

              return _FontOptionCard(
                fontFamily: font.fontFamily == 'System' ? '' : font.fontFamily,
                displayName: font.displayName,
                isSelected: isSelected,
                onTap: () {
                  ref.read(fontConfigProvider.notifier).setChineseFont(font);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 字体选项卡片
class _FontOptionCard extends StatelessWidget {
  final String fontFamily;
  final String displayName;
  final String? secondaryName;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontOptionCard({
    required this.fontFamily,
    required this.displayName,
    this.secondaryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected 
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主显示名称
              Text(
                displayName,
                style: TextStyle(
                  fontFamily: fontFamily.isEmpty ? null : fontFamily,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // 次要名称（维吾尔语）
              if (secondaryName != null) ...[
                const SizedBox(height: 4),
                Text(
                  secondaryName!,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 字体大小调节器
class FontSizeAdjuster extends ConsumerWidget {
  final EdgeInsets? padding;

  const FontSizeAdjuster({super.key, this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '字体大小',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // 减小按钮
              IconButton(
                onPressed: fontSize > FontConstants.minFontSize
                    ? () => ref.read(fontConfigProvider.notifier).decreaseFontSize()
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              
              // 滑块
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: FontConstants.minFontSize,
                  max: FontConstants.maxFontSize,
                  divisions: ((FontConstants.maxFontSize - FontConstants.minFontSize) / 
                      FontConstants.fontSizeStep).round(),
                  label: fontSize.toStringAsFixed(0),
                  onChanged: (value) {
                    ref.read(fontConfigProvider.notifier).setFontSize(value);
                  },
                ),
              ),
              
              // 增大按钮
              IconButton(
                onPressed: fontSize < FontConstants.maxFontSize
                    ? () => ref.read(fontConfigProvider.notifier).increaseFontSize()
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
              
              // 当前大小显示
              SizedBox(
                width: 40,
                child: Text(
                  fontSize.toStringAsFixed(0),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          
          // 预览文本
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'مەرھابا 你好 Hello',
              style: TextStyle(fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// 完整字体设置底部表单
class FontSettingsSheet extends ConsumerWidget {
  const FontSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FontSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // 拖动把手
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '字体设置',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        ref.read(fontConfigProvider.notifier).resetToDefault();
                      },
                      child: const Text('重置'),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // 滚动内容
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: const [
                    // 字体大小调节
                    FontSizeAdjuster(),
                    
                    Divider(height: 32),
                    
                    // Alkatip 字体选择
                    AlkatipFontSelector(),
                    
                    Divider(height: 32),
                    
                    // 汉语字体选择
                    ChineseFontSelector(),
                    
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
