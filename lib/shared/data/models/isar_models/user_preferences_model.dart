import 'package:isar/isar.dart';

part 'user_preferences_model.g.dart';

@collection
class UserPreferencesModel {
  Id id = Isar.autoIncrement;
  
  String? userId;
  String sourceLanguage = 'zh';
  String targetLanguage = 'ug';
  String theme = 'system';
  double fontSize = 16.0;
  bool autoDetectLanguage = true;
  bool saveHistory = true;
  bool hapticFeedback = true;
  bool darkMode = false;
  bool enableNotifications = true;
  bool enableOfflineMode = true;
  DateTime? lastUpdated;
  
  UserPreferencesModel();
  
  factory UserPreferencesModel.defaults() {
    return UserPreferencesModel()
      ..lastUpdated = DateTime.now();
  }
}
