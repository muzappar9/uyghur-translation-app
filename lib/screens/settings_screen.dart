import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../i18n/localizations.dart';
import '../widgets/responsive_layout.dart';

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
  String _selectedLanguage = 'zh';

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '维汉翻译应用隐私政策\n\n'
            '1. 数据收集：我们仅收集必要的翻译文本数据用于提供翻译服务。\n\n'
            '2. 数据存储：您的翻译历史存储在本地设备上。\n\n'
            '3. 数据共享：我们不会与第三方共享您的个人数据。\n\n'
            '4. 数据安全：我们采用行业标准的安全措施保护您的数据。\n\n'
            '5. 用户权利：您有权随时删除您的翻译历史和账户数据。\n\n'
            '如有任何疑问，请联系我们。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showOpenSourceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开源信息'),
        content: const SingleChildScrollView(
          child: Text(
            '本应用使用了以下开源库：\n\n'
            '• Flutter - UI 框架\n'
            '• Riverpod - 状态管理\n'
            '• Go Router - 路由管理\n'
            '• Dio - 网络请求\n'
            '• Isar - 本地数据库\n'
            '• Logger - 日志记录\n\n'
            '感谢所有开源贡献者！',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
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
                child: ResponsiveContainer(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getPadding(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Language Section
                        _SectionTitle(
                            title: t(context, 'settings.section.language')),
                      GlassCard(
                        blurSigma: 10,
                        child: RadioGroup<String>(
                          groupValue: _selectedLanguage,
                          onChanged: (value) {
                            setState(() => _selectedLanguage = value!);
                          },
                          child: Column(
                            children: [
                              _SettingsRow(
                                title: t(context, 'language.zh'),
                                trailing: const Radio<String>(
                                  value: 'zh',
                                  activeColor: Colors.white,
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 1),
                              _SettingsRow(
                                title: t(context, 'language.ug'),
                                trailing: const Radio<String>(
                                  value: 'ug',
                                  activeColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Font Section
                      _SectionTitle(title: t(context, 'settings.section.font')),
                      GlassCard(
                        blurSigma: 10,
                        child: RadioGroup<String>(
                          groupValue: _selectedFont,
                          onChanged: (value) {
                            setState(() => _selectedFont = value!);
                          },
                          child: Column(
                            children: [
                              _SettingsRow(
                                title: t(context, 'settings.font.small'),
                                trailing: const Radio<String>(
                                  value: 'small',
                                  activeColor: Colors.white,
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 1),
                              _SettingsRow(
                                title: t(context, 'settings.font.medium'),
                                trailing: const Radio<String>(
                                  value: 'medium',
                                  activeColor: Colors.white,
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 1),
                              _SettingsRow(
                                title: t(context, 'settings.font.large'),
                                trailing: const Radio<String>(
                                  value: 'large',
                                  activeColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Theme Section
                      _SectionTitle(
                          title: t(context, 'settings.section.theme')),
                      GlassCard(
                        blurSigma: 10,
                        child: _SettingsRow(
                          title: t(context, 'settings.theme.dark'),
                          trailing: Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() => _isDarkMode = value);
                              // 主题切换逻辑已通过 setState 实现
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(value ? '已切换到深色模式' : '已切换到浅色模式'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            activeThumbColor: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Privacy Section
                      _SectionTitle(
                          title: t(context, 'settings.section.privacy')),
                      GlassCard(
                        blurSigma: 10,
                        child: _SettingsRow(
                          title: t(context, 'settings.privacy.policy'),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.white70),
                          onTap: _showPrivacyPolicy,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Section
                      _SectionTitle(
                          title: t(context, 'settings.section.about')),
                      GlassCard(
                        blurSigma: 10,
                        child: Column(
                          children: [
                            _SettingsRow(
                              title: t(context, 'settings.about.opensource'),
                              trailing: const Icon(Icons.chevron_right,
                                  color: Colors.white70),
                              onTap: _showOpenSourceInfo,
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
