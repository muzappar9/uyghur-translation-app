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
                        '你好',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${t(context, 'dict_detail.label.pronunciation')}: nǐ hǎo',
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
                        text: 'سالام - 问候语，用于见面时打招呼',
                      ),

                      // Sense Section
                      DictSectionCard.withList(
                        title: t(context, 'dict_detail.section.sense'),
                        children: const [
                          Text('1. [感叹词] 问候语，见面打招呼时使用',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 8),
                          Text('2. [动词] 向某人问好',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),

                      // Professional Section
                      DictSectionCard.withText(
                        title: t(context, 'dict_detail.section.professional'),
                        text: '日常用语，在维吾尔族地区广泛使用',
                      ),

                      // Examples Section
                      DictSectionCard(
                        title: t(context, 'dict_detail.section.examples'),
                        child: Column(
                          children: [
                            _ExampleItem(
                              original: '你好，请问您贵姓？',
                              translated: 'سالام، فامىلىڭىز نېمە؟',
                              onRead: () {},
                            ),
                            const Divider(color: Colors.white24),
                            _ExampleItem(
                              original: '你好！今天天气真好。',
                              translated: 'سالام! بۈگۈن ھاۋا ناھايىتى ياخشى.',
                              onRead: () {},
                            ),
                          ],
                        ),
                      ),

                      // Related Section
                      DictSectionCard(
                        title: t(context, 'dict_detail.section.related'),
                        child: const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _RelatedChip(word: '您好'),
                            _RelatedChip(word: '早上好'),
                            _RelatedChip(word: '晚上好'),
                          ],
                        ),
                      ),

                      // Source Section
                      DictSectionCard.withText(
                        title: t(context, 'dict_detail.label.source'),
                        text: '新编维汉词典',
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
              icon:
                  const Icon(Icons.volume_up, size: 20, color: Colors.white70),
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
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        word,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
