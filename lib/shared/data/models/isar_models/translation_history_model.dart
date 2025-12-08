import 'package:isar/isar.dart';

part 'translation_history_model.g.dart';

@collection
class TranslationHistoryModel {
  Id id = Isar.autoIncrement;
  
  late String sourceText;
  late String targetText;
  String? translatedText;
  late String sourceLanguage;
  late String targetLanguage;
  String? sourceType;
  late DateTime timestamp;
  String? userId;
  
  bool isFavorite = false;
  bool isSynced = false;
  String? syncId;
  
  TranslationHistoryModel();
  
  factory TranslationHistoryModel.create({
    required String sourceText,
    required String targetText,
    required String sourceLanguage,
    required String targetLanguage,
    String? translatedText,
    String? sourceType,
    String? userId,
    bool isFavorite = false,
  }) {
    return TranslationHistoryModel()
      ..sourceText = sourceText
      ..targetText = targetText
      ..translatedText = translatedText ?? targetText
      ..sourceLanguage = sourceLanguage
      ..targetLanguage = targetLanguage
      ..sourceType = sourceType
      ..userId = userId
      ..timestamp = DateTime.now()
      ..isFavorite = isFavorite
      ..isSynced = false;
  }
}
