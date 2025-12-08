import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/word_entry.dart';
import '../../data/repositories/dictionary_repository.dart';

// Mock 字典数据（演示用）
final List<WordEntry> _mockWords = [
  WordEntry(
    id: '1',
    word: 'hello',
    language: 'en',
    pronunciation: 'həˈloʊ',
    definition: 'A greeting or expression of goodwill',
    senses: [],
    relatedWords: [],
    examples: ['Hello, how are you?'],
    addedDate: DateTime.now().subtract(const Duration(days: 5)),
  ),
  WordEntry(
    id: '2',
    word: 'سلام',
    language: 'ug',
    pronunciation: 'salam',
    definition: '维吾尔语的问候语，意为"你好"',
    senses: [],
    relatedWords: [],
    examples: ['سلام، نەڭ ھال؟'],
    addedDate: DateTime.now().subtract(const Duration(days: 4)),
  ),
  WordEntry(
    id: '3',
    word: '你好',
    language: 'zh',
    pronunciation: 'nǐ hǎo',
    definition: '中文的基本问候语',
    senses: [],
    relatedWords: [],
    examples: ['你好，你好吗？'],
    addedDate: DateTime.now().subtract(const Duration(days: 3)),
  ),
  WordEntry(
    id: '4',
    word: 'thank you',
    language: 'en',
    pronunciation: 'θæŋk juː',
    definition: 'Expression of gratitude',
    senses: [],
    relatedWords: [],
    examples: ['Thank you very much!'],
    addedDate: DateTime.now().subtract(const Duration(days: 2)),
    isFavorite: true,
  ),
  WordEntry(
    id: '5',
    word: 'رەھمەت',
    language: 'ug',
    pronunciation: 'rahmat',
    definition: '维吾尔语的感谢用语',
    senses: [],
    relatedWords: [],
    examples: ['رەھمەت!'],
    addedDate: DateTime.now().subtract(const Duration(days: 1)),
    isFavorite: true,
  ),
];

// Dictionary Repository Provider
final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return _MockDictionaryRepository();
});

// 搜索单词
final dictionarySearchProvider =
    FutureProvider.family<List<WordEntry>, String>((ref, query) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  if (query.isEmpty) {
    return [];
  }
  return repo.searchWords(query);
});

// 推荐单词（最近添加的）
final dictionaryRecommendedProvider =
    FutureProvider<List<WordEntry>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getRecentWords(limit: 6);
});

// 收藏单词
final dictionaryFavoritesProvider =
    FutureProvider<List<WordEntry>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getFavoriteWords();
});

// 单词详情
final dictionaryDetailProvider =
    FutureProvider.family<WordEntry?, String>((ref, wordId) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getWordById(wordId);
});

// 分类列表
final dictionaryCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getCategories();
});

// Mock Repository 实现（用于开发阶段）
class _MockDictionaryRepository implements DictionaryRepository {
  @override
  Future<List<WordEntry>> searchWords(String query, {String? language}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockWords
        .where((word) =>
            word.word.toLowerCase().contains(query.toLowerCase()) ||
            (word.definition?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .where((word) => language == null || word.language == language)
        .toList();
  }

  @override
  Future<WordEntry?> getWordById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockWords.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WordEntry>> getFavoriteWords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockWords.where((w) => w.isFavorite).toList();
  }

  @override
  Future<List<WordEntry>> getRecentWords({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockWords.take(limit).toList();
  }

  @override
  Future<void> addToFavorites(String wordId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> removeFromFavorites(String wordId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> addWord(WordEntry word) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['Basic', 'Travel', 'Business', 'Daily Life'];
  }
}
