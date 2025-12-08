import 'package:isar/isar.dart';

part 'favorite_item_model.g.dart';

@collection
class FavoriteItemModel {
  Id id = Isar.autoIncrement;
  
  String? type;
  String? title;
  late String sourceText;
  late String targetText;
  String? translatedText;
  late String sourceLanguage;
  late String targetLanguage;
  String? sourceLang;
  String? targetLang;
  late DateTime addedAt;
  DateTime? createdAt;
  DateTime? lastAccessedAt;
  int accessCount = 0;
  
  List<String>? tags;
  String? category;
  String? note;
  String? notes;
  bool isSynced = false;
  String? syncId;
  
  FavoriteItemModel();
  
  factory FavoriteItemModel.create({
    required String sourceText,
    required String targetText,
    required String sourceLanguage,
    required String targetLanguage,
    String? type,
    String? title,
    String? translatedText,
    String? sourceLang,
    String? targetLang,
    List<String>? tags,
    String? category,
    String? note,
    String? notes,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    int accessCount = 0,
  }) {
    final now = DateTime.now();
    return FavoriteItemModel()
      ..type = type
      ..title = title
      ..sourceText = sourceText
      ..targetText = targetText
      ..translatedText = translatedText ?? targetText
      ..sourceLanguage = sourceLanguage
      ..targetLanguage = targetLanguage
      ..sourceLang = sourceLang ?? sourceLanguage
      ..targetLang = targetLang ?? targetLanguage
      ..addedAt = now
      ..createdAt = createdAt ?? now
      ..lastAccessedAt = lastAccessedAt ?? now
      ..accessCount = accessCount
      ..tags = tags
      ..category = category
      ..note = note
      ..notes = notes
      ..isSynced = false;
  }
}
