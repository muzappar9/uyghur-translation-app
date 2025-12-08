/// 多语言选择器组件
/// 支持 36 种语言的选择、搜索和分组显示
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/i18n/language_config.dart';
import '../core/i18n/font_download_manager.dart';

/// 语言选择器配置
class LanguageSelectorConfig {
  /// 是否显示搜索框
  final bool showSearch;

  /// 是否分组显示
  final bool showGroups;

  /// 是否显示本地名称
  final bool showNativeName;

  /// 是否显示字体下载状态
  final bool showFontStatus;

  /// 当前 UI 语言
  final String uiLocale;

  const LanguageSelectorConfig({
    this.showSearch = true,
    this.showGroups = true,
    this.showNativeName = true,
    this.showFontStatus = true,
    this.uiLocale = 'zh',
  });
}

/// 语言选择结果
class LanguageSelection {
  final String sourceLanguage;
  final String targetLanguage;

  const LanguageSelection({
    required this.sourceLanguage,
    required this.targetLanguage,
  });
}

/// 单语言选择器（选择一个语言）
class SingleLanguageSelector extends ConsumerStatefulWidget {
  final String? selectedLanguage;
  final ValueChanged<String> onSelected;
  final String title;
  final LanguageSelectorConfig config;

  /// 排除的语言列表（不显示这些语言）
  final List<String> excludeLanguages;

  const SingleLanguageSelector({
    super.key,
    this.selectedLanguage,
    required this.onSelected,
    this.title = '选择语言',
    this.config = const LanguageSelectorConfig(),
    this.excludeLanguages = const [],
  });

  @override
  ConsumerState<SingleLanguageSelector> createState() =>
      _SingleLanguageSelectorState();
}

