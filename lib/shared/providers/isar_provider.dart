import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uyghur_translator/features/translation/data/models/translation_isar_model.dart';

/// Isar 数据库实例 Provider
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open(
    [TranslationIsarModelSchema, SavedWordIsarModelSchema],
    directory: dir.path,
    inspector: true, // 开发时启用调试
  );

  ref.onDispose(() {
    isar.close();
  });

  return isar;
});
