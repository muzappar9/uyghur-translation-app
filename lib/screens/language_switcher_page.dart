import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../i18n/localizations.dart';
import '../main.dart';

/// LanguageSwitcherPage: 语言切换页
/// 切换按钮 + 应用后rebuild App
class LanguageSwitcherPage extends StatefulWidget {
  const LanguageSwitcherPage({super.key});

  @override
  State<LanguageSwitcherPage> createState() => _LanguageSwitcherPageState();
}

class _LanguageSwitcherPageState extends State<LanguageSwitcherPage> {
  String _selectedLanguage = 'zh';

  void _applyLanguage() {
    final locale = Locale(_selectedLanguage);
    // 触发App重建以实现RTL安全切换
    UyghurTranslatorApp.setLocale(context, locale);
    Navigator.pop(context);
  }

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
                    const SizedBox(width: 8),
                    Text(
                      t(context, 'language.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Language Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _LanguageOption(
                      label: t(context, 'language.zh'),
                      subtitle: '中文',
                      isSelected: _selectedLanguage == 'zh',
                      onTap: () {
                        setState(() => _selectedLanguage = 'zh');
                      },
                    ),
                    const SizedBox(height: 16),
                    _LanguageOption(
                      label: t(context, 'language.ug'),
                      subtitle: 'ئۇيغۇرچە',
                      isSelected: _selectedLanguage == 'ug',
                      onTap: () {
                        setState(() => _selectedLanguage = 'ug');
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    text: t(context, 'language.button.apply'),
                    icon: Icons.check,
                    onPressed: _applyLanguage,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

class _LanguageOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguageOption({
    required this.label,
    required this.subtitle,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurSigma: 15,
      padding: const EdgeInsets.all(20),
      backgroundColor: isSelected
          ? Colors.white.withOpacity(0.3)
          : Colors.white.withOpacity(0.15),
      border: isSelected
          ? Border.all(color: Colors.white, width: 2)
          : Border.all(color: Colors.white.withOpacity(0.3)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
