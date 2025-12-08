/// 词条数据模型
class WordEntry {
  final String id;
  final String word;
  final String language; // 'ug' | 'zh' | 'en'
  final String pronunciation;
  final String? definition;
  final List<WordSense> senses;
  final List<String> relatedWords;
  final List<String>? examples;
  final String? category;
  final DateTime addedDate;
  final bool isFavorite;

  const WordEntry({
    required this.id,
    required this.word,
    required this.language,
    required this.pronunciation,
    required this.senses,
    required this.relatedWords,
    required this.addedDate,
    this.isFavorite = false,
    this.definition,
    this.examples,
    this.category,
  });

  WordEntry copyWith({
    String? id,
    String? word,
    String? language,
    String? pronunciation,
    String? definition,
    List<WordSense>? senses,
    List<String>? relatedWords,
    List<String>? examples,
    String? category,
    DateTime? addedDate,
    bool? isFavorite,
  }) {
    return WordEntry(
      id: id ?? this.id,
      word: word ?? this.word,
      language: language ?? this.language,
      pronunciation: pronunciation ?? this.pronunciation,
      definition: definition ?? this.definition,
      senses: senses ?? this.senses,
      relatedWords: relatedWords ?? this.relatedWords,
      examples: examples ?? this.examples,
      category: category ?? this.category,
      addedDate: addedDate ?? this.addedDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// 词义/释义
class WordSense {
  final int id;
  final String definition;
  final String partOfSpeech; // 'noun', 'verb', 'adj', etc.
  final List<String> examples;
  final List<String>? synonyms;
  final List<String>? antonyms;

  const WordSense({
    required this.id,
    required this.definition,
    required this.partOfSpeech,
    required this.examples,
    this.synonyms,
    this.antonyms,
  });
}

/// 字典过滤器
class DictionaryFilter {
  final String searchQuery;
  final String language;
  final String category;
  final bool onlyFavorites;

  const DictionaryFilter({
    this.searchQuery = '',
    this.language = '',
    this.category = '',
    this.onlyFavorites = false,
  });
}
