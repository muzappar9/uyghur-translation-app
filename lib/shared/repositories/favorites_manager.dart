import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../services/database/isar_database_service.dart';
import '../data/models/isar_models/favorite_item_model.dart';

/// 收藏项目的类型
enum FavoriteItemType {
  translation, // 翻译结果
  voicePhrase, // 语音短语
  ocrResult, // OCR 结果
}

/// 收藏项目
class FavoriteItem {
  final int? id;
  final FavoriteItemType type;
  final String title; // 显示标题
  final String sourceText; // 原始文本
  final String translatedText; // 翻译文本
  final String sourceLang; // 源语言
  final String targetLang; // 目标语言
  final String? tags; // 标签（用逗号分隔）
  final String? notes; // 用户笔记
  final DateTime createdAt;
  final DateTime? lastAccessedAt;
  final int accessCount; // 访问计数

  FavoriteItem({
    this.id,
    required this.type,
    required this.title,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    this.tags,
    this.notes,
    required this.createdAt,
    this.lastAccessedAt,
    this.accessCount = 0,
  });

  /// 转换为 FavoriteItemModel 用于存储
  FavoriteItemModel toModel() {
    return FavoriteItemModel(
      type: type.toString(),
      title: title,
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLang: sourceLang,
      targetLang: targetLang,
      tags: tags,
      notes: notes,
      createdAt: createdAt,
      lastAccessedAt: lastAccessedAt,
      accessCount: accessCount,
    );
  }

  /// 从 FavoriteItemModel 创建
  factory FavoriteItem.fromModel(FavoriteItemModel model) {
    return FavoriteItem(
      id: model.id,
      type: FavoriteItemType.values.firstWhere(
        (e) => e.toString() == model.type,
        orElse: () => FavoriteItemType.translation,
      ),
      title: model.title,
      sourceText: model.sourceText,
      translatedText: model.translatedText,
      sourceLang: model.sourceLang,
      targetLang: model.targetLang,
      tags: model.tags,
      notes: model.notes,
      createdAt: model.createdAt,
      lastAccessedAt: model.lastAccessedAt,
      accessCount: model.accessCount,
    );
  }

  /// 解析标签列表
  List<String> get tagList =>
      tags?.split(',').where((t) => t.isNotEmpty).toList() ?? [];

  /// 添加标签
  FavoriteItem addTag(String tag) {
    final currentTags = tagList;
    if (!currentTags.contains(tag)) {
      currentTags.add(tag);
      return FavoriteItem(
        id: id,
        type: type,
        title: title,
        sourceText: sourceText,
        translatedText: translatedText,
        sourceLang: sourceLang,
        targetLang: targetLang,
        tags: currentTags.join(','),
        notes: notes,
        createdAt: createdAt,
        lastAccessedAt: lastAccessedAt,
        accessCount: accessCount,
      );
    }
    return this;
  }

  /// 移除标签
  FavoriteItem removeTag(String tag) {
    final currentTags = tagList;
    currentTags.removeWhere((t) => t == tag);
    return FavoriteItem(
      id: id,
      type: type,
      title: title,
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLang: sourceLang,
      targetLang: targetLang,
      tags: currentTags.isNotEmpty ? currentTags.join(',') : null,
      notes: notes,
      createdAt: createdAt,
      lastAccessedAt: lastAccessedAt,
      accessCount: accessCount,
    );
  }
}

/// 收藏管理器
///
/// 功能：
/// - 收藏/取消收藏翻译、短语、识别结果
/// - 收藏列表管理和搜索
/// - 标签支持
/// - 用户笔记
/// - 访问统计
/// - 收藏分类导出
class FavoritesManager {
  final Logger _logger = Logger();

