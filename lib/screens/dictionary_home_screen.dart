import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../i18n/localizations.dart';
import '../widgets/responsive_layout.dart';

/// DictionaryHomeScreen: 词典首页
/// 搜索框 + 推荐Section + 分类Section
class DictionaryHomeScreen extends StatelessWidget {
  const DictionaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF8E53),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t(context, 'dict.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  blurSigma: 15,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: 20,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: t(context, 'dict.search.placeholder'),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onSubmitted: (value) {
                      Navigator.pushNamed(context, '/dictionary_detail');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ResponsiveContainer(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getPadding(context),
                    ),
                    child: ResponsiveBuilder(
                      builder: (context, deviceType, orientation) {
                        // 平板/桌面使用两列布局
                        if (deviceType != DeviceType.mobile) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 左侧列
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Recommend Section
                                    Text(
                                      t(context, 'dict.section.recommend'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _WordChip(
                                            word: '你好',
                                            onTap: () => Navigator.pushNamed(
                                                context, '/dictionary_detail')),
                                        _WordChip(
                                            word: 'سالام',
                                            onTap: () => Navigator.pushNamed(
                                                context, '/dictionary_detail')),
                                        _WordChip(
                                            word: '谢谢',
                                            onTap: () => Navigator.pushNamed(
                                                context, '/dictionary_detail')),
                                        _WordChip(
                                            word: 'رەھمەت',
                                            onTap: () => Navigator.pushNamed(
                                                context, '/dictionary_detail')),
                                        _WordChip(
                                            word: '早上好',
                                            onTap: () => Navigator.pushNamed(
                                                context, '/dictionary_detail')),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    // Category Section
                                    Text(
                                      t(context, 'dict.section.category'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _CategoryChip(label: '基础词汇', onTap: () {}),
                                        _CategoryChip(label: '旅行', onTap: () {}),
                                        _CategoryChip(label: '商务', onTap: () {}),
                                        _CategoryChip(label: '日常生活', onTap: () {}),
                                        _CategoryChip(label: '食物', onTap: () {}),
                                        _CategoryChip(label: '数字', onTap: () {}),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // 右侧列 - 历史
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t(context, 'dict.section.history'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Column(
                                      children: [
                                        _HistoryListItem(
                                            word: '你好', translation: 'سالام', onTap: () {}),
                                        _HistoryListItem(
                                            word: '谢谢', translation: 'رەھمەت', onTap: () {}),
                                        _HistoryListItem(
                                            word: '再见',
                                            translation: 'خەير خوش',
                                            onTap: () {}),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        // 手机使用单列布局
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recommend Section
                            Text(
                              t(context, 'dict.section.recommend'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _WordChip(
                                    word: '你好',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/dictionary_detail')),
                                _WordChip(
                                    word: 'سالام',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/dictionary_detail')),
                                _WordChip(
                                    word: '谢谢',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/dictionary_detail')),
                                _WordChip(
                                    word: 'رەھمەت',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/dictionary_detail')),
                                _WordChip(
                                    word: '早上好',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/dictionary_detail')),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Category Section
                            Text(
                              t(context, 'dict.section.category'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _CategoryChip(label: '基础词汇', onTap: () {}),
                                _CategoryChip(label: '旅行', onTap: () {}),
                                _CategoryChip(label: '商务', onTap: () {}),
                                _CategoryChip(label: '日常生活', onTap: () {}),
                                _CategoryChip(label: '食物', onTap: () {}),
                                _CategoryChip(label: '数字', onTap: () {}),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // History Section
                            Text(
                              t(context, 'dict.section.history'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: [
                                _HistoryListItem(
                                    word: '你好', translation: 'سالام', onTap: () {}),
                                _HistoryListItem(
                                    word: '谢谢', translation: 'رەھمەت', onTap: () {}),
                                _HistoryListItem(
                                    word: '再见',
                                    translation: 'خەير خوش',
                                    onTap: () {}),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final VoidCallback? onTap;

  const _WordChip({required this.word, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            word,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _CategoryChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final String word;
  final String translation;
  final VoidCallback? onTap;

  const _HistoryListItem({
    required this.word,
    required this.translation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translation,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
