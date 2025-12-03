import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../i18n/localizations.dart';

/// LanguageSwitchBar: 源语言/交换/目标语言切换栏
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Expanded/Compact | Active Source/Target
/// - Import to Figma: Use Auto Layout (H:Space Between), 
///   3 frames (source btn | swap icon | target btn),
///   RTL variant mirrors order automatically via direction prop
class LanguageSwitchBar extends StatelessWidget {
  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback? onSourceTap;
  final VoidCallback? onTargetTap;
  final VoidCallback? onSwapTap;

  const LanguageSwitchBar({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.onSourceTap,
    this.onTargetTap,
    this.onSwapTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Source Language Button
          Expanded(
            child: _LanguageButton(
              label: sourceLanguage.isEmpty ? t(context, 'home.lang.source') : sourceLanguage,
              onTap: onSourceTap,
              isActive: true,
            ),
          ),
          
          // Swap Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: onSwapTap,
              icon: Icon(
                isRTL ? Icons.swap_horiz : Icons.swap_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: t(context, 'home.lang.swap'),
            ),
          ),
          
          // Target Language Button
          Expanded(
            child: _LanguageButton(
              label: targetLanguage.isEmpty ? t(context, 'home.lang.target') : targetLanguage,
              onTap: onTargetTap,
              isActive: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _LanguageButton({
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
