/// 字体按需下载管理器
/// 支持多语言字体的动态下载和缓存
///
/// 特性：
/// - 默认内置字体（中文、维语）无需下载
/// - 其他语言字体按需下载
/// - 下载进度跟踪
/// - 本地缓存管理
/// - 支持字体预加载
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'language_config.dart';

/// 字体下载状态
enum FontDownloadStatus {
  /// 未下载
  notDownloaded,

  /// 下载中
  downloading,

  /// 已下载
  downloaded,

  /// 下载失败
  failed,

  /// 内置字体（无需下载）
  builtIn,
}

/// 单个字体的状态
class FontStatus {
  final FontCategory category;
  final FontDownloadStatus status;
  final double progress;
  final String? errorMessage;
  final String? localPath;

  const FontStatus({
    required this.category,
    this.status = FontDownloadStatus.notDownloaded,
    this.progress = 0.0,
    this.errorMessage,
    this.localPath,
  });

  FontStatus copyWith({
    FontDownloadStatus? status,
    double? progress,
    String? errorMessage,
    String? localPath,
  }) {
    return FontStatus(
      category: category,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      localPath: localPath ?? this.localPath,
    );
  }

  bool get isAvailable =>
      status == FontDownloadStatus.downloaded ||
      status == FontDownloadStatus.builtIn;
}

/// 字体管理器状态
class FontManagerState {
  final Map<FontCategory, FontStatus> fontStatuses;
  final bool isInitialized;

  const FontManagerState({
    this.fontStatuses = const {},
    this.isInitialized = false,
  });

