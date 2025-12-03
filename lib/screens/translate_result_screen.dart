import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../i18n/localizations.dart';

/// TranslateResultScreen: 翻译结果页
/// 源Card + 目标Card + 底部按钮
class TranslateResultScreen extends StatelessWidget {
  const TranslateResultScreen({super.key});

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
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // TODO: 分享功能
                      },
                      icon: const Icon(Icons.share, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Source Card
                      GlassCard(
                        blurSigma: 15,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  t(context, 'result.source.title'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.volume_up, size: 20, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: t(context, 'result.action.read'),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.copy, size: 20, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: t(context, 'result.action.copy'),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.star_border, size: 20, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: t(context, 'result.action.favorite'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'TODO: Source Text',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Target Card
                      GlassCard(
                        blurSigma: 15,
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  t(context, 'result.target.title'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.volume_up, size: 20, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.copy, size: 20, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.share, size: 20, color: Colors.white70),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'TODO: Target Text',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'result.button.new'),
                        icon: Icons.add,
                        onPressed: () => Navigator.pop(context),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'result.button.conversation'),
                        icon: Icons.chat,
                        onPressed: () => Navigator.pushNamed(context, '/conversation'),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'result.button.dictionary'),
                        icon: Icons.book,
                        onPressed: () => Navigator.pushNamed(context, '/dictionary'),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
