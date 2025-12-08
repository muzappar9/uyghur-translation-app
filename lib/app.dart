import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uyghur_translator/routes/app_router.dart';
import 'package:uyghur_translator/shared/providers/app_providers.dart';
import 'package:uyghur_translator/shared/providers/network_provider.dart';
import 'package:uyghur_translator/shared/services/translation_service.dart';
import 'package:uyghur_translator/shared/services/storage/preference_service.dart';
import 'package:uyghur_translator/i18n/localizations.dart';
import 'package:uyghur_translator/theme/app_theme.dart';
import 'package:uyghur_translator/widgets/offline_indicator.dart';
import 'package:uyghur_translator/core/network/offline_mode_service.dart';

/// 主应用 Widget
class MyApp extends ConsumerStatefulWidget {
  final PreferenceService prefService;

  const MyApp({super.key, required this.prefService});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // 初始化应用状态
    Future.microtask(() async {
      final notifier = ref.read(appStateProvider.notifier);

      notifier.setLanguage(widget.prefService.getLanguage());
      notifier.setDarkMode(widget.prefService.isDarkMode());

      // 监听网络状态变化
      ref.listen(networkConnectivityProvider, (previous, next) {
        next.whenData((status) {
          final isOnline = status == NetworkStatus.online;
          notifier.setOnlineStatus(isOnline);

          // 如果从离线变为在线，处理待同步队列
          if (previous == null ||
              (previous.asData?.value != NetworkStatus.online &&
                  status == NetworkStatus.online)) {
            // 触发待同步翻译处理
            ref.read(translationServiceProvider).processPendingTranslations();
          }
        });
      });
        // 保证离线模式状态管理器启动
        ref.read(offlineModeProvider);

      // 标记初始化完成
      notifier.markInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(
      appStateProvider.select((state) => state.isDarkMode),
    );
    final currentLanguage = ref.watch(
      appStateProvider.select((state) => state.currentLanguage),
    );

    return MaterialApp.router(
      title: 'Uyghur Translator',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        final routerChild = child ?? const SizedBox.shrink();
        return OfflineBanner(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: routerChild),
              const Positioned(
                top: 16,
                right: 16,
                child: SyncStatusIndicator(),
              ),
            ],
          ),
        );
      },
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('ug', 'CN'),
      ],
      locale: currentLanguage == 'ug'
          ? const Locale('ug', 'CN')
          : const Locale('zh', 'CN'),
    );
  }
}
