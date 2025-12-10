import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uyghur_translator/shared/services/database/hive_database_service.dart';

/// Hive 数据库服务初始化 Provider
final hiveDatabaseServiceProvider = FutureProvider<void>((ref) async {
  await HiveDatabaseService.initialize();
});

/// Hive 初始化 Provider (兼容旧代码)
final hiveInitProvider = FutureProvider<void>((ref) async {
  await Hive.initFlutter();
});

/// 翻译历史列表 Provider
final translationHistoryListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  await ref.watch(hiveDatabaseServiceProvider.future);
  return HiveDatabaseService.getAllTranslationHistory();
});

/// 收藏列表 Provider
final favoritesListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  await ref.watch(hiveDatabaseServiceProvider.future);
  return HiveDatabaseService.getAllFavorites();
});

/// OCR 结果列表 Provider
final ocrResultsListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  await ref.watch(hiveDatabaseServiceProvider.future);
  return HiveDatabaseService.getAllOcrResults();
});

/// 用户偏好设置 Provider
final userPreferencesDataProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  await ref.watch(hiveDatabaseServiceProvider.future);
  return HiveDatabaseService.getUserPreferences();
});
