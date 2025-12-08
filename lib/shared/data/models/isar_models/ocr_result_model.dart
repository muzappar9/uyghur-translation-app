import 'package:isar/isar.dart';

part 'ocr_result_model.g.dart';

@collection
class OcrResultModel {
  Id id = Isar.autoIncrement;
  
  late String imagePath;
  String? imageUrl;
  late String recognizedText;
  late String language;
  String? detectedLanguage;
  late DateTime timestamp;
  DateTime? createdAt;
  DateTime? lastModified;
  List<String>? editHistory;
  String? userId;
  
  bool isFavorite = false;
  bool isSynced = false;
  String? syncId;
  String? translatedText;
  
  OcrResultModel();
  
  factory OcrResultModel.create({
    required String imagePath,
    required String recognizedText,
    required String language,
    String? translatedText,
    String? imageUrl,
    String? detectedLanguage,
    String? userId,
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    return OcrResultModel()
      ..imagePath = imagePath
      ..imageUrl = imageUrl
      ..recognizedText = recognizedText
      ..language = language
      ..detectedLanguage = detectedLanguage
      ..timestamp = now
      ..createdAt = now
      ..lastModified = now
      ..translatedText = translatedText
      ..userId = userId
      ..isFavorite = isFavorite
      ..isSynced = false;
  }
}
