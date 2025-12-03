import 'dart:ui';
import 'package:flutter/material.dart';
import '../i18n/localizations.dart';

/// ModeSegmentedControl: 翻译模式切换控件
/// Figma Variant Specs:
/// - Variant: LTR/RTL | Selected Tab (Text/Voice/Camera/Document) | Light/Dark
/// - Import to Figma: Use Auto Layout (H:Fill, gap:4), 4 tab frames,
///   selected state has Glass fill + border highlight,
///   RTL variant reverses tab order via direction prop
class ModeSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const ModeSegmentedControl({
    super.key,
    this.selectedIndex = 0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = [
      _ModeItem(icon: Icons.text_fields, labelKey: 'home.mode.text'),
      _ModeItem(icon: Icons.mic, labelKey: 'home.mode.voice'),
      _ModeItem(icon: Icons.camera_alt, labelKey: 'home.mode.camera'),
      _ModeItem(icon: Icons.description, labelKey: 'home.mode.document'),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x33000000) : const Color(0x4DFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: List.generate(modes.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: _ModeTab(
                  icon: modes[index].icon,
                  label: t(context, modes[index].labelKey),
                  isSelected: isSelected,
                  onTap: () => onChanged?.call(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ModeItem {
  final IconData icon;
  final String labelKey;

  _ModeItem({required this.icon, required this.labelKey});
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.8))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black54),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
