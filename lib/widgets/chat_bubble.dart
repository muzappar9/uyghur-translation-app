import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../i18n/localizations.dart';

/// ChatBubble: 对话气泡组件
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Alignment (Left/Right) | Light/Dark | With/Without Actions
/// - Import to Figma: Use Auto Layout (V:Top, gap:8), 
///   main bubble frame + actions row frame,
///   RTL variant mirrors alignment + icon positions via direction prop
class ChatBubble extends StatelessWidget {
  final String originalText;
  final String translatedText;
  final bool isLeft;
  final VoidCallback? onReadOriginal;
  final VoidCallback? onReadTranslated;
  final VoidCallback? onCopy;

  const ChatBubble({
    super.key,
    required this.originalText,
    required this.translatedText,
    this.isLeft = true,
    this.onReadOriginal,
    this.onReadTranslated,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // RTL时镜像对齐
    final effectiveIsLeft = isRTL ? !isLeft : isLeft;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: effectiveIsLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 20,
          backgroundColor: effectiveIsLeft
              ? (isDark ? const Color(0x4D000000) : const Color(0x80FFFFFF))
              : primaryColor.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      originalText.isNotEmpty ? originalText : '...',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  if (onReadOriginal != null)
                    IconButton(
                      onPressed: onReadOriginal,
                      icon: const Icon(Icons.volume_up, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: t(context, 'result.action.read'),
                    ),
                ],
              ),
              
              const Divider(height: 16),
              
              // Translated Text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      translatedText.isNotEmpty ? translatedText : '...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  if (onReadTranslated != null)
                    IconButton(
                      onPressed: onReadTranslated,
                      icon: const Icon(Icons.volume_up, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: t(context, 'result.action.read'),
                    ),
                ],
              ),
              
              // Actions
              if (onCopy != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: t(context, 'result.action.copy'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
