import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/translation_repository_impl.dart';
import '../../domain/repositories/translation_repository.dart';
import '../../data/services/google_translate_service.dart';

/// Google Translate 服务提供者
final googleTranslateServiceProvider = Provider<GoogleTranslateService>((ref) {
  return GoogleTranslateService();
});

/// 翻译仓库提供者
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final googleTranslateService = ref.watch(googleTranslateServiceProvider);

  return TranslationRepositoryImpl(
    googleTranslateService: googleTranslateService,
  );
});

/// 执行翻译
final translateProvider = FutureProvider.family<
    dynamic,
    ({
      String text,
      String sourceLanguage,
      String targetLanguage,
    })>((ref, params) async {
  final repository = ref.watch(translationRepositoryProvider);
  return repository.translate(
    params.text,
    params.sourceLanguage,
    params.targetLanguage,
  );
});

/// 获取翻译历史
final translationHistoryProvider = FutureProvider.family<
    dynamic,
    ({
      String? userId,
      String? sourceLanguage,
      String? targetLanguage,
      int limit,
    })>((ref, params) async {
  final repository = ref.watch(translationRepositoryProvider);
  return repository.getHistory(
    userId: params.userId,
    sourceLanguage: params.sourceLanguage,
    targetLanguage: params.targetLanguage,
    limit: params.limit,
  );
});

/// 批量翻译
final batchTranslateProvider = FutureProvider.family<
    dynamic,
    ({
      List<String> texts,
      String sourceLanguage,
      String targetLanguage,
    })>((ref, params) async {
  final repository = ref.watch(translationRepositoryProvider);
  return repository.translateBatch(
    params.texts,
    params.sourceLanguage,
    params.targetLanguage,
  );
});

/// 同步翻译记录
final syncTranslationsProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(translationRepositoryProvider);
  return repository.syncTranslations();
});
