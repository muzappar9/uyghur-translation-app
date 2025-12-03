import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../i18n/localizations.dart';

/// SettingsScreen: 设置页
/// 语言/字体/外观/隐私/关于分区
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedFont = 'medium';
  bool _isDarkMode = false;

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
                      t(context, 'settings.title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language Section
                      _SectionTitle(title: t(context, 'settings.section.language')),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            _SettingsRow(
                              title: t(context, 'language.zh'),
                              trailing: Radio<String>(
                                value: 'zh',
                                groupValue: 'zh', // TODO: 实际语言状态
                                onChanged: (value) {
                                  Navigator.pushNamed(context, '/language_switcher');
                                },
                                activeColor: Colors.white,
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            _SettingsRow(
                              title: t(context, 'language.ug'),
                              trailing: Radio<String>(
                                value: 'ug',
                                groupValue: 'zh', // TODO
                                onChanged: (value) {
                                  Navigator.pushNamed(context, '/language_switcher');
                                },
                                activeColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Font Section
                      _SectionTitle(title: t(context, 'settings.section.font')),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            _SettingsRow(
                              title: t(context, 'settings.font.small'),
                              trailing: Radio<String>(
                                value: 'small',
                                groupValue: _selectedFont,
                                onChanged: (value) {
                                  setState(() => _selectedFont = value!);
                                },
                                activeColor: Colors.white,
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            _SettingsRow(
                              title: t(context, 'settings.font.medium'),
                              trailing: Radio<String>(
                                value: 'medium',
                                groupValue: _selectedFont,
                                onChanged: (value) {
                                  setState(() => _selectedFont = value!);
                                },
                                activeColor: Colors.white,
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            _SettingsRow(
                              title: t(context, 'settings.font.large'),
                              trailing: Radio<String>(
                                value: 'large',
                                groupValue: _selectedFont,
                                onChanged: (value) {
                                  setState(() => _selectedFont = value!);
                                },
                                activeColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Theme Section
                      _SectionTitle(title: t(context, 'settings.section.theme')),
                      GlassCard(
                        blurSigma: 10,
                        child: _SettingsRow(
                          title: t(context, 'settings.theme.dark'),
                          trailing: Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() => _isDarkMode = value);
                              // TODO: 切换主题
                            },
                            activeColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Privacy Section
                      _SectionTitle(title: t(context, 'settings.section.privacy')),
                      GlassCard(
                        blurSigma: 10,
                        child: _SettingsRow(
                          title: t(context, 'settings.privacy.policy'),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                          onTap: () {
                            // TODO: 打开隐私政策
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Section
                      _SectionTitle(title: t(context, 'settings.section.about')),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            _SettingsRow(
                              title: t(context, 'settings.about.opensource'),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                              onTap: () {
                                // TODO: 打开开源信息
                              },
                            ),
                            const Divider(color: Colors.white24, height: 1),
                            _SettingsRow(
                              title: t(context, 'settings.about.version'),
                              trailing: const Text(
                                '1.0.0',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
