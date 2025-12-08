import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/routes/route_names.dart';
import 'package:uyghur_translator/screens/splash_screen.dart';
import 'package:uyghur_translator/screens/onboarding_screen.dart';
import 'package:uyghur_translator/screens/home_screen.dart';
import 'package:uyghur_translator/screens/voice_input_screen.dart';
import 'package:uyghur_translator/screens/camera_screen.dart';
import 'package:uyghur_translator/screens/ocr_result_screen.dart';
import 'package:uyghur_translator/screens/dictionary_home_screen.dart';
import 'package:uyghur_translator/screens/history_screen.dart';
import 'package:uyghur_translator/screens/settings_screen.dart';
import 'package:uyghur_translator/screens/language_switcher_page.dart';
import 'package:uyghur_translator/screens/translate_result_screen.dart';
import 'package:uyghur_translator/screens/conversation_screen.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// 路由状态提供者 - 用于路由状态管理
final routerStateProvider = StateProvider<String>((ref) {
  return RouteNames.splash;
});

/// GoRouter 配置提供者
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/${RouteNames.splash}',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) {
      _logger.w('Navigation error: ${state.error}');
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Navigation Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/${RouteNames.home}'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    },
    routes: [
      /// Splash 路由
      GoRoute(
        path: '/${RouteNames.splash}',
        name: RouteNames.splash,
        builder: (context, state) {
          _logger.i('Navigating to Splash');
          return const SplashScreen();
        },
      ),

      /// Onboarding 路由
      GoRoute(
        path: '/${RouteNames.onboarding}',
        name: RouteNames.onboarding,
        builder: (context, state) {
          _logger.i('Navigating to Onboarding');
          return const OnboardingScreen();
        },
      ),

      /// Home 路由（主导航树）
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return HomeScreenWrapper(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, state, children) {
          return children.first;
        },
        branches: [
          /// 翻译分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${RouteNames.home}',
                name: RouteNames.home,
                builder: (context, state) {
                  _logger.i('Navigating to Home');
                  return const HomeScreen();
                },
                routes: [
                  /// 语音输入
                  GoRoute(
                    path: RouteNames.voiceInput,
                    name: RouteNames.voiceInput,
                    builder: (context, state) {
                      _logger.i('Navigating to Voice Input');
                      return const VoiceInputScreen();
                    },
                  ),

                  /// 摄像头/OCR
                  GoRoute(
                    path: RouteNames.camera,
                    name: RouteNames.camera,
                    builder: (context, state) {
                      _logger.i('Navigating to Camera');
                      return const CameraScreen();
                    },
                    routes: [
                      /// OCR 结果
                      GoRoute(
                        path: RouteNames.ocrResult,
                        name: RouteNames.ocrResult,
                        builder: (context, state) {
                          _logger.i('Navigating to OCR Result');
                          return const OcrResultScreen();
                        },
                      ),
                    ],
                  ),

                  /// 翻译结果
                  GoRoute(
                    path: RouteNames.translateResult,
                    name: RouteNames.translateResult,
                    builder: (context, state) {
                      _logger.i('Navigating to Translate Result');
                      return const TranslateResultScreen();
                    },
                  ),

                  /// 对话
                  GoRoute(
                    path: RouteNames.conversation,
                    name: RouteNames.conversation,
                    builder: (context, state) {
                      _logger.i('Navigating to Conversation');
                      return const ConversationScreen();
                    },
                  ),
                ],
              ),
            ],
          ),

          /// 字典分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${RouteNames.dictionary}',
                name: RouteNames.dictionary,
                builder: (context, state) {
                  _logger.i('Navigating to Dictionary');
                  return const DictionaryHomeScreen();
                },
              ),
            ],
          ),

          /// 历史分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${RouteNames.history}',
                name: RouteNames.history,
                builder: (context, state) {
                  _logger.i('Navigating to History');
                  return const HistoryScreen();
                },
              ),
            ],
          ),

          /// 设置分支
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/${RouteNames.settings}',
                name: RouteNames.settings,
                builder: (context, state) {
                  _logger.i('Navigating to Settings');
                  return const SettingsScreen();
                },
                routes: [
                  /// 语言切换
                  GoRoute(
                    path: RouteNames.languageSwitcher,
                    name: RouteNames.languageSwitcher,
                    builder: (context, state) {
                      _logger.i('Navigating to Language Switcher');
                      return const LanguageSwitcherPage();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// 导航器 Provider - 用于获取导航上下文
class HomeScreenWrapper extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreenWrapper({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
    );
  }
}

/// GoRouter 扩展 - 便捷导航方法
extension GoRouterExtension on GoRouter {
  /// 导航到翻译页面
  void goToTranslate() => go('/${RouteNames.home}');

  /// 导航到字典页面
  void goToDictionary() => go('/${RouteNames.dictionary}');

  /// 导航到历史记录页面
  void goToHistory() => go('/${RouteNames.history}');

  /// 导航到设置页面
  void goToSettings() => go('/${RouteNames.settings}');

  /// 导航到语音输入
  void goToVoiceInput() => push('/${RouteNames.home}/${RouteNames.voiceInput}');

  /// 导航到摄像头
  void goToCamera() => push('/${RouteNames.home}/${RouteNames.camera}');

  /// 导航到OCR结果
  void goToOcrResult(String imagePath) => push(
        '/${RouteNames.home}/${RouteNames.camera}/${RouteNames.ocrResult}',
        extra: imagePath,
      );

  /// 导航到翻译结果
  void goToTranslateResult(String sourceText, String targetText) => push(
        '/${RouteNames.home}/${RouteNames.translateResult}',
        extra: {'source': sourceText, 'target': targetText},
      );

  /// 导航到对话
  void goToConversation() =>
      push('/${RouteNames.home}/${RouteNames.conversation}');

  /// 导航到语言切换
  void goToLanguageSwitcher() =>
      push('/${RouteNames.settings}/${RouteNames.languageSwitcher}');

  /// 返回首页
  void popToHome() => go('/${RouteNames.home}');

  /// 返回上一页
  void goBack() => pop();
}
