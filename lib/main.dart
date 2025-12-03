import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n/localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/translate_result_screen.dart';
import 'screens/conversation_screen.dart';
import 'screens/voice_input_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/ocr_result_screen.dart';
import 'screens/dictionary_home_screen.dart';
import 'screens/dictionary_detail_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/language_switcher_page.dart';

void main() {
  runApp(const UyghurTranslatorApp());
}

class UyghurTranslatorApp extends StatefulWidget {
  const UyghurTranslatorApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_UyghurTranslatorAppState>();
    state?.setLocale(locale);
  }

  static Locale getLocale(BuildContext context) {
    final state = context.findAncestorStateOfType<_UyghurTranslatorAppState>();
    return state?._locale ?? const Locale('zh');
  }

  @override
  State<UyghurTranslatorApp> createState() => _UyghurTranslatorAppState();
}

class _UyghurTranslatorAppState extends State<UyghurTranslatorApp> {
  Locale _locale = const Locale('zh');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  bool get isRTL => _locale.languageCode == 'ug';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(_locale.languageCode), // 强制重建
      title: 'Uyghur Translator',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('zh'),
        Locale('ug'),
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (context, child) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/translate_result': (context) => const TranslateResultScreen(),
        '/conversation': (context) => const ConversationScreen(),
        '/voice_input': (context) => const VoiceInputScreen(),
        '/camera': (context) => const CameraScreen(),
        '/ocr_result': (context) => const OcrResultScreen(),
        '/dictionary': (context) => const DictionaryHomeScreen(),
        '/dictionary_detail': (context) => const DictionaryDetailScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/language_switcher': (context) => const LanguageSwitcherPage(),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // RTL时使用Noto Sans Arabic Uyghur字体
      fontFamily: isRTL ? 'NotoSansArabicUyghur' : 'Roboto',
      // Coral主题色
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF7F50), // Coral
        brightness: brightness,
        primary: const Color(0xFFFF7F50),
        secondary: const Color(0xFFFF6B6B),
        surface: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        onSurface: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: !isRTL, // RTL时左对齐(实际显示右对齐)
        titleTextStyle: TextStyle(
          fontFamily: isRTL ? 'NotoSansArabicUyghur' : 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      // 文本主题
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: isRTL ? 'NotoSansArabicUyghur' : 'Roboto',
        ),
        bodyLarge: TextStyle(
          fontFamily: isRTL ? 'NotoSansArabicUyghur' : 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontFamily: isRTL ? 'NotoSansArabicUyghur' : 'Roboto',
        ),
      ),
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

/// RTL-aware Row helper - 自动镜像mainAxisAlignment
class RTLRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const RTLRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    MainAxisAlignment effectiveAlignment = mainAxisAlignment;
    if (isRTL) {
      switch (mainAxisAlignment) {
        case MainAxisAlignment.start:
          effectiveAlignment = MainAxisAlignment.end;
          break;
        case MainAxisAlignment.end:
          effectiveAlignment = MainAxisAlignment.start;
          break;
        default:
          break;
      }
    }

    return Row(
      mainAxisAlignment: effectiveAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}
