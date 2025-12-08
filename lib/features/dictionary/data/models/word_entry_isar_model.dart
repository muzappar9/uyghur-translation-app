// Isar 模型 (需要运行 flutter pub run build_runner build 生成 .g.dart)
// 暂时注释，使用 Mock 数据替代
//
// import 'package:isar/isar.dart';
//
// part 'word_entry_isar_model.g.dart';
//
// @Collection()
// class WordEntryIsarModel {
//   Id id = Isar.autoIncrement;
//
//   late String word;
//   late String language; // 'ug' | 'zh' | 'en'
//   late String pronunciation;
//   String? definition;
//   late DateTime addedDate;
//   late bool isFavorite;
//   String? category;
//
//   // 搜索优化
//   late List<String> searchTokens;
//
//   // 关联数据 (将通过关系查询)
//   final relatedWords = IsarLink<RelatedWordIsarModel>();
//   final senses = IsarLinks<WordSenseIsarModel>();
// }
//
// @Collection()
// class WordSenseIsarModel {
//   Id id = Isar.autoIncrement;
//
//   late int orderIndex;
//   late String definition;
//   late String partOfSpeech;
//   late List<String> examples;
//   List<String>? synonyms;
//   List<String>? antonyms;
//
//   final word = IsarLink<WordEntryIsarModel>();
// }
//
// @Collection()
// class RelatedWordIsarModel {
//   Id id = Isar.autoIncrement;
//
//   late String relatedWord;
//   late DateTime addedDate;
//
//   final word = IsarLink<WordEntryIsarModel>();
// }