  /// 添加收藏
  ///
  /// 参数：
  /// - [type] 收藏类型
  /// - [title] 显示标题
  /// - [sourceText] 原始文本
  /// - [translatedText] 翻译文本
  /// - [sourceLang] 源语言
  /// - [targetLang] 目标语言
  /// - [notes] 用户笔记
  ///
  /// 返回收藏项目 ID
  Future<int> addFavorite({
    required FavoriteItemType type,
    required String title,
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
    String? notes,
  }) async {
    try {
      _logger.i('[Favorites] Adding favorite: $title');

      final item = FavoriteItem(
        type: type,
        title: title,
        sourceText: sourceText,
        translatedText: translatedText,
        sourceLang: sourceLang,
        targetLang: targetLang,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final isar = IsarDatabaseService.isar;
      final id = await isar.writeTxn(() async {
        return await isar.favoriteItemModels.put(item.toModel());
      });

      _logger.i('[Favorites] ✓ Favorite added with ID: $id');
      return id;
    } catch (e) {
      _logger.e('[Favorites] Error adding favorite: $e');
      rethrow;
    }
  }

  /// 获取所有收藏
  ///
  /// 参数：
  /// - [limit] 限制数量
  /// - [offset] 偏移量
  ///
  /// 返回收藏列表（按最近访问时间排序）
  Future<List<FavoriteItem>> getAllFavorites({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.favoriteItemModels
          .where()
          .sortByCreatedAtDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      final items = models.map((m) => FavoriteItem.fromModel(m)).toList();
      _logger.d('[Favorites] Retrieved ${items.length} favorites');
      return items;
    } catch (e) {
      _logger.e('[Favorites] Error getting all favorites: $e');
      rethrow;
    }
  }

  /// 按类型获取收藏
  ///
  /// 参数：
  /// - [type] 收藏类型
  /// - [limit] 限制数量
  /// - [offset] 偏移量
  Future<List<FavoriteItem>> getFavoritesByType({
    required FavoriteItemType type,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.favoriteItemModels
          .where()
          .typeEqualTo(type.toString())
          .sortByCreatedAtDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      final items = models.map((m) => FavoriteItem.fromModel(m)).toList();
      _logger.d(
          '[Favorites] Found ${items.length} favorites of type ${type.toString()}');
      return items;
    } catch (e) {
      _logger.e('[Favorites] Error getting favorites by type: $e');
      rethrow;
    }
  }

  /// 按语言对获取收藏
  ///
  /// 参数：
  /// - [sourceLang] 源语言
  /// - [targetLang] 目标语言
  /// - [limit] 限制数量
  /// - [offset] 偏移量
  Future<List<FavoriteItem>> getFavoritesByLanguagePair({
    required String sourceLang,
    required String targetLang,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.favoriteItemModels
          .where()
          .sourceLangEqualTo(sourceLang)
          .filter()
          .targetLangEqualTo(targetLang)
          .sortByCreatedAtDesc()
          .offset(offset)
          .limit(limit)
          .findAll();

      final items = models.map((m) => FavoriteItem.fromModel(m)).toList();
      _logger.d(
          '[Favorites] Found ${items.length} favorites for $sourceLang→$targetLang');
      return items;
    } catch (e) {
      _logger.e('[Favorites] Error getting favorites by language pair: $e');
      rethrow;
    }
  }

  /// 按标签搜索收藏
  ///
  /// 参数：
  /// - [tag] 标签
  /// - [limit] 限制数量
  /// - [offset] 偏移量
  Future<List<FavoriteItem>> getFavoritesByTag({
    required String tag,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;

      final allModels =
          await isar.favoriteItemModels.where().sortByCreatedAtDesc().findAll();

      final filtered = allModels
          .where((m) => m.tags?.contains(tag) ?? false)
          .skip(offset)
          .take(limit)
          .toList();

      final items = filtered.map((m) => FavoriteItem.fromModel(m)).toList();
      _logger.d('[Favorites] Found ${items.length} favorites with tag "$tag"');
      return items;
    } catch (e) {
      _logger.e('[Favorites] Error getting favorites by tag: $e');
      rethrow;
    }
  }

  /// 搜索收藏（标题或文本）
  ///
  /// 参数：
  /// - [query] 搜索关键词
  /// - [limit] 限制数量
  /// - [offset] 偏移量
  Future<List<FavoriteItem>> searchFavorites({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final isar = IsarDatabaseService.isar;
      final lowerQuery = query.toLowerCase();

      final allModels =
          await isar.favoriteItemModels.where().sortByCreatedAtDesc().findAll();

      final filtered = allModels
          .where((m) =>
              m.title.toLowerCase().contains(lowerQuery) ||
              m.sourceText.toLowerCase().contains(lowerQuery) ||
              m.translatedText.toLowerCase().contains(lowerQuery))
          .skip(offset)
          .take(limit)
          .toList();

      final items = filtered.map((m) => FavoriteItem.fromModel(m)).toList();
      _logger
          .d('[Favorites] Found ${items.length} favorites matching "$query"');
      return items;
    } catch (e) {
      _logger.e('[Favorites] Error searching favorites: $e');
      rethrow;
    }
  }

  /// 更新收藏笔记
  ///
  /// 参数：
  /// - [id] 收藏项目 ID
  /// - [notes] 新笔记
  Future<void> updateNotes(int id, String? notes) async {
    try {
      final isar = IsarDatabaseService.isar;

      final model = await isar.favoriteItemModels.get(id);
      if (model == null) {
        _logger.w('[Favorites] Favorite not found: $id');
        return;
      }

      model.notes = notes;

      await isar.writeTxn(() async {
        await isar.favoriteItemModels.put(model);
      });

      _logger.i('[Favorites] ✓ Notes updated for favorite: $id');
    } catch (e) {
      _logger.e('[Favorites] Error updating notes: $e');
      rethrow;
    }
  }

  /// 添加标签
  ///
  /// 参数：
  /// - [id] 收藏项目 ID
  /// - [tag] 标签
  Future<void> addTag(int id, String tag) async {
    try {
      final isar = IsarDatabaseService.isar;

      final model = await isar.favoriteItemModels.get(id);
      if (model == null) {
        _logger.w('[Favorites] Favorite not found: $id');
        return;
      }

      final tags = model.tags?.split(',') ?? [];
      if (!tags.contains(tag)) {
        tags.add(tag);
        model.tags = tags.join(',');

        await isar.writeTxn(() async {
          await isar.favoriteItemModels.put(model);
        });

        _logger.i('[Favorites] ✓ Tag added: $tag to favorite $id');
      }
    } catch (e) {
      _logger.e('[Favorites] Error adding tag: $e');
      rethrow;
    }
  }

  /// 删除标签
  ///
  /// 参数：
  /// - [id] 收藏项目 ID
  /// - [tag] 标签
  Future<void> removeTag(int id, String tag) async {
    try {
      final isar = IsarDatabaseService.isar;

      final model = await isar.favoriteItemModels.get(id);
      if (model == null) {
        _logger.w('[Favorites] Favorite not found: $id');
        return;
      }

      final tags = model.tags?.split(',') ?? [];
      tags.removeWhere((t) => t == tag);
      model.tags = tags.isNotEmpty ? tags.join(',') : null;

      await isar.writeTxn(() async {
        await isar.favoriteItemModels.put(model);
      });

      _logger.i('[Favorites] ✓ Tag removed: $tag from favorite $id');
    } catch (e) {
      _logger.e('[Favorites] Error removing tag: $e');
      rethrow;
    }
  }

  /// 增加访问计数（用户访问时调用）
  ///
  /// 参数：
  /// - [id] 收藏项目 ID
  Future<void> recordAccess(int id) async {
    try {
      final isar = IsarDatabaseService.isar;

      final model = await isar.favoriteItemModels.get(id);
      if (model == null) {
        _logger.w('[Favorites] Favorite not found: $id');
        return;
      }

      model.accessCount++;
      model.lastAccessedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.favoriteItemModels.put(model);
      });

      _logger.d('[Favorites] Access recorded for favorite: $id');
    } catch (e) {
      _logger.e('[Favorites] Error recording access: $e');
      rethrow;
    }
  }

  /// 删除单个收藏
  ///
  /// 参数：
  /// - [id] 收藏项目 ID
  ///
  /// 返回是否删除成功
  Future<bool> removeFavorite(int id) async {
    try {
      final isar = IsarDatabaseService.isar;

      final success = await isar.writeTxn(() async {
        return await isar.favoriteItemModels.delete(id);
      });

      _logger.i('[Favorites] ✓ Favorite removed: $id');
      return success;
    } catch (e) {
      _logger.e('[Favorites] Error removing favorite: $e');
      rethrow;
    }
  }

  /// 删除所有收藏
  ///
  /// 返回删除的项目数
  Future<int> removeAllFavorites() async {
    try {
      final isar = IsarDatabaseService.isar;

      final count = await isar.writeTxn(() async {
        return await isar.favoriteItemModels.where().deleteAll();
      });

      _logger.i('[Favorites] ✓ All favorites removed: $count items');
      return count;
    } catch (e) {
      _logger.e('[Favorites] Error removing all favorites: $e');
      rethrow;
    }
  }

  /// 获取收藏总数
  Future<int> getFavoriteCount() async {
    try {
      final isar = IsarDatabaseService.isar;
      return await isar.favoriteItemModels.where().count();
    } catch (e) {
      _logger.e('[Favorites] Error getting favorite count: $e');
      rethrow;
    }
  }

  /// 获取所有标签及其计数
  ///
  /// 返回标签映射（标签 → 计数）
  Future<Map<String, int>> getAllTags() async {
    try {
      final isar = IsarDatabaseService.isar;

      final models = await isar.favoriteItemModels.where().findAll();
      final tagMap = <String, int>{};

      for (final model in models) {
        if (model.tags != null) {
          final tags = model.tags!.split(',');
          for (final tag in tags) {
            tagMap[tag] = (tagMap[tag] ?? 0) + 1;
          }
        }
      }

      _logger.d('[Favorites] Found ${tagMap.length} unique tags');
      return tagMap;
    } catch (e) {
      _logger.e('[Favorites] Error getting all tags: $e');
      rethrow;
    }
  }

  /// 导出收藏为 JSON
  ///
  /// 返回 JSON 格式的字符串
  Future<String> exportFavoritesAsJson() async {
    try {
      final items = await getAllFavorites(limit: 10000);

      final jsonList = items
          .map((item) => {
                'type': item.type.toString(),
                'title': item.title,
                'sourceText': item.sourceText,
                'translatedText': item.translatedText,
                'sourceLang': item.sourceLang,
                'targetLang': item.targetLang,
                'tags': item.tags,
                'notes': item.notes,
                'createdAt': item.createdAt.toIso8601String(),
                'lastAccessedAt': item.lastAccessedAt?.toIso8601String(),
                'accessCount': item.accessCount,
              })
          .toList();

      _logger.i('[Favorites] ✓ Exported ${items.length} favorites');
      return jsonList.toString(); // 实际应用中应转为 JSON 字符串
    } catch (e) {
      _logger.e('[Favorites] Error exporting favorites: $e');
      rethrow;
    }
  }
}

/// 收藏管理器 Provider
final favoritesManagerProvider = Provider<FavoritesManager>((ref) {
  return FavoritesManager();
});

/// 收藏列表 Provider（异步）
final favoritesProvider = FutureProvider<List<FavoriteItem>>((ref) async {
  final manager = ref.watch(favoritesManagerProvider);
  return manager.getAllFavorites(limit: 100);
});

/// 收藏总数 Provider（异步）
final favoriteCountProvider = FutureProvider<int>((ref) async {
  final manager = ref.watch(favoritesManagerProvider);
  return manager.getFavoriteCount();
});

/// 所有标签 Provider（异步）
final allTagsProvider = FutureProvider<Map<String, int>>((ref) async {
  final manager = ref.watch(favoritesManagerProvider);
  return manager.getAllTags();
});
