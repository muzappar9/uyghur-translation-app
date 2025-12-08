import 'package:isar/isar.dart';

part 'pending_sync_model.g.dart';

@collection
class PendingSyncModel {
  Id id = Isar.autoIncrement;
  
  late String entityType;
  String? type;
  late String entityId;
  late String action; // 'create', 'update', 'delete'
  late String jsonData;
  String? data;
  late DateTime timestamp;
  DateTime? createdAt;
  
  int retryCount = 0;
  String? errorMessage;
  bool isCompleted = false;
  
  PendingSyncModel();
  
  factory PendingSyncModel.create({
    required String entityType,
    required String entityId,
    required String action,
    required String jsonData,
    String? type,
    String? data,
    DateTime? createdAt,
    int retryCount = 0,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();
    return PendingSyncModel()
      ..entityType = entityType
      ..type = type ?? entityType
      ..entityId = entityId
      ..action = action
      ..jsonData = jsonData
      ..data = data ?? jsonData
      ..timestamp = now
      ..createdAt = createdAt ?? now
      ..retryCount = retryCount
      ..isCompleted = isCompleted;
  }
}
