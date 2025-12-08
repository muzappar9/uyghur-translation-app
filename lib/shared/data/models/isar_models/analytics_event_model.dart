import 'package:isar/isar.dart';

part 'analytics_event_model.g.dart';

@collection
class AnalyticsEventModel {
  Id id = Isar.autoIncrement;
  
  late String eventName;
  late String eventType;
  String? type;
  late DateTime timestamp;
  
  String? jsonParameters;
  String? metadata;
  String? userId;
  String? sessionId;
  String? deviceInfo;
  bool isSynced = false;
  
  AnalyticsEventModel();
  
  factory AnalyticsEventModel.create({
    required String eventName,
    required String eventType,
    String? type,
    String? jsonParameters,
    String? metadata,
    String? userId,
    String? sessionId,
    String? deviceInfo,
  }) {
    return AnalyticsEventModel()
      ..eventName = eventName
      ..eventType = eventType
      ..type = type ?? eventType
      ..timestamp = DateTime.now()
      ..jsonParameters = jsonParameters
      ..metadata = metadata
      ..userId = userId
      ..sessionId = sessionId
      ..deviceInfo = deviceInfo
      ..isSynced = false;
  }
}
