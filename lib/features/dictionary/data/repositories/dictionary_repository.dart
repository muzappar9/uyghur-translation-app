import '../../domain/entities/word_entry.dart';

abstract class DictionaryRepository {
  Future<List<WordEntry>> searchWords(String query, {String? language});
  Future<WordEntry?> getWordById(String id);
  Future<List<WordEntry>> getFavoriteWords();
  Future<List<WordEntry>> getRecentWords({int limit = 10});
  Future<void> addToFavorites(String wordId);
  Future<void> removeFromFavorites(String wordId);
  Future<void> addWord(WordEntry word);
  Future<List<String>> getCategories();
}

class DictionaryRepositoryImpl implements DictionaryRepository {
  DictionaryRepositoryImpl();

  // 模拟词典数据
  final List<WordEntry> _mockWords = [
    WordEntry(
      id: '1',
      word: '你好',
      language: 'zh',
      pronunciation: 'nǐ hǎo',
      definition: 'Hello, a greeting',
      senses: const [
        WordSense(
          id: 1,
          definition: '问候语，用于见面时打招呼',
          partOfSpeech: 'interjection',
          examples: ['你好，很高兴认识你。', '你好，请问有什么可以帮您？'],
        ),
      ],
      relatedWords: const ['您好', '早上好', '晚上好'],
      examples: const ['你好，我是张三。', '你好！今天天气真好。'],
      category: 'Basic',
      addedDate: DateTime.now(),
      isFavorite: true,
    ),
    WordEntry(
      id: '2',
      word: 'سالام',
      language: 'ug',
      pronunciation: 'salam',
      definition: '问候语，你好',
      senses: const [
        WordSense(
          id: 1,
          definition: 'ساﻻملاشما ئۈچۈن ئىشلىتىلىدىغان سۆز',
          partOfSpeech: 'interjection',
          examples: ['سالام، مەن سىزنى تونۇپ بەكئۇشال بولدۇم.'],
        ),
      ],
      relatedWords: const ['ياخشىمۇسىز', 'خەيرلىك تاڭ'],
      examples: const ['سالام، قانداق ئەھۋالىڭىز؟'],
      category: 'Basic',
      addedDate: DateTime.now(),
      isFavorite: false,
    ),
    WordEntry(
      id: '3',
      word: '谢谢',
      language: 'zh',
      pronunciation: 'xiè xiè',
      definition: 'Thank you, express gratitude',
      senses: const [
        WordSense(
          id: 1,
          definition: '表示感谢的用语',
          partOfSpeech: 'verb',
          examples: ['谢谢你的帮助。', '非常谢谢！'],
        ),
      ],
      relatedWords: const ['感谢', '多谢', '谢了'],
      examples: const ['谢谢你送我回家。', '谢谢大家的支持！'],
      category: 'Basic',
      addedDate: DateTime.now(),
      isFavorite: true,
    ),
    WordEntry(
      id: '4',
      word: 'رەھمەت',
      language: 'ug',
      pronunciation: 'rehmet',
      definition: '感谢，谢谢',
      senses: const [
        WordSense(
          id: 1,
          definition: 'مىننەتدارلىق بىلدۈرۈش ئۈچۈن ئىشلىتىلىدىغان سۆز',
          partOfSpeech: 'noun',
          examples: ['رەھمەت سىزگە!', 'كۆپ رەھمەت!'],
        ),
      ],
      relatedWords: const ['تەشەككۈر', 'مىننەتدار'],
      examples: const ['ياردەم قىلغانلىقىڭىزغا رەھمەت.'],
      category: 'Basic',
      addedDate: DateTime.now(),
      isFavorite: false,
    ),
    WordEntry(
      id: '5',
      word: '旅行',
      language: 'zh',
      pronunciation: 'lǚ xíng',
      definition: 'Travel, journey',
      senses: const [
        WordSense(
          id: 1,
          definition: '到远方去游览，出行',
          partOfSpeech: 'verb/noun',
          examples: ['我喜欢旅行。', '这次旅行很愉快。'],
        ),
      ],
      relatedWords: const ['旅游', '出行', '远行'],
      examples: const ['暑假我们计划去新疆旅行。'],
      category: 'Travel',
      addedDate: DateTime.now(),
      isFavorite: false,
    ),
    WordEntry(
      id: '6',
      word: 'ساياھەت',
      language: 'ug',
      pronunciation: 'sayahet',
      definition: '旅行，旅游',
      senses: const [
        WordSense(
          id: 1,
          definition: 'يىراق جايلارغا بىرىپ ئايلىنىپ كېلىش',
          partOfSpeech: 'noun',
          examples: ['مەن ساياھەت قىلىشنى ياخشى كۆرىمەن.'],
        ),
      ],
      relatedWords: const ['سەيلە', 'سەپەر'],
      examples: const ['بىز يازدا شىنجاڭغا ساياھەت قىلىمىز.'],
      category: 'Travel',
      addedDate: DateTime.now(),
      isFavorite: false,
    ),
  ];

  final Set<String> _favoriteIds = {'1', '3'};
  final List<String> _recentIds = ['1', '2', '3', '4'];

  @override
  Future<List<WordEntry>> searchWords(String query, {String? language}) async {
    if (query.isEmpty) {
      return [];
    }
    await Future.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();
    return _mockWords.where((word) {
      final matchWord = word.word.toLowerCase().contains(lowerQuery);
      final matchDefinition =
          (word.definition ?? '').toLowerCase().contains(lowerQuery);
      final matchLanguage = language == null || word.language == language;
      return (matchWord || matchDefinition) && matchLanguage;
    }).toList();
  }

  @override
  Future<WordEntry?> getWordById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockWords.firstWhere((word) => word.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WordEntry>> getFavoriteWords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockWords.where((word) => _favoriteIds.contains(word.id)).toList();
  }

  @override
  Future<List<WordEntry>> getRecentWords({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final recent = <WordEntry>[];
    for (final id in _recentIds.take(limit)) {
      final word = _mockWords.where((w) => w.id == id).firstOrNull;
      if (word != null) {
        recent.add(word);
      }
    }
    return recent;
  }

  @override
  Future<void> addToFavorites(String wordId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favoriteIds.add(wordId);
  }

  @override
  Future<void> removeFromFavorites(String wordId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favoriteIds.remove(wordId);
  }

  @override
  Future<void> addWord(WordEntry word) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockWords.add(word);
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['Basic', 'Travel', 'Business', 'Daily Life', 'Food', 'Numbers'];
  }
}
