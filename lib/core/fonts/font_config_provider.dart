/// 字体配置状态管理
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fonts/font_config.dart';

/// 字体配置状态类
class FontConfigState {
  final FontConfig config;
  final bool isLoading;
  final String? error;

  const FontConfigState({
    required this.config,
    this.isLoading = false,
    this.error,
  });

  FontConfigState copyWith({
    FontConfig? config,
    bool? isLoading,
    String? error,
  }) {
    return FontConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 字体配置 Notifier
class FontConfigNotifier extends StateNotifier<FontConfigState> {
  FontConfigNotifier() : super(const FontConfigState(
    config: FontConfig(),
  )) {
    _loadConfig();
  }

  /// SharedPreferences 键
  static const String _keyUyghurFont = 'font_uyghur';
  static const String _keyChineseFont = 'font_chinese';
  static const String _keyFontSize = 'font_size';
  static const String _keyLineHeight = 'font_line_height';

  /// 加载保存的字体配置 (优化：延迟加载)
  Future<void> _loadConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      // 优化：使用异步获取SharedPreferences，避免阻塞
      final prefs = await SharedPreferences.getInstance();

      // 优化：使用更高效的查找方式
      AlkatipFont uyghurFont = AlkatipFont.standard;
      final uyghurFontName = prefs.getString(_keyUyghurFont);
      if (uyghurFontName != null) {
        try {
          uyghurFont = AlkatipFont.values.firstWhere(
            (f) => f.fontFamily == uyghurFontName,
          );
        } catch (_) {
          // 如果找不到，使用默认值
        }
      }

      ChineseFont chineseFont = ChineseFont.system;
      final chineseFontName = prefs.getString(_keyChineseFont);
      if (chineseFontName != null) {
        try {
          chineseFont = ChineseFont.values.firstWhere(
            (f) => f.fontFamily == chineseFontName,
          );
        } catch (_) {
          // 如果找不到，使用默认值
        }
      }

      // 读取字体大小和行高
      final fontSize = prefs.getDouble(_keyFontSize) ?? FontConstants.defaultFontSize;
      final lineHeight = prefs.getDouble(_keyLineHeight) ?? FontConstants.defaultLineHeight;

      state = state.copyWith(
        config: FontConfig(
          uyghurFont: uyghurFont,
          chineseFont: chineseFont,
          fontSize: fontSize,
          lineHeight: lineHeight,
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载字体配置失败: $e',
      );
    }
  }

  /// 设置维吾尔语字体
  Future<void> setUyghurFont(AlkatipFont font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUyghurFont, font.fontFamily);
    
    // 自动调整到推荐字体大小
    final recommendedSize = FontConstants.getRecommendedSize(font);
    await prefs.setDouble(_keyFontSize, recommendedSize);
    
    state = state.copyWith(
      config: state.config.copyWith(
        uyghurFont: font,
        fontSize: recommendedSize,
      ),
    );
  }

  /// 设置汉语字体
  Future<void> setChineseFont(ChineseFont font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChineseFont, font.fontFamily);
    
    state = state.copyWith(
      config: state.config.copyWith(chineseFont: font),
    );
  }

  /// 设置字体大小
  Future<void> setFontSize(double size) async {
    if (size < FontConstants.minFontSize || size > FontConstants.maxFontSize) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
    
    state = state.copyWith(
      config: state.config.copyWith(fontSize: size),
    );
  }

  /// 增加字体大小
  Future<void> increaseFontSize() async {
    final newSize = state.config.fontSize + FontConstants.fontSizeStep;
    await setFontSize(newSize);
  }

  /// 减少字体大小
  Future<void> decreaseFontSize() async {
    final newSize = state.config.fontSize - FontConstants.fontSizeStep;
    await setFontSize(newSize);
  }

  /// 设置行高
  Future<void> setLineHeight(double height) async {
    if (height < FontConstants.minLineHeight || height > FontConstants.maxLineHeight) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyLineHeight, height);
    
    state = state.copyWith(
      config: state.config.copyWith(lineHeight: height),
    );
  }

  /// 重置为默认配置
  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUyghurFont);
    await prefs.remove(_keyChineseFont);
    await prefs.remove(_keyFontSize);
    await prefs.remove(_keyLineHeight);
    
    state = state.copyWith(
      config: const FontConfig(),
    );
  }
}

/// 字体配置 Provider
final fontConfigProvider = StateNotifierProvider<FontConfigNotifier, FontConfigState>((ref) {
  return FontConfigNotifier();
});

/// 当前字体配置 Provider（便捷访问）
final currentFontConfigProvider = Provider<FontConfig>((ref) {
  return ref.watch(fontConfigProvider).config;
});

/// 维吾尔语字体 Provider
final uyghurFontProvider = Provider<AlkatipFont>((ref) {
  return ref.watch(fontConfigProvider).config.uyghurFont;
});

/// 汉语字体 Provider
final chineseFontProvider = Provider<ChineseFont>((ref) {
  return ref.watch(fontConfigProvider).config.chineseFont;
});

/// 字体大小 Provider
final fontSizeProvider = Provider<double>((ref) {
  return ref.watch(fontConfigProvider).config.fontSize;
});

/// 行高 Provider
final lineHeightProvider = Provider<double>((ref) {
  return ref.watch(fontConfigProvider).config.lineHeight;
});
