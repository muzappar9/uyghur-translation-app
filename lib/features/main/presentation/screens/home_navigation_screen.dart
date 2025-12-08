import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/features/translation/presentation/pages/translation_screen.dart';
import 'package:uyghur_translator/features/ocr/presentation/pages/ocr_screen.dart';
import 'settings_screen.dart';

/// 主应用导航屏幕
class HomeNavigationScreen extends ConsumerStatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  ConsumerState<HomeNavigationScreen> createState() =>
      _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends ConsumerState<HomeNavigationScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TranslationScreen(),
      const OcrScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: '翻译',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: '文字识别',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
