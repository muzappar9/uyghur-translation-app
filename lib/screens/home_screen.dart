import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/language_switch_bar.dart';
import '../widgets/mode_segmented_control.dart';
import '../i18n/localizations.dart';
import '../core/animations/animations.dart';
import '../core/performance/performance_monitor.dart';

/// HomeScreen: 主页
/// 升级: Stage 19 添加动画和微交互
/// AppBar + LanguageSwitchBar + ModeSegmentedControl + TextField + 底部按钮行
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _sourceLanguage = 'zh';
  String _targetLanguage = 'ug';
  int _selectedMode = 0;
  bool _isFocused = false;
  int _currentNavIndex = 0;
  final _perfMonitor = PerformanceMonitor();

  // 动画控制器
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _perfMonitor.startTimer('home_screen_init');
    _focusNode.addListener(_onFocusChange);

    // 初始化页面淡入动画
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimationDuration.medium,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _perfMonitor.endTimer('home_screen_init');
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTranslate() {
    if (_textController.text.isNotEmpty) {
      Navigator.pushNamed(context, '/translate_result', arguments: {
        'text': _textController.text,
        'source': _sourceLanguage,
        'target': _targetLanguage,
      });
    }
  }

  void _onMicTap() {
    Navigator.pushNamed(context, '/voice_input');
  }

  void _onCameraTap() {
    Navigator.pushNamed(context, '/camera');
  }

  void _onSwapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
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
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Language Switch Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LanguageSwitchBar(
                  sourceLanguage: _sourceLanguage,
                  targetLanguage: _targetLanguage,
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

              // Main Input Area with Focus Animation
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedInputContainer(
                      isFocused: _isFocused,
                      focusColor: Colors.white,
                      child: GlassCard(
                        blurSigma: 15,
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
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
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Action Buttons with Staggered Animation
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StaggeredListItem(
                        index: 0,
                        direction: Axis.horizontal,
                        child: GlassButton(
                          text: t(context, 'home.button.translate'),
                          icon: Icons.translate,
                          onPressed: _onTranslate,
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    StaggeredListItem(
                      index: 1,
                      direction: Axis.horizontal,
                      child: GlassButton(
                        text: '',
                        icon: Icons.mic,
                        iconOnly: true,
                        onPressed: _onMicTap,
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    StaggeredListItem(
                      index: 2,
                      direction: Axis.horizontal,
                      child: GlassButton(
                        text: '',
                        icon: Icons.camera_alt,
                        iconOnly: true,
                        onPressed: _onCameraTap,
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Navigation with Animation
              GlassCard(
                borderRadius: 0,
                blurSigma: 20,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AnimatedBottomNavItem(
                      icon: Icons.home,
                      isActive: _currentNavIndex == 0,
                      onTap: () => setState(() => _currentNavIndex = 0),
                    ),
                    AnimatedBottomNavItem(
                      icon: Icons.chat,
                      isActive: _currentNavIndex == 1,
                      onTap: () {
                        setState(() => _currentNavIndex = 1);
                        Navigator.pushNamed(context, '/conversation');
                      },
                    ),
                    AnimatedBottomNavItem(
                      icon: Icons.book,
                      isActive: _currentNavIndex == 2,
                      onTap: () {
                        setState(() => _currentNavIndex = 2);
                        Navigator.pushNamed(context, '/dictionary');
                      },
                    ),
                    AnimatedBottomNavItem(
                      icon: Icons.person,
                      isActive: _currentNavIndex == 3,
                      onTap: () {
                        setState(() => _currentNavIndex = 3);
                        Navigator.pushNamed(context, '/settings');
                      },
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

// _BottomNavItem class removed - using AnimatedBottomNavItem instead
