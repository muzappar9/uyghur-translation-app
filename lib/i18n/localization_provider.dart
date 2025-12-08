/// 国际化提供者
///
/// 提供语言切换和国际化状态管理
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 支持的语言列表
enum AppLanguage {
  /// 简体中文
  zhCN('zh', 'CN', '简体中文', '中文'),

  /// 维吾尔语
  ug('ug', '', 'ئۇيغۇرچە', 'Uyghur'),

  /// 英语
  en('en', 'US', 'English', 'English'),

  /// 俄语
  ru('ru', '', 'Русский', 'Russian'),

  /// 哈萨克语
  kk('kk', '', 'Қазақша', 'Kazakh'),

  /// 柯尔克孜语
  ky('ky', '', 'Кыргызча', 'Kyrgyz'),

  /// 土耳其语
  tr('tr', '', 'Türkçe', 'Turkish');

  final String languageCode;
  final String countryCode;
  final String nativeName;
  final String englishName;

  const AppLanguage(
      this.languageCode, this.countryCode, this.nativeName, this.englishName);

  Locale get locale => countryCode.isNotEmpty
      ? Locale(languageCode, countryCode)
      : Locale(languageCode);

  /// 从 Locale 获取 AppLanguage
  static AppLanguage fromLocale(Locale locale) {
    for (final lang in AppLanguage.values) {
      if (lang.languageCode == locale.languageCode) {
        return lang;
      }
    }
    return AppLanguage.zhCN; // 默认中文
  }

  /// 从语言代码获取
  static AppLanguage fromCode(String code) {
    for (final lang in AppLanguage.values) {
      if (lang.languageCode == code) {
        return lang;
      }
    }
    return AppLanguage.zhCN;
  }
}

/// 国际化状态
class LocalizationState {
  final AppLanguage currentLanguage;
  final AppLanguage? fallbackLanguage;
  final bool isLoading;
  final List<AppLanguage> availableLanguages;

  const LocalizationState({
    this.currentLanguage = AppLanguage.zhCN,
    this.fallbackLanguage = AppLanguage.zhCN,
    this.isLoading = false,
    this.availableLanguages = const [
      AppLanguage.zhCN,
      AppLanguage.ug,
      AppLanguage.en,
    ],
  });

  Locale get locale => currentLanguage.locale;

  LocalizationState copyWith({
    AppLanguage? currentLanguage,
    AppLanguage? fallbackLanguage,
    bool? isLoading,
    List<AppLanguage>? availableLanguages,
  }) {
    return LocalizationState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      fallbackLanguage: fallbackLanguage ?? this.fallbackLanguage,
      isLoading: isLoading ?? this.isLoading,
      availableLanguages: availableLanguages ?? this.availableLanguages,
    );
  }
}

/// 国际化服务
class LocalizationService {
  static const String _boxName = 'localization_prefs';
  static const String _languageKey = 'current_language';

  Box<String>? _box;
  bool _isInitialized = false;

  /// 初始化
  Future<void> initialize() async {
    if (_isInitialized) return;
    _box = await Hive.openBox<String>(_boxName);
    _isInitialized = true;
  }

  /// 获取保存的语言
  Future<AppLanguage?> getSavedLanguage() async {
    await _ensureInitialized();
    final code = _box?.get(_languageKey);
    if (code != null) {
      return AppLanguage.fromCode(code);
    }
    return null;
  }

  /// 保存语言
  Future<void> saveLanguage(AppLanguage language) async {
    await _ensureInitialized();
    await _box?.put(_languageKey, language.languageCode);
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// 获取系统语言
  AppLanguage getSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return AppLanguage.fromLocale(systemLocale);
  }

  void dispose() {
    _box?.close();
  }
}

/// 国际化服务提供者
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  final service = LocalizationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 国际化状态管理器
class LocalizationNotifier extends AsyncNotifier<LocalizationState> {
  @override
  Future<LocalizationState> build() async {
    final service = ref.watch(localizationServiceProvider);
    await service.initialize();

    // 尝试获取保存的语言
    final saved = await service.getSavedLanguage();
    if (saved != null) {
      return LocalizationState(currentLanguage: saved);
    }

    // 使用系统语言或默认语言
    final system = service.getSystemLanguage();
    return LocalizationState(currentLanguage: system);
  }

  /// 切换语言
  Future<void> changeLanguage(AppLanguage language) async {
    final current = state.valueOrNull ?? const LocalizationState();
    state = AsyncValue.data(current.copyWith(isLoading: true));

    try {
      final service = ref.read(localizationServiceProvider);
      await service.saveLanguage(language);

      state = AsyncValue.data(current.copyWith(
        currentLanguage: language,
        isLoading: false,
      ));
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// 重置为系统语言
  Future<void> resetToSystemLanguage() async {
    final service = ref.read(localizationServiceProvider);
    final system = service.getSystemLanguage();
    await changeLanguage(system);
  }
}

/// 国际化状态提供者
final localizationProvider =
    AsyncNotifierProvider<LocalizationNotifier, LocalizationState>(
  () => LocalizationNotifier(),
);

/// 当前语言提供者
final currentLanguageProvider = Provider<AppLanguage>((ref) {
  final state = ref.watch(localizationProvider);
  return state.when(
    data: (data) => data.currentLanguage,
    loading: () => AppLanguage.zhCN,
    error: (_, __) => AppLanguage.zhCN,
  );
});

/// 当前 Locale 提供者
final currentLocaleProvider = Provider<Locale>((ref) {
  final language = ref.watch(currentLanguageProvider);
  return language.locale;
});