  FontManagerState copyWith({
    Map<FontCategory, FontStatus>? fontStatuses,
    bool? isInitialized,
  }) {
    return FontManagerState(
      fontStatuses: fontStatuses ?? this.fontStatuses,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  /// 获取指定类别的字体状态
  FontStatus getStatus(FontCategory category) {
    return fontStatuses[category] ??
        FontStatus(
          category: category,
          status: FontDownloadStatus.notDownloaded,
        );
  }

  /// 检查语言的字体是否可用
  bool isFontAvailable(String languageCode) {
    final category = SupportedLanguages.getFontCategory(languageCode);
    return getStatus(category).isAvailable;
  }
}

/// 字体下载管理器
class FontDownloadManager extends StateNotifier<FontManagerState> {
  FontDownloadManager() : super(const FontManagerState()) {
    _initialize();
  }

  /// Google Fonts 字体 CDN 配置
  /// 注意：实际项目中应使用自己的 CDN 或者 Google Fonts API
  static const _fontUrls = {
    FontCategory.devanagari:
        'https://fonts.gstatic.com/s/notosansdevanagari/v26/TuGPUUFzXI5FBtUq5a8bq6EZLfhTNlE5HHKwp7EKVmQ.woff2',
    FontCategory.bengali:
        'https://fonts.gstatic.com/s/notosansbengali/v20/Cn-SJsCGWQxOjaGwMQ6fIiMywrNJIky6nvd8BjzVMvJx2mcSPVFpVEqE-6KmsLItsLc.woff2',
    FontCategory.tamil:
        'https://fonts.gstatic.com/s/notosanstamil/v27/ieVc2YdFI3GCY6SyQy1KfStzYKZgzN1z4LKDbeZce-0429tBManUktuex7vGor0RqKE.woff2',
    FontCategory.telugu:
        'https://fonts.gstatic.com/s/notosanstelugu/v26/0FlxVOGZlE2Rrtr-HmgkMWJNjJ5_RyT8o8c7fHkeg-esVC5dzHkHIJQqrEntezfq.woff2',
    FontCategory.gujarati:
        'https://fonts.gstatic.com/s/notosansgujarati/v25/wlpWgx_HC1ti5ViekvcxnhMlCVo3f5pv17ivlzsUB14gg1TMR2Gw4VceEl7MA_ypFg.woff2',
    FontCategory.thai:
        'https://fonts.gstatic.com/s/notosansthai/v25/iJWnBXeUZi_OHPqn4wq6hQ2_hbJ1xyN9wd43SofNWcd1MKVQt_So_9CdV5RspzI.woff2',
    FontCategory.khmer:
        'https://fonts.gstatic.com/s/notosanskhmer/v24/ijw3s5roRME5LLRxjsRb-gssOenAyendxrgV2c-Zw-9vbVUti_Z_dWgtWYuNAJz4kA.woff2',
    FontCategory.myanmar:
        'https://fonts.gstatic.com/s/notosansmyanmar/v20/AlZq_y1ZtY3ymOryg38hOCSdOnFq0En23OU4o1AC.woff2',
    FontCategory.tibetan:
        'https://fonts.gstatic.com/s/notosanstibetan/v18/NaPecZTSBuhTirw6IaFn7lINj9-2PmNCD28eaQaaPME.woff2',
    FontCategory.hebrew:
        'https://fonts.gstatic.com/s/notosanshebrew/v46/or3HQ7v33eiDljA1IufXTtVf7V6RvEEdhQlk0LlGxCyaeNKYZC0sqk3xXGiXd4qtDw.woff2',
    FontCategory.mongolian:
        'https://fonts.gstatic.com/s/notosansmongolian/v19/VdGCAYADGIwE0EopZx8xQfHlgEAMsrToxLsga8sEvBjosA.woff2',
  };

  /// 字体文件名配置
  static const _fontFileNames = {
    FontCategory.devanagari: 'NotoSansDevanagari.woff2',
    FontCategory.bengali: 'NotoSansBengali.woff2',
    FontCategory.tamil: 'NotoSansTamil.woff2',
    FontCategory.telugu: 'NotoSansTelugu.woff2',
    FontCategory.gujarati: 'NotoSansGujarati.woff2',
    FontCategory.thai: 'NotoSansThai.woff2',
    FontCategory.khmer: 'NotoSansKhmer.woff2',
    FontCategory.myanmar: 'NotoSansMyanmar.woff2',
    FontCategory.tibetan: 'NotoSansTibetan.woff2',
    FontCategory.hebrew: 'NotoSansHebrew.woff2',
    FontCategory.mongolian: 'NotoSansMongolian.woff2',
  };

  /// 初始化
  Future<void> _initialize() async {
    final statuses = <FontCategory, FontStatus>{};

    // 内置字体（系统字体、阿拉伯语系、CJK）
    for (final category in [
      FontCategory.system,
      FontCategory.arabic,
      FontCategory.cjk,
    ]) {
      statuses[category] = FontStatus(
        category: category,
        status: FontDownloadStatus.builtIn,
      );
    }

    // 检查已下载的字体
    for (final category in _fontUrls.keys) {
      final localPath = await _getLocalFontPath(category);
      if (localPath != null && await File(localPath).exists()) {
        statuses[category] = FontStatus(
          category: category,
          status: FontDownloadStatus.downloaded,
          localPath: localPath,
        );
        // 加载字体
        await _loadFont(category, localPath);
      } else {
        statuses[category] = FontStatus(
          category: category,
          status: FontDownloadStatus.notDownloaded,
        );
      }
    }

    state = state.copyWith(
      fontStatuses: statuses,
      isInitialized: true,
    );
  }

  /// 获取本地字体路径
  Future<String?> _getLocalFontPath(FontCategory category) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${directory.path}/fonts');
      if (!await fontDir.exists()) {
        await fontDir.create(recursive: true);
      }
      final fileName = _fontFileNames[category];
      if (fileName == null) return null;
      return '${fontDir.path}/$fileName';
    } catch (e) {
      debugPrint('获取字体路径失败: $e');
      return null;
    }
  }

