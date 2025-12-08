/// 支持字体切换的翻译结果显示组件
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/fonts/font_config.dart';
import '../core/fonts/font_config_provider.dart';
import '../core/i18n/language_config.dart';
import '../core/i18n/safe_text_renderer.dart';
import 'font_selector.dart';

/// 翻译文本显示卡片（支持字体切换）
class TranslationTextCard extends ConsumerWidget {
  final String text;
  final String languageCode;
  final String? label;
  final bool showFontButton;
  final bool selectable;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const TranslationTextCard({
    super.key,
    required this.text,
    required this.languageCode,
    this.label,
    this.showFontButton = true,
    this.selectable = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontConfig = ref.watch(currentFontConfigProvider);
    final theme = Theme.of(context);
    final textStyle = fontConfig.getTextStyle(
      languageCode,
      color: theme.textTheme.bodyLarge?.color,
    );

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行（带字体按钮）
          if (label != null || showFontButton)
            Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(
                      label!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                if (showFontButton)
                  IconButton(
                    icon: const Icon(Icons.font_download_outlined, size: 20),
                    tooltip: '字体设置',
                    onPressed: () => FontSettingsSheet.show(context),
                  ),
              ],
            ),

          if (label != null || showFontButton) const SizedBox(height: 8),

          // 文本内容 - 使用 SafeText 处理多语言显示
          SafeText(
            text,
            languageCode: languageCode,
            style: textStyle,
            selectable: selectable,
          ),

          // 操作按钮行
          if (text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 复制按钮
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已复制到剪贴板'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('复制'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 双语对照显示卡片
class BilingualTextCard extends ConsumerWidget {
  final String sourceText;
  final String sourceLang;
  final String targetText;
  final String targetLang;
  final bool showFontButtons;

  const BilingualTextCard({
    super.key,
    required this.sourceText,
    required this.sourceLang,
    required this.targetText,
    required this.targetLang,
    this.showFontButtons = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 源文本
        TranslationTextCard(
          text: sourceText,
          languageCode: sourceLang,
          label: _getLanguageLabel(sourceLang),
          showFontButton: showFontButtons,
        ),

        const SizedBox(height: 16),

        // 分隔指示器
        Row(
          children: [
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.arrow_downward,
                size: 20,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          ],
        ),

        const SizedBox(height: 16),

        // 目标文本
        TranslationTextCard(
          text: targetText,
          languageCode: targetLang,
          label: _getLanguageLabel(targetLang),
          showFontButton: showFontButtons,
          backgroundColor: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.1),
        ),
      ],
    );
  }

  String _getLanguageLabel(String langCode) {
    // 使用多语言配置获取完整显示名称
    return SupportedLanguages.getFullDisplayName(langCode, locale: 'zh');
  }
}

/// 快速字体切换按钮（浮动按钮）
class QuickFontSwitcher extends ConsumerWidget {
  final String languageCode;

  const QuickFontSwitcher({
    super.key,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FloatingActionButton.small(
      onPressed: () {
        _showQuickFontMenu(context, ref);
      },
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.font_download,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _showQuickFontMenu(BuildContext context, WidgetRef ref) {
    // 根据语言代码获取语言配置
    final language = SupportedLanguages.getByCode(languageCode);

    if (languageCode == 'ug') {
      _showUyghurFontMenu(context, ref);
    } else if (languageCode == 'zh' || languageCode == 'zh-Hant') {
      _showChineseFontMenu(context, ref);
    } else if (language != null) {
      // 对于其他支持的语言，显示通用字体提示
      _showGenericFontInfo(context, language);
    }
  }

  void _showGenericFontInfo(BuildContext context, LanguageConfig language) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.font_download_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '${language.nameNative} (${language.nameZh})',
              style: Theme.of(context).textTheme.titleLarge,
              textDirection: language.textDirection,
            ),
            const SizedBox(height: 8),
            Text(
              '字体类别: ${language.fontCategory.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (language.isRTL)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.format_textdirection_r_to_l, size: 16),
                    SizedBox(width: 4),
                    Text('从右到左书写'),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showUyghurFontMenu(BuildContext context, WidgetRef ref) {
    final currentFont = ref.read(uyghurFontProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择维吾尔语字体',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),

            // 字体列表
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: AlkatipFont.values.length,
                itemBuilder: (context, index) {
                  final font = AlkatipFont.values[index];
                  final isSelected = font == currentFont;

                  return ListTile(
                    title: Text(
                      font.displayNameZh,
                      style: TextStyle(
                        fontFamily: font.fontFamily,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    subtitle: Text(
                      font.displayNameUg,
                      style: TextStyle(
                        fontFamily: font.fontFamily,
                        fontSize: 12,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      ref.read(fontConfigProvider.notifier).setUyghurFont(font);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showChineseFontMenu(BuildContext context, WidgetRef ref) {
    final currentFont = ref.read(chineseFontProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择汉语字体',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),

            // 字体列表
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ChineseFont.values.length,
                itemBuilder: (context, index) {
                  final font = ChineseFont.values[index];
                  final isSelected = font == currentFont;

                  return ListTile(
                    title: Text(
                      font.displayName,
                      style: TextStyle(
                        fontFamily: font.fontFamily == 'System'
                            ? null
                            : font.fontFamily,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      ref
                          .read(fontConfigProvider.notifier)
                          .setChineseFont(font);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
