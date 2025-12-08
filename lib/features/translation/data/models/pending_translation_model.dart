import 'package:isar/isar.dart';

part 'pending_translation_model.g.dart';

/// Isar 数据库中的待同步翻译队列
@Collection()
class PendingTranslationModel {
  Id id = Isar.autoIncrement;

  late String sourceText;
  late String sourceLang;
  late String targetLang;
  late DateTime createdAt;

  /// 重试次数
  late int retryCount = 0;

  /// 最后一次重试时间
  DateTime? lastRetryAt;

  /// 错误信息
  String? errorMessage;

  /// 是否已成功同步
  late bool isSynced = false;
}
