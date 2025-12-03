import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/language_switch_bar.dart';
import '../widgets/mode_segmented_control.dart';
import '../i18n/localizations.dart';

/// HomeScreen: 主页
/// AppBar + LanguageSwitchBar + ModeSegmentedControl + TextField + 底部按钮行
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  int _selectedMode = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTranslate() {
    // TODO: 实现翻译逻辑
    Navigator.pushNamed(context, '/translate_result');
  }

  void _onMicTap() {
    Navigator.pushNamed(context, '/voice_input');
  }

  void _onCameraTap() {
    Navigator.pushNamed(context, '/camera');
  }

  void _onSwapLanguages() {
    // TODO: 实现语言交换
  }

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
              Color(0xFFFFA07A),
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
                    Text(
                      t(context, 'home.title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/history'),
                      icon: const Icon(Icons.history, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Language Switch Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LanguageSwitchBar(
                  sourceLanguage: '', // TODO
                  targetLanguage: '', // TODO
                  onSwapTap: _onSwapLanguages,
                ),
              ),

              const SizedBox(height: 16),

              // Mode Segmented Control
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ModeSegmentedControl(
                  selectedIndex: _selectedMode,
                  onChanged: (index) {
                    setState(() => _selectedMode = index);
                    if (index == 1) _onMicTap();
                    if (index == 2) _onCameraTap();
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Main Input Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    blurSigma: 15,
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: t(context, 'home.input.placeholder'),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black38,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: t(context, 'home.button.translate'),
                        icon: Icons.translate,
                        onPressed: _onTranslate,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassButton(
                      text: '',
                      icon: Icons.mic,
                      iconOnly: true,
                      onPressed: _onMicTap,
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                    const SizedBox(width: 12),
                    GlassButton(
                      text: '',
                      icon: Icons.camera_alt,
                      iconOnly: true,
                      onPressed: _onCameraTap,
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ],
                ),
              ),

              // Bottom Navigation
              GlassCard(
                borderRadius: 0,
                blurSigma: 20,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home,
                      isActive: true,
                      onTap: () {},
                    ),
                    _BottomNavItem(
                      icon: Icons.chat,
                      onTap: () => Navigator.pushNamed(context, '/conversation'),
                    ),
                    _BottomNavItem(
                      icon: Icons.book,
                      onTap: () => Navigator.pushNamed(context, '/dictionary'),
                    ),
                    _BottomNavItem(
                      icon: Icons.person,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white60,
        size: 26,
      ),
    );
  }
}
