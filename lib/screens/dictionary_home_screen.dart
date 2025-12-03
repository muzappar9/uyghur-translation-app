import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../i18n/localizations.dart';

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          // TODO: 推荐词列表
                          _WordChip(word: 'TODO', onTap: () {}),
                          _WordChip(word: 'TODO', onTap: () {}),
                          _WordChip(word: 'TODO', onTap: () {}),
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
                          // TODO: 分类列表
                          _CategoryChip(label: 'TODO', onTap: () {}),
                          _CategoryChip(label: 'TODO', onTap: () {}),
                          _CategoryChip(label: 'TODO', onTap: () {}),
                          _CategoryChip(label: 'TODO', onTap: () {}),
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
                      // TODO: 历史记录ListView
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'TODO: History List',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
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
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            color: Colors.white.withOpacity(0.15),
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
