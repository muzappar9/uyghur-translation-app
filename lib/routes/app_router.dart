import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/shared/providers/app_providers.dart';
import 'package:uyghur_translator/routes/route_names.dart';

// 导入真实屏幕
import 'package:uyghur_translator/screens/splash_screen.dart';
import 'package:uyghur_translator/screens/home_screen.dart';
import 'package:uyghur_translator/screens/voice_input_screen.dart';
import 'package:uyghur_translator/screens/camera_screen.dart';
import 'package:uyghur_translator/screens/history_screen.dart';
import 'package:uyghur_translator/screens/dictionary_home_screen.dart';
import 'package:uyghur_translator/screens/dictionary_detail_screen.dart';
import 'package:uyghur_translator/screens/conversation_screen.dart';
import 'package:uyghur_translator/screens/settings_screen.dart';
import 'package:uyghur_translator/screens/onboarding_screen.dart';
import 'package:uyghur_translator/screens/translate_result_screen.dart';

/// GoRouter 实例 Provider
final routerProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // App 未初始化，显示 splash
      final path = state.path;
      if (!appState.isInitialized && !(path?.startsWith('/splash') ?? false)) {
        return '/splash';
      }

      return null; // 无需重定向
    },
    routes: [
      // ==================== Splash ====================
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: SplashScreen(),
          );
        },
      ),

      // ==================== Home ====================
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: HomeScreen(),
          );
        },
        routes: [
          GoRoute(
            path: 'translate-result',
            name: RouteNames.translateResult,
            pageBuilder: (context, state) {
              // 参数通过 extra 或 queryParameters 传递
              return const MaterialPage(
                child: TranslateResultScreen(),
              );
            },
          ),
        ],
      ),

      // ==================== Voice Input ====================
      GoRoute(
        path: '/voice-input',
        name: RouteNames.voiceInput,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: VoiceInputScreen(),
          );
        },
      ),

      // ==================== Camera ====================
      GoRoute(
        path: '/camera',
        name: RouteNames.camera,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: CameraScreen(),
          );
        },
      ),

      // ==================== History ====================
      GoRoute(
        path: '/history',
        name: RouteNames.history,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: HistoryScreen(),
          );
        },
      ),

      // ==================== Dictionary ====================
      GoRoute(
        path: '/dictionary',
        name: RouteNames.dictionary,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: DictionaryHomeScreen(),
          );
        },
        routes: [
          GoRoute(
            path: 'detail/:id',
            name: RouteNames.dictionaryDetail,
            pageBuilder: (context, state) {
              // wordId 暂时不使用，页面内部处理
              return const MaterialPage(
                child: DictionaryDetailScreen(),
              );
            },
          ),
        ],
      ),

      // ==================== Conversation ====================
      GoRoute(
        path: '/conversation',
        name: RouteNames.conversation,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: ConversationScreen(),
          );
        },
      ),

      // ==================== Settings ====================
      GoRoute(
        path: '/settings',
        name: RouteNames.settings,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: SettingsScreen(),
          );
        },
      ),

      // ==================== Onboarding ====================
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        pageBuilder: (context, state) {
          return const MaterialPage(
            child: OnboardingScreen(),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Error: ${state.error ?? "Unknown error"}'),
      ),
    ),
  );
});

// ==================== 路由配置集合 ====================
class RoutingConfig {
  /// 所有可用的路由
  static const List<String> allRoutes = [
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.home,
    RouteNames.voiceInput,
    RouteNames.camera,
    RouteNames.ocrResult,
    RouteNames.dictionary,
    RouteNames.history,
    RouteNames.settings,
    RouteNames.languageSwitcher,
    RouteNames.translateResult,
    RouteNames.conversation,
  ];

  /// 受保护的路由（需要初始化）
  static const List<String> protectedRoutes = [
    RouteNames.home,
    RouteNames.dictionary,
    RouteNames.history,
    RouteNames.settings,
  ];

  /// 不需要底部导航的路由
  static const List<String> noNavBarRoutes = [
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.voiceInput,
    RouteNames.camera,
    RouteNames.ocrResult,
    RouteNames.translateResult,
    RouteNames.conversation,
    RouteNames.languageSwitcher,
  ];

  /// 检查路由是否需要底部导航
  static bool showNavBar(String location) {
    return !noNavBarRoutes.any((route) => location.contains(route));
  }

  /// 检查路由是否受保护
  static bool isProtected(String location) {
    return protectedRoutes.any((route) => location.contains(route));
  }

  /// 获取路由的显示名称
  static String getRouteName(String routeName) {
    const routeNames = {
      RouteNames.splash: '启动页',
      RouteNames.onboarding: '教程',
      RouteNames.home: '首页',
      RouteNames.voiceInput: '语音输入',
      RouteNames.camera: '摄像头',
      RouteNames.ocrResult: 'OCR结果',
      RouteNames.dictionary: '字典',
      RouteNames.history: '历史',
      RouteNames.settings: '设置',
      RouteNames.languageSwitcher: '语言切换',
      RouteNames.translateResult: '翻译结果',
      RouteNames.conversation: '对话',
    };
    return routeNames[routeName] ?? routeName;
  }
}

// ==================== 路由快捷方式 ====================
extension RouteNavigationExtension on BuildContext {
  /// 导航到翻译页面
  void toTranslate() => goNamed(RouteNames.home);

  /// 导航到字典
  void toDictionary() => goNamed(RouteNames.dictionary);

  /// 导航到历史
  void toHistory() => goNamed(RouteNames.history);

  /// 导航到设置
  void toSettings() => goNamed(RouteNames.settings);

  /// 导航到语音输入
  void toVoiceInput() => pushNamed(RouteNames.voiceInput);

  /// 导航到摄像头
  void toCamera() => pushNamed(RouteNames.camera);

  /// 导航到OCR结果
  void toOcrResult(String imagePath) => pushNamed(
        RouteNames.ocrResult,
        extra: imagePath,
      );

  /// 导航到翻译结果
  void toTranslateResult(String sourceText, String targetText) => pushNamed(
        RouteNames.translateResult,
        extra: {'source': sourceText, 'target': targetText},
      );

  /// 导航到对话
  void toConversation() => pushNamed(RouteNames.conversation);

  /// 导航到语言切换
  void toLanguageSwitcher() => pushNamed(RouteNames.languageSwitcher);

  /// 返回主页
  void backToHome() => go('/${RouteNames.home}');

  /// 安全返回
  void safeGoBack() {
    if (canPop()) {
      pop();
    } else {
      go('/${RouteNames.home}');
    }
  }
}