  /// 下载字体
  Future<bool> downloadFont(FontCategory category) async {
    if (!_fontUrls.containsKey(category)) {
      debugPrint('不支持下载的字体类别: $category');
      return false;
    }

    final currentStatus = state.getStatus(category);
    if (currentStatus.status == FontDownloadStatus.downloading) {
      return false; // 已经在下载中
    }
    if (currentStatus.status == FontDownloadStatus.downloaded ||
        currentStatus.status == FontDownloadStatus.builtIn) {
      return true; // 已经可用
    }

    // 更新状态为下载中
    _updateStatus(category, FontDownloadStatus.downloading, progress: 0);

    try {
      final url = _fontUrls[category]!;
      final localPath = await _getLocalFontPath(category);
      if (localPath == null) {
        throw Exception('无法获取本地存储路径');
      }

      // 下载文件
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('下载失败: HTTP ${response.statusCode}');
      }

      // 保存文件
      final file = File(localPath);
      await file.writeAsBytes(response.bodyBytes);

      // 加载字体
      await _loadFont(category, localPath);

      // 更新状态为已下载
      _updateStatus(
        category,
        FontDownloadStatus.downloaded,
        progress: 1.0,
        localPath: localPath,
      );

      return true;
    } catch (e) {
      debugPrint('字体下载失败: $e');
      _updateStatus(
        category,
        FontDownloadStatus.failed,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 加载字体到 Flutter
  Future<void> _loadFont(FontCategory category, String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final fontLoader = FontLoader(_getFontFamily(category));
      fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await fontLoader.load();
      debugPrint('字体加载成功: $category');
    } catch (e) {
      debugPrint('字体加载失败: $e');
    }
  }

  /// 获取字体族名称
  String _getFontFamily(FontCategory category) {
    switch (category) {
      case FontCategory.devanagari:
        return 'NotoSansDevanagari';
      case FontCategory.bengali:
        return 'NotoSansBengali';
      case FontCategory.tamil:
        return 'NotoSansTamil';
      case FontCategory.telugu:
        return 'NotoSansTelugu';
      case FontCategory.gujarati:
        return 'NotoSansGujarati';
      case FontCategory.thai:
        return 'NotoSansThai';
      case FontCategory.khmer:
        return 'NotoSansKhmer';
      case FontCategory.myanmar:
        return 'NotoSansMyanmar';
      case FontCategory.tibetan:
        return 'NotoSansTibetan';
      case FontCategory.hebrew:
        return 'NotoSansHebrew';
      case FontCategory.mongolian:
        return 'NotoSansMongolian';
      default:
        return 'System';
    }
  }

  /// 更新字体状态
  void _updateStatus(
    FontCategory category,
    FontDownloadStatus status, {
    double? progress,
    String? errorMessage,
    String? localPath,
  }) {
    final currentStatus = state.getStatus(category);
    final newStatuses = Map<FontCategory, FontStatus>.from(state.fontStatuses);
    newStatuses[category] = currentStatus.copyWith(
      status: status,
      progress: progress,
      errorMessage: errorMessage,
      localPath: localPath,
    );
    state = state.copyWith(fontStatuses: newStatuses);
  }

  /// 检查语言字体是否可用
  bool isFontAvailable(String languageCode) {
    return state.isFontAvailable(languageCode);
  }

  /// 确保语言字体可用（如需下载则下载）
  Future<bool> ensureFontAvailable(String languageCode) async {
    final category = SupportedLanguages.getFontCategory(languageCode);
    final status = state.getStatus(category);

    if (status.isAvailable) {
      return true;
    }

    return await downloadFont(category);
  }

  /// 删除已下载的字体
  Future<void> deleteFont(FontCategory category) async {
    final status = state.getStatus(category);
    if (status.localPath != null) {
      try {
        final file = File(status.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('删除字体失败: $e');
      }
    }
    _updateStatus(category, FontDownloadStatus.notDownloaded);
  }

  /// 获取已下载字体的总大小（MB）
  Future<double> getDownloadedFontsSize() async {
    double totalSize = 0;
    for (final entry in state.fontStatuses.entries) {
      if (entry.value.localPath != null) {
        try {
          final file = File(entry.value.localPath!);
          if (await file.exists()) {
            totalSize += await file.length();
          }
        } catch (_) {}
      }
    }
    return totalSize / (1024 * 1024); // 转换为 MB
  }

  /// 清除所有下载的字体
  Future<void> clearAllDownloadedFonts() async {
    for (final category in _fontUrls.keys) {
      await deleteFont(category);
    }
  }
}

/// 字体下载管理器 Provider
final fontDownloadManagerProvider =
    StateNotifierProvider<FontDownloadManager, FontManagerState>((ref) {
  return FontDownloadManager();
});

/// 检查特定语言字体是否可用
final fontAvailableProvider =
    Provider.family<bool, String>((ref, languageCode) {
  final state = ref.watch(fontDownloadManagerProvider);
  return state.isFontAvailable(languageCode);
});

/// 获取字体状态
final fontStatusProvider =
    Provider.family<FontStatus, FontCategory>((ref, category) {
  final state = ref.watch(fontDownloadManagerProvider);
  return state.getStatus(category);
});
