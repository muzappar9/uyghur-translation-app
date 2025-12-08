/// 翻译历史模型 - 基于 Hive 存储
/// 
/// 替代原有的 Isar TranslationHistoryModel
class TranslationHistoryModel {
  final int id;
  final String sourceText;
  final String targetText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final bool isFavorite;
  final bool isSynced;

  TranslationHistoryModel({
    required this.id,
    required this.sourceText,
    required this.targetText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    this.isFavorite = false,
    this.isSynced = false,
  });

  /// 从 Map 创建
  factory TranslationHistoryModel.fromMap(Map<String, dynamic> map) {
    return TranslationHistoryModel(
      id: map['id'] as int,
      sourceText: map['sourceText'] as String? ?? '',
      targetText: map['targetText'] as String? ?? '',
      sourceLanguage: map['sourceLanguage'] as String? ?? 'zh',
      targetLanguage: map['targetLanguage'] as String? ?? 'ug',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      isFavorite: map['isFavorite'] as bool? ?? false,
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceText': sourceText,
      'targetText': targetText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isSynced': isSynced,
    };
  }

  /// 复制并修改属性
  TranslationHistoryModel copyWith({
    int? id,
    String? sourceText,
    String? targetText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isSynced,
  }) {
    return TranslationHistoryModel(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      targetText: targetText ?? this.targetText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

/// 收藏项模型
class FavoriteItemModel {
  final int id;
  final String sourceText;
  final String targetText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final String? note;

  FavoriteItemModel({
    required this.id,
    required this.sourceText,
    required this.targetText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    this.note,
  });

  factory FavoriteItemModel.fromMap(Map<String, dynamic> map) {
    return FavoriteItemModel(
      id: map['id'] as int,
      sourceText: map['sourceText'] as String? ?? '',
      targetText: map['targetText'] as String? ?? '',
      sourceLanguage: map['sourceLanguage'] as String? ?? 'zh',
      targetLanguage: map['targetLanguage'] as String? ?? 'ug',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceText': sourceText,
      'targetText': targetText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }
}

/// OCR 结果模型
class OcrResultModel {
  final int id;
  final String imagePath;
  final String recognizedText;
  final String language;
  final DateTime createdAt;
  final double? confidence;
  final bool isSynced;

  OcrResultModel({
    required this.id,
    required this.imagePath,
    required this.recognizedText,
    required this.language,
    required this.createdAt,
    this.confidence,
    this.isSynced = false,
  });

  factory OcrResultModel.fromMap(Map<String, dynamic> map) {
    return OcrResultModel(
      id: map['id'] as int,
      imagePath: map['imagePath'] as String? ?? '',
      recognizedText: map['recognizedText'] as String? ?? '',
      language: map['language'] as String? ?? 'zh',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      confidence: map['confidence'] as double?,
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'recognizedText': recognizedText,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'confidence': confidence,
      'isSynced': isSynced,
    };
  }
}

/// 用户偏好设置模型
class UserPreferencesModel {
  final String sourceLanguage;
  final String targetLanguage;
  final String theme;
  final double fontSize;
  final bool autoDetectLanguage;
  final bool saveHistory;

  UserPreferencesModel({
    this.sourceLanguage = 'zh',
    this.targetLanguage = 'ug',
    this.theme = 'system',
    this.fontSize = 16.0,
    this.autoDetectLanguage = true,
    this.saveHistory = true,
  });

  factory UserPreferencesModel.fromMap(Map<String, dynamic> map) {
    return UserPreferencesModel(
      sourceLanguage: map['sourceLanguage'] as String? ?? 'zh',
      targetLanguage: map['targetLanguage'] as String? ?? 'ug',
      theme: map['theme'] as String? ?? 'system',
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 16.0,
      autoDetectLanguage: map['autoDetectLanguage'] as bool? ?? true,
      saveHistory: map['saveHistory'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'theme': theme,
      'fontSize': fontSize,
      'autoDetectLanguage': autoDetectLanguage,
      'saveHistory': saveHistory,
    };
  }

  UserPreferencesModel copyWith({
    String? sourceLanguage,
    String? targetLanguage,
    String? theme,
    double? fontSize,
    bool? autoDetectLanguage,
    bool? saveHistory,
  }) {
    return UserPreferencesModel(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
      saveHistory: saveHistory ?? this.saveHistory,
    );
  }
}

/// 待同步模型
class PendingSyncModel {
  final int id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  PendingSyncModel({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory PendingSyncModel.fromMap(Map<String, dynamic> map) {
    return PendingSyncModel(
      id: map['id'] as int,
      type: map['type'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      retryCount: map['retryCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }
}

/// 分析事件模型
class AnalyticsEventModel {
  final String id;
  final String eventName;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  AnalyticsEventModel({
    required this.id,
    required this.eventName,
    required this.parameters,
    required this.timestamp,
  });

  factory AnalyticsEventModel.fromMap(Map<String, dynamic> map) {
    return AnalyticsEventModel(
      id: map['id'] as String,
      eventName: map['eventName'] as String? ?? '',
      parameters: Map<String, dynamic>.from(map['parameters'] as Map? ?? {}),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
