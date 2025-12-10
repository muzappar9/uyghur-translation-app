import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uyghur_translator/app.dart';
import 'package:uyghur_translator/shared/services/storage/preference_service.dart';
import 'package:uyghur_translator/core/config/env_config.dart';
import 'package:uyghur_translator/shared/services/database/hive_database_service.dart';
import 'package:uyghur_translator/features/auth/data/services/auth_initializer.dart';
import 'package:uyghur_translator/core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 启用性能监控
  PerformanceMonitor().setEnabled(true);
  PerformanceMonitor().startFrameMonitoring();

  // 加载环境变量配置
  await dotenv.load(fileName: '.env');

  // 验证配置
  if (!EnvConfig.validateConfig()) {
    appLogger.w('Configuration validation warnings detected');
  }

  // 初始化 Hive 数据库（替代 Isar）
  try {
    await HiveDatabaseService.initialize();
    appLogger.i('Hive database initialized');
  } catch (e) {
    appLogger.e('Failed to initialize Hive: $e');
  }

  // 初始化认证系统
  try {
    await AuthInitializer.initialize();
    appLogger.i('Auth system initialized (${AuthInitializer.getAuthMethod()})');
  } catch (e) {
    appLogger.e('Failed to initialize auth: $e');
  }

  // 初始化 Hive（用户偏好存储）
  final prefService = PreferenceService();
  await prefService.init();

  runApp(
    ProviderScope(
      child: MyApp(prefService: prefService),
    ),
  );
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
