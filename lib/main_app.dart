import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/features/main/presentation/screens/home_navigation_screen.dart';

/// 主应用Widget
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 监听认证状态提供器
    // final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: '维吾尔翻译助手',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          // TODO: 根据认证状态切换屏幕
          // 临时显示主导航，完整实现后应检查authState
          return const HomeNavigationScreen();
          // return authState.when(
          //   data: (user) => user != null
          //       ? const HomeNavigationScreen()
          //       : const AuthenticationScreen(),
          //   loading: () => const Scaffold(
          //     body: Center(child: CircularProgressIndicator()),
          //   ),
          //   error: (error, stack) => const AuthenticationScreen(),
          // );
        },
      ),
    );
  }
}
