import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:uyghur_translator/features/translation/data/repositories/translation_repository.dart';
import 'package:uyghur_translator/features/translation/data/repositories/pending_translation_repository.dart';
import 'package:uyghur_translator/shared/providers/network_provider.dart';
import 'package:uyghur_translator/shared/services/translation/translation_manager.dart';

/// 翻译服务 - 处理翻译逻辑、缓存、离线和重试
///
/// 特性:
/// - 使用 TranslationManager 管理多个翻译引擎
/// - 自动缓存翻译结果到本地数据库 (Isar)
/// - 离线模式支持 (保存到待同步队列)
/// - 指数退避重试策略
/// - 详细的日志记录
class TranslationService {
  final Ref _ref;
  final _logger = Logger();

  /// 指数退避重试延迟 (毫秒)
  static const List<int> retryDelays = [1000, 2000, 4000, 8000, 16000];

  TranslationService(this._ref);

  /// 执行翻译 (使用 TranslationManager 进行多引擎管理)
  ///
  /// 流程:
  /// 1. 使用 TranslationManager 翻译 (自动选择可用引擎)
  /// 2. 结果保存到本地数据库缓存
  /// 3. 添加到历史记录
  /// 4. 如果失败且离线，保存到待同步队列
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    final networkStatus = _ref.watch(networkConnectivityProvider).value;
    final pendingRepo = _ref.watch(pendingTranslationRepositoryProvider);
    final translationManager = _ref.watch(translationManagerProvider);

    try {
      // 使用 TranslationManager 执行翻译
      // 它会自动选择最高优先级的可用引擎
      _logger.i('Starting translation: "$text" ($sourceLang→$targetLang)');
      final result = await translationManager.translate(
        text,
        sourceLang,
        targetLang,
      );

      // 成功翻译后:
      // 1. 保存到本地数据库缓存
      // 2. 标记任何相同内容的待同步记录为已同步
      _logger.i('Translation successful: "$result"');
      await _markPendingAsSynced(pendingRepo, text, sourceLang, targetLang);

      return result;
    } catch (e) {
      _logger.e('Translation failed: $e');

      // 如果在线，重新抛出异常
      if (networkStatus == NetworkStatus.online) {
        _logger.w('Online mode: rethrowing exception');
        rethrow;
      }

      // 如果离线，保存到待同步队列
      _logger.w('Offline mode: saving to pending queue for later sync');
      await pendingRepo.addPending(text, sourceLang, targetLang);

      // 抛出离线异常，说明内容已保存待同步
      throw OfflineTranslationException(
        'Offline: translation saved to sync queue',
      );
    }
  }

  /// 处理待同步的翻译队列
  Future<void> processPendingTranslations() async {
    final pendingRepo = _ref.watch(pendingTranslationRepositoryProvider);
    final repository = _ref.watch(translationRepositoryProvider);
    final networkStatus = _ref.watch(networkConnectivityProvider).value;

    // 如果离线，不处理
    if (networkStatus != NetworkStatus.online) {
      _logger.i('Offline: skipping pending translation processing');
      return;
    }

    try {
      final pendingList = await pendingRepo.getRetryableList();

      for (final pending in pendingList) {
        try {
          // 尝试翻译
          await repository.translate(
            pending.sourceText,
            pending.sourceLang,
            pending.targetLang,
          );

          _logger.i('Synced pending: ${pending.sourceText}');
          await pendingRepo.markSynced(pending.id);
        } catch (e) {
          // 更新重试计数和错误信息
          final nextRetryCount = pending.retryCount + 1;
          await pendingRepo.updateRetryCount(
            pending.id,
            nextRetryCount,
            e.toString(),
          );

          _logger.w(
              'Retry pending translation: attempt $nextRetryCount, error: $e');

          // 如果重试次数达到限制，停止
          if (nextRetryCount >= 5) {
            _logger.e('Max retries reached for: ${pending.sourceText}');
          }
        }
      }
    } catch (e) {
      _logger.e('Error processing pending translations: $e');
    }
  }

  /// 标记待同步记录为已同步
  Future<void> _markPendingAsSynced(
    PendingTranslationRepository pendingRepo,
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final pendingList = await pendingRepo.getPendingList();

      for (final pending in pendingList) {
        if (pending.sourceText.trim().toLowerCase() ==
                text.trim().toLowerCase() &&
            pending.sourceLang == sourceLang &&
            pending.targetLang == targetLang) {
          await pendingRepo.markSynced(pending.id);
        }
      }
    } catch (e) {
      _logger.w('Error marking pending as synced: $e');
    }
  }
}

/// 离线翻译异常
class OfflineTranslationException implements Exception {
  final String message;
  OfflineTranslationException(this.message);

  @override
  String toString() => message;
}

/// 翻译服务 Provider
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService(ref);
});