class _SingleLanguageSelectorState
    extends ConsumerState<SingleLanguageSelector> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LanguageConfig> get _filteredLanguages {
    var languages = SupportedLanguages.all
        .where((lang) => !widget.excludeLanguages.contains(lang.code))
        .toList();

    if (_searchQuery.isNotEmpty) {
      languages = SupportedLanguages.search(_searchQuery)
          .where((lang) => !widget.excludeLanguages.contains(lang.code))
          .toList();
    }

    return languages;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // 搜索框
        if (widget.config.showSearch)
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索语言...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

        // 语言列表
        Expanded(
          child: widget.config.showGroups && _searchQuery.isEmpty
              ? _buildGroupedList()
              : _buildFlatList(),
        ),
      ],
    );
  }

  Widget _buildGroupedList() {
    final grouped = SupportedLanguages.groupedLanguages;

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped.keys.elementAt(index);
        final languages = grouped[group]!
            .where((lang) => !widget.excludeLanguages.contains(lang.code))
            .toList();

        if (languages.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分组标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                group.getDisplayName(widget.config.uiLocale),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // 语言项
            ...languages.map((lang) => _buildLanguageItem(lang)),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildFlatList() {
    final languages = _filteredLanguages;

    return ListView.builder(
      itemCount: languages.length,
      itemBuilder: (context, index) => _buildLanguageItem(languages[index]),
    );
  }

  Widget _buildLanguageItem(LanguageConfig language) {
    final isSelected = widget.selectedLanguage == language.code;
    final theme = Theme.of(context);
    final fontState = ref.watch(fontDownloadManagerProvider);
    final fontAvailable = fontState.isFontAvailable(language.code);

    return ListTile(
      leading: _buildLanguageIcon(language),
      title: Text(
        language.getDisplayName(widget.config.uiLocale),
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      subtitle:
          widget.config.showNativeName && language.nameNative != language.nameZh
              ? Text(
                  language.nameNative,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textDirection: language.textDirection,
                )
              : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 字体状态指示
          if (widget.config.showFontStatus && !fontAvailable)
            Tooltip(
              message: '需要下载字体',
              child: Icon(
                Icons.download_outlined,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
            ),
          // 选中标记
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
      selected: isSelected,
      onTap: () {
        widget.onSelected(language.code);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLanguageIcon(LanguageConfig language) {
    // RTL 语言显示特殊图标
    if (language.isRTL) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.format_textdirection_r_to_l, size: 20),
        ),
      );
    }

    // 中国少数民族语言显示特殊标记
    if (language.isChineseMinority) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '🇨🇳',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    // 默认显示语言代码
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          language.code.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 翻译语言对选择器
class TranslationLanguagePairSelector extends ConsumerStatefulWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final ValueChanged<LanguageSelection> onChanged;

  const TranslationLanguagePairSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onChanged,
  });

  @override
  ConsumerState<TranslationLanguagePairSelector> createState() =>
      _TranslationLanguagePairSelectorState();
}

class _TranslationLanguagePairSelectorState
    extends ConsumerState<TranslationLanguagePairSelector> {
  late String _sourceLanguage;
  late String _targetLanguage;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = widget.sourceLanguage;
    _targetLanguage = widget.targetLanguage;
  }

  @override
  void didUpdateWidget(TranslationLanguagePairSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceLanguage != widget.sourceLanguage) {
      _sourceLanguage = widget.sourceLanguage;
    }
    if (oldWidget.targetLanguage != widget.targetLanguage) {
      _targetLanguage = widget.targetLanguage;
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
    widget.onChanged(LanguageSelection(
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    ));
  }

  Future<void> _selectSourceLanguage() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleLanguageSelector(
            selectedLanguage: _sourceLanguage,
            title: '选择源语言',
            excludeLanguages: [_targetLanguage],
            onSelected: (code) {
              setState(() => _sourceLanguage = code);
              widget.onChanged(LanguageSelection(
                sourceLanguage: _sourceLanguage,
                targetLanguage: _targetLanguage,
              ));
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectTargetLanguage() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleLanguageSelector(
            selectedLanguage: _targetLanguage,
            title: '选择目标语言',
            excludeLanguages: [_sourceLanguage],
            onSelected: (code) {
              setState(() => _targetLanguage = code);
              widget.onChanged(LanguageSelection(
                sourceLanguage: _sourceLanguage,
                targetLanguage: _targetLanguage,
              ));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceConfig = SupportedLanguages.getByCode(_sourceLanguage);
    final targetConfig = SupportedLanguages.getByCode(_targetLanguage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 源语言按钮
          _LanguageButton(
            languageCode: _sourceLanguage,
            languageConfig: sourceConfig,
            onTap: _selectSourceLanguage,
          ),

          // 交换按钮
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _swapLanguages,
            tooltip: '交换语言',
            iconSize: 24,
          ),

          // 目标语言按钮
          _LanguageButton(
            languageCode: _targetLanguage,
            languageConfig: targetConfig,
            onTap: _selectTargetLanguage,
          ),
        ],
      ),
    );
  }
}

/// 语言按钮组件
class _LanguageButton extends StatelessWidget {
  final String languageCode;
  final LanguageConfig? languageConfig;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.languageCode,
    required this.languageConfig,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = languageConfig?.nameZh ?? languageCode.toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 紧凑型语言选择器（用于应用栏等空间受限场景）
class CompactLanguageSelector extends ConsumerWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final ValueChanged<LanguageSelection> onChanged;

  const CompactLanguageSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TranslationLanguagePairSelector(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      onChanged: onChanged,
    );
  }
}

/// 语言列表选择器（全屏版本）
class FullScreenLanguageSelector extends StatelessWidget {
  final String? selectedLanguage;
  final ValueChanged<String> onSelected;
  final String title;
  final List<String> excludeLanguages;

  const FullScreenLanguageSelector({
    super.key,
    this.selectedLanguage,
    required this.onSelected,
    this.title = '选择语言',
    this.excludeLanguages = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleLanguageSelector(
        selectedLanguage: selectedLanguage,
        onSelected: onSelected,
        title: title,
        excludeLanguages: excludeLanguages,
      ),
    );
  }
}

/// 显示语言选择对话框
Future<String?> showLanguageSelector(
  BuildContext context, {
  String? selectedLanguage,
  String title = '选择语言',
  List<String> excludeLanguages = const [],
}) async {
  String? result;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleLanguageSelector(
          selectedLanguage: selectedLanguage,
          title: title,
          excludeLanguages: excludeLanguages,
          onSelected: (code) {
            result = code;
          },
        ),
      ),
    ),
  );

  return result;
}
