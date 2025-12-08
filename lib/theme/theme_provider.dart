/// 主题提供者
///
/// 管理应用主题状态和切换
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

/// 主题模式
enum AppThemeMode {
  /// 跟随系统
  system,

  /// 亮色
  light,

  /// 暗色
  dark,
}

/// 主题状态
class ThemeState {
  final AppThemeMode mode;
  final Color? seedColor;
  final bool useDynamicColor;

  const ThemeState({
    this.mode = AppThemeMode.system,
    this.seedColor,
    this.useDynamicColor = true,
  });

  ThemeMode get themeMode {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme => AppTheme.light(seedColor: seedColor);
  ThemeData get darkTheme => AppTheme.dark(seedColor: seedColor);

  ThemeState copyWith({
    AppThemeMode? mode,
    Color? seedColor,
    bool? useDynamicColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }
}

/// 主题服务
class ThemeService {
  static const String _boxName = 'theme_prefs';
  static const String _modeKey = 'theme_mode';
  static const String _seedColorKey = 'seed_color';
  static const String _dynamicColorKey = 'dynamic_color';

  Box<dynamic>? _box;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  Future<ThemeState> loadState() async {
    await _ensureInitialized();

    final modeIndex = _box?.get(_modeKey, defaultValue: 0) as int;
    final colorValue = _box?.get(_seedColorKey) as int?;
    final useDynamic = _box?.get(_dynamicColorKey, defaultValue: true) as bool;

    return ThemeState(
      mode: AppThemeMode.values[modeIndex],
      seedColor: colorValue != null ? Color(colorValue) : null,
      useDynamicColor: useDynamic,
    );
  }

  Future<void> saveMode(AppThemeMode mode) async {
    await _ensureInitialized();
    await _box?.put(_modeKey, mode.index);
  }

  Future<void> saveSeedColor(Color? color) async {
    await _ensureInitialized();
    if (color != null) {
      await _box?.put(_seedColorKey, color.toARGB32());
    } else {
      await _box?.delete(_seedColorKey);
    }
  }

  Future<void> saveUseDynamicColor(bool value) async {
    await _ensureInitialized();
    await _box?.put(_dynamicColorKey, value);
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  void dispose() {
    _box?.close();
  }
}

/// 主题服务提供者
final themeServiceProvider = Provider<ThemeService>((ref) {
  final service = ThemeService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 主题状态管理器
class ThemeNotifier extends AsyncNotifier<ThemeState> {
  @override
  Future<ThemeState> build() async {
    final service = ref.watch(themeServiceProvider);
    await service.initialize();
    return service.loadState();
  }

  /// 设置主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = state.valueOrNull ?? const ThemeState();
    state = AsyncValue.data(current.copyWith(mode: mode));

    final service = ref.read(themeServiceProvider);
    await service.saveMode(mode);
  }

  /// 设置种子颜色
  Future<void> setSeedColor(Color? color) async {
    final current = state.valueOrNull ?? const ThemeState();
    state = AsyncValue.data(current.copyWith(seedColor: color));

    final service = ref.read(themeServiceProvider);
    await service.saveSeedColor(color);
  }

  /// 设置是否使用动态颜色
  Future<void> setUseDynamicColor(bool value) async {
    final current = state.valueOrNull ?? const ThemeState();
    state = AsyncValue.data(current.copyWith(useDynamicColor: value));

    final service = ref.read(themeServiceProvider);
    await service.saveUseDynamicColor(value);
  }

  /// 切换深色模式
  Future<void> toggleDarkMode() async {
    final current = state.valueOrNull ?? const ThemeState();
    final newMode = current.mode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// 重置为系统默认
  Future<void> resetToSystem() async {
    await setThemeMode(AppThemeMode.system);
    await setSeedColor(null);
  }
}

/// 主题状态提供者
final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(
  () => ThemeNotifier(),
);

/// 当前主题模式提供者
final themeModeProvider = Provider<ThemeMode>((ref) {
  final state = ref.watch(themeProvider);
  return state.when(
    data: (data) => data.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});

/// 亮色主题提供者
final lightThemeProvider = Provider<ThemeData>((ref) {
  final state = ref.watch(themeProvider);
  return state.when(
    data: (data) => data.lightTheme,
    loading: () => AppTheme.light(),
    error: (_, __) => AppTheme.light(),
  );
});

/// 暗色主题提供者
final darkThemeProvider = Provider<ThemeData>((ref) {
  final state = ref.watch(themeProvider);
  return state.when(
    data: (data) => data.darkTheme,
    loading: () => AppTheme.dark(),
    error: (_, __) => AppTheme.dark(),
  );
});

/// 是否为暗色模式提供者
final isDarkModeProvider = Provider<bool>((ref) {
  final state = ref.watch(themeProvider);
  return state.when(
    data: (data) => data.mode == AppThemeMode.dark,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// 预设颜色列表
const List<Color> presetColors = [
  AppColors.primary,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.red,
  Colors.pink,
  Colors.brown,
  Colors.blueGrey,
];
