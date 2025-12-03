import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dict_section_card.dart';
import '../i18n/localizations.dart';

/// DictionaryDetailScreen: 词典详情页
/// 词头 + 多分区Glass卡片
class DictionaryDetailScreen extends StatelessWidget {
  const DictionaryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.star_border, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.copy, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Word Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  blurSigma: 15,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TODO: Word',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t(context, 'dict_detail.label.pronunciation'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sections
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Basic Section
                      DictSectionCard.withText(
                        title: t(context, 'dict_detail.section.basic'),
                        text: '', // TODO
                      ),

                      // Sense Section
                      DictSectionCard.withList(
                        title: t(context, 'dict_detail.section.sense'),
                        children: [
                          // TODO: 多义项列表
                          const Text('TODO: Sense 1', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 8),
                          const Text('TODO: Sense 2', style: TextStyle(color: Colors.white)),
                        ],
                      ),

                      // Professional Section
                      DictSectionCard.withText(
                        title: t(context, 'dict_detail.section.professional'),
                        text: '', // TODO
                      ),

                      // Examples Section
                      DictSectionCard(
                        title: t(context, 'dict_detail.section.examples'),
                        child: Column(
                          children: [
                            // TODO: 例句列表
                            _ExampleItem(
                              original: 'TODO: Original',
                              translated: 'TODO: Translated',
                              onRead: () {},
                            ),
                            const Divider(color: Colors.white24),
                            _ExampleItem(
                              original: 'TODO: Original',
                              translated: 'TODO: Translated',
                              onRead: () {},
                            ),
                          ],
                        ),
                      ),

                      // Related Section
                      DictSectionCard(
                        title: t(context, 'dict_detail.section.related'),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // TODO: 相关词Chip列表
                            _RelatedChip(word: 'TODO'),
                            _RelatedChip(word: 'TODO'),
                            _RelatedChip(word: 'TODO'),
                          ],
                        ),
                      ),

                      // Source Section
                      DictSectionCard.withText(
                        title: t(context, 'dict_detail.label.source'),
                        text: '', // TODO
                      ),

                      const SizedBox(height: 24),
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

class _ExampleItem extends StatelessWidget {
  final String original;
  final String translated;
  final VoidCallback? onRead;

  const _ExampleItem({
    required this.original,
    required this.translated,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  original,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translated,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (onRead != null)
            IconButton(
              onPressed: onRead,
              icon: const Icon(Icons.volume_up, size: 20, color: Colors.white70),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _RelatedChip extends StatelessWidget {
  final String word;

  const _RelatedChip({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        word,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
