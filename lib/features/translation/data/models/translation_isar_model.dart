import 'package:isar/isar.dart';

part 'translation_isar_model.g.dart';

/// Isar 数据库中的翻译记录集合
@Collection()
class TranslationIsarModel {
  Id id = Isar.autoIncrement;

  late String sourceText;
  late String targetText;
  late String sourceLang;
  late String targetLang;
  late DateTime timestamp;
  late bool isFavorite;
  String? notes;

  /// 用于快速搜索的令牌
  late List<String> searchTokens;
}

/// Isar 数据库中的保存词汇集合
@Collection()
class SavedWordIsarModel {
  Id id = Isar.autoIncrement;

  late String word;
  late String definition;
  late String language;
  late DateTime addedDate;
  String? phonetic;
  String? example;
}
