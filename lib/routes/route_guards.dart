import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uyghur_translator/routes/route_names.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// 路由保护器接口
abstract class RouteGuard {
  /// 检查是否允许导航
  /// 返回 null 表示允许导航，否则返回应该重定向到的路由
  Future<String?> canNavigate(String routeName, Map<String, dynamic>? extra);
}

/// 权限检查守卫
class PermissionGuard implements RouteGuard {
  @override
  Future<String?> canNavigate(
      String routeName, Map<String, dynamic>? extra) async {
    // 摄像头相关路由需要权限检查
    if (routeName == RouteNames.camera || routeName == RouteNames.ocrResult) {
      // TODO: 实现摄像头权限检查
      _logger.i('Checking camera permission for route: $routeName');
      return null; // 允许导航
    }

    // 语音识别路由需要权限检查
    if (routeName == RouteNames.voiceInput ||
        routeName == RouteNames.conversation) {
      // TODO: 实现麦克风权限检查
      _logger.i('Checking microphone permission for route: $routeName');
      return null; // 允许导航
    }

    return null; // 其他路由允许导航
  }
}

/// 初始化检查守卫
class InitializationGuard implements RouteGuard {
  @override
  Future<String?> canNavigate(
      String routeName, Map<String, dynamic>? extra) async {
    // 某些路由需要在应用初始化后才能访问
    final protectedRoutes = [
      RouteNames.home,
      RouteNames.dictionary,
      RouteNames.history,
      RouteNames.settings,
    ];

    if (protectedRoutes.contains(routeName)) {
      // TODO: 检查应用初始化是否完成
      _logger.i('Checking initialization for route: $routeName');
      return null; // 允许导航
    }

    return null;
  }
}

/// 离线模式检查守卫
class OfflineModeGuard implements RouteGuard {
  final WidgetRef ref;

  OfflineModeGuard(this.ref);

  @override
  Future<String?> canNavigate(
      String routeName, Map<String, dynamic>? extra) async {
    // 某些路由在离线模式下不可用
    final onlineOnlyRoutes = [
      RouteNames.translateResult, // 实时翻译可能需要网络
    ];

    if (onlineOnlyRoutes.contains(routeName)) {
      // TODO: 检查离线模式状态
      _logger.i('Checking offline mode for route: $routeName');
      return null; // 允许导航
    }

    return null;
  }
}

/// 数据验证守卫
class DataValidationGuard implements RouteGuard {
  @override
  Future<String?> canNavigate(
      String routeName, Map<String, dynamic>? extra) async {
    // 某些路由需要特定的数据
    if (routeName == RouteNames.ocrResult) {
      if (extra == null || extra.isEmpty) {
        _logger.w('Invalid data for OCR result route');
        return '/${RouteNames.camera}'; // 重定向回摄像头
      }
      _logger.i('Data validation passed for OCR result');
    }

    if (routeName == RouteNames.translateResult) {
      if (extra == null || extra['source'] == null || extra['target'] == null) {
        _logger.w('Invalid data for translate result route');
        return '/${RouteNames.home}'; // 重定向回主页
      }
      _logger.i('Data validation passed for translate result');
    }

    return null;
  }
}

/// 路由守卫管理器
class RouteGuardManager {
  final List<RouteGuard> guards = [
    PermissionGuard(),
    InitializationGuard(),
    DataValidationGuard(),
  ];

  /// 检查是否允许导航
  Future<String?> canNavigate(
    String routeName,
    Map<String, dynamic>? extra,
  ) async {
    for (final guard in guards) {
      final result = await guard.canNavigate(routeName, extra);
      if (result != null) {
        _logger.w(
            'Route guard blocked navigation to $routeName, redirecting to $result');
        return result; // 返回重定向目标
      }
    }
    _logger.i('All route guards passed for $routeName');
    return null; // 允许导航
  }
}

/// 路由守卫管理器 Provider
final routeGuardManagerProvider = Provider<RouteGuardManager>((ref) {
  return RouteGuardManager();
});

/// 导航中间件 - 用于在导航前执行守卫检查
Future<String?> navigateWithGuards(
  WidgetRef ref,
  String routeName,
  Map<String, dynamic>? extra,
) async {
  final guardManager = ref.read(routeGuardManagerProvider);
  return await guardManager.canNavigate(routeName, extra);
}

/// 路由重定向回调
String? Function(BuildContext, GoRouterState)? createRouteRedirectCallback(
  WidgetRef ref,
) {
  return (context, state) {
    // 可以在这里添加全局路由重定向逻辑
    // 例如：未登录时重定向到登录页
    // 例如：用户在onboarding时无法访问其他页面

    _logger.i('Current route: ${state.matchedLocation}');
    return null; // 不进行重定向
  };
}

/// 路由监听器 - 监听路由变化
void Function(BuildContext, GoRouterState)? createRouteNavigatorObserver(
  WidgetRef ref,
) {
  return (context, state) {
    _logger.i('Route changed: ${state.matchedLocation}');
    // 可以在这里进行分析追踪、页面事件上报等
  };
}

/// 路由错误处理
class RouteErrorHandler {
  /// 处理404错误
  static String handleNotFound(String location) {
    _logger.e('Route not found: $location');
    return '/${RouteNames.home}'; // 重定向到主页
  }

  /// 处理权限错误
  static String handlePermissionDenied(String routeName) {
    _logger.e('Permission denied for route: $routeName');
    return '/${RouteNames.home}'; // 重定向到主页
  }

  /// 处理数据验证失败
  static String handleDataValidationFailed(String routeName) {
    _logger.e('Data validation failed for route: $routeName');
    return '/${RouteNames.home}'; // 重定向到主页
  }

  /// 处理初始化失败
  static String handleInitializationFailed() {
    _logger.e('Application initialization failed');
    return '/${RouteNames.splash}'; // 重定向到启动页
  }
}
