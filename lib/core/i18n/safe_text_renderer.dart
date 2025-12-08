/// 多语言文本安全渲染组件
/// 解决以下问题：
/// 1. 字体缺失时的豆腐块显示
/// 2. RTL/LTR 混排文本的正确隔离
/// 3. 复杂文字的正确显示
/// 4. 文本溢出处理
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_config.dart';
import 'font_download_manager.dart';

/// 安全文本渲染组件
/// 自动处理 RTL/LTR 混排、字体检测、溢出等问题
class SafeText extends ConsumerWidget {
  /// 要显示的文本
  final String text;

  /// 文本的语言代码
  final String languageCode;

  /// 文本样式
  final TextStyle? style;

  /// 最大行数
  final int? maxLines;

  /// 溢出处理方式
  final TextOverflow? overflow;

  /// 文本对齐
  final TextAlign? textAlign;

  /// 是否可选择
  final bool selectable;

  /// 字体缺失时的回调
  final VoidCallback? onFontMissing;

  const SafeText(
    this.text, {
    super.key,
    required this.languageCode,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.onFontMissing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontState = ref.watch(fontDownloadManagerProvider);
    final fontAvailable = fontState.isFontAvailable(languageCode);
    final textDirection = SupportedLanguages.getTextDirection(languageCode);

    // 处理后的文本（添加双向隔离）
    final processedText = _processTextForBidi(text, languageCode);

    // 字体不可用时显示提示
    if (!fontAvailable) {
      return _buildFontMissingWidget(context, ref);
    }

    // 合并样式
    final effectiveStyle = _buildTextStyle(context);

    if (selectable) {
      return SelectableText(
        processedText,
        style: effectiveStyle,
        textDirection: textDirection,
        maxLines: maxLines,
        textAlign: textAlign,
      );
    }

    return Text(
      processedText,
      style: effectiveStyle,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }

  /// 为双向文本添加隔离符号
  /// 解决 RTL 文本中包含数字、英文时的显示问题
  String _processTextForBidi(String text, String langCode) {
    if (!SupportedLanguages.isRTL(langCode)) {
      return text;
    }

    // 使用 Unicode 双向隔离符号
    // U+2066 Left-to-Right Isolate (LRI)
    // U+2067 Right-to-Left Isolate (RLI)
    // U+2068 First Strong Isolate (FSI)
    // U+2069 Pop Directional Isolate (PDI)

    // 为 RTL 文本中的数字和英文添加 LTR 隔离
    final buffer = StringBuffer();
    final numberOrLatinRegex = RegExp(r'[0-9a-zA-Z]+');

    int lastEnd = 0;
    for (final match in numberOrLatinRegex.allMatches(text)) {
      // 添加匹配前的 RTL 文本
      if (match.start > lastEnd) {
        buffer.write(text.substring(lastEnd, match.start));
      }
      // 用 LRI...PDI 包裹数字/英文
      buffer.write('\u2066'); // LRI
      buffer.write(match.group(0));
      buffer.write('\u2069'); // PDI
      lastEnd = match.end;
    }
    // 添加剩余文本
    if (lastEnd < text.length) {
      buffer.write(text.substring(lastEnd));
    }

    return buffer.toString();
  }

  /// 构建文本样式
  TextStyle _buildTextStyle(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final fontFamily = _getFontFamily();

    return baseStyle?.copyWith(
          fontFamily: fontFamily,
          // 确保复杂文字的正确显示
          fontFeatures: _getFontFeatures(),
        ) ??
        TextStyle(
          fontFamily: fontFamily,
          fontFeatures: _getFontFeatures(),
        );
  }

  /// 获取语言对应的字体族
  String? _getFontFamily() {
    final config = SupportedLanguages.getByCode(languageCode);
    if (config == null) return null;

    switch (config.fontCategory) {
      case FontCategory.arabic:
        return 'Alkatip'; // 维吾尔语/阿拉伯语
      case FontCategory.cjk:
        return null; // 使用系统 CJK 字体
      case FontCategory.devanagari:
        return 'NotoSansDevanagari';
      case FontCategory.bengali:
        return 'NotoSansBengali';
      case FontCategory.tamil:
        return 'NotoSansTamil';
      case FontCategory.telugu:
        return 'NotoSansTelugu';
      case FontCategory.gujarati:
        return 'NotoSansGujarati';
      case FontCategory.thai:
        return 'NotoSansThai';
      case FontCategory.khmer:
        return 'NotoSansKhmer';
      case FontCategory.myanmar:
        return 'NotoSansMyanmar';
      case FontCategory.tibetan:
        return 'NotoSansTibetan';
      case FontCategory.hebrew:
        return 'NotoSansHebrew';
      case FontCategory.mongolian:
        return 'NotoSansMongolian';
      case FontCategory.system:
        return null;
    }
  }

  /// 获取字体特性
  List<FontFeature>? _getFontFeatures() {
    final config = SupportedLanguages.getByCode(languageCode);
    if (config == null) return null;

    // 阿拉伯语系需要启用连字特性
    if (config.fontCategory == FontCategory.arabic) {
      return const [
        FontFeature.enable('liga'), // 标准连字
        FontFeature.enable('calt'), // 上下文替换
        FontFeature.enable('ccmp'), // 组合字符
      ];
    }

    return null;
  }

  /// 构建字体缺失提示组件
  Widget _buildFontMissingWidget(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = SupportedLanguages.getByCode(languageCode);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 显示原文（可能是豆腐块）
          Text(
            text,
            style: style?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
            maxLines: maxLines,
            overflow: overflow,
          ),
          const SizedBox(height: 8),
          // 下载字体提示
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                '需要下载${config?.nameZh ?? languageCode}字体',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _downloadFont(ref),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('下载'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 下载字体
  Future<void> _downloadFont(WidgetRef ref) async {
    final category = SupportedLanguages.getFontCategory(languageCode);
    await ref.read(fontDownloadManagerProvider.notifier).downloadFont(category);
    onFontMissing?.call();
  }
}

/// 混合语言文本组件
/// 用于显示包含多种语言的文本（如翻译结果）
class MixedLanguageText extends ConsumerWidget {
  /// 源文本
  final String sourceText;

  /// 源语言代码
  final String sourceLanguage;

  /// 目标文本
  final String targetText;

  /// 目标语言代码
  final String targetLanguage;

  /// 显示方向（垂直/水平）
  final Axis direction;

  /// 间距
  final double spacing;

  const MixedLanguageText({
    super.key,
    required this.sourceText,
    required this.sourceLanguage,
    required this.targetText,
    required this.targetLanguage,
    this.direction = Axis.vertical,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = [
      // 源文本
      _LanguageTextBlock(
        text: sourceText,
        languageCode: sourceLanguage,
        label: SupportedLanguages.getDisplayName(sourceLanguage),
      ),
      SizedBox(
        width: direction == Axis.horizontal ? spacing : 0,
        height: direction == Axis.vertical ? spacing : 0,
      ),
      // 目标文本
      _LanguageTextBlock(
        text: targetText,
        languageCode: targetLanguage,
        label: SupportedLanguages.getDisplayName(targetLanguage),
      ),
    ];

    if (direction == Axis.horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((c) => Expanded(child: c)).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// 单语言文本块
class _LanguageTextBlock extends StatelessWidget {
  final String text;
  final String languageCode;
  final String label;

  const _LanguageTextBlock({
    required this.text,
    required this.languageCode,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = SupportedLanguages.isRTL(languageCode);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 语言标签
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          // 文本内容
          SafeText(
            text,
            languageCode: languageCode,
            selectable: true,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// RTL 感知的布局容器
/// 根据语言自动调整子组件的排列方向
class RTLAwareContainer extends StatelessWidget {
  final String languageCode;
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const RTLAwareContainer({
    super.key,
    required this.languageCode,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = SupportedLanguages.isRTL(languageCode);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }
}

/// 检测文本是否包含不可显示字符（豆腐块检测）
bool hasDisplayIssues(String text) {
  // 检查是否有替换字符 U+FFFD
  if (text.contains('\uFFFD')) return true;

  // 检查是否有对象替换字符 U+FFFC
  if (text.contains('\uFFFC')) return true;

  return false;
}

/// 获取文本的主要脚本（用于自动检测语言方向）
TextDirection detectTextDirection(String text) {
  if (text.isEmpty) return TextDirection.ltr;

  // RTL 字符范围
  final rtlRegex = RegExp(r'[\u0600-\u06FF' // 阿拉伯语
      r'\u0750-\u077F' // 阿拉伯语补充
      r'\u08A0-\u08FF' // 阿拉伯语扩展A
      r'\uFB50-\uFDFF' // 阿拉伯语表现形式A
      r'\uFE70-\uFEFF' // 阿拉伯语表现形式B
      r'\u0590-\u05FF' // 希伯来语
      r']');

  // 计算 RTL 字符占比
  int rtlCount = 0;
  for (final char in text.runes) {
    if (rtlRegex.hasMatch(String.fromCharCode(char))) {
      rtlCount++;
    }
  }

  // 如果 RTL 字符超过 30%，则判定为 RTL
  return rtlCount / text.length > 0.3 ? TextDirection.rtl : TextDirection.ltr;
}
