import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uyghur_translator/features/translation/data/repositories/translation_repository.dart';
import 'package:uyghur_translator/features/translation/data/repositories/pending_translation_repository.dart';
import 'package:uyghur_translator/shared/services/api/api_client.dart';
import 'package:uyghur_translator/features/translation/data/models/pending_translation_model.dart';

// ============ Mock Classes for Testing ============

/// Mock Isar database instance using mocktail
class MockIsar extends Mock implements Isar {}

/// Mock IsarCollection for testing database operations
class MockIsarCollection<T> extends Mock implements IsarCollection<T> {}

/// Mock QueryBuilder for testing queries
class MockQueryBuilder extends Mock implements QueryBuilder {}

/// Mock Connectivity for network monitoring
class MockConnectivity extends Mock implements Connectivity {}

/// Mock API Client
class MockApiClient extends Mock implements ApiClient {}

/// Mock TranslationRepository
class MockTranslationRepository extends Mock implements TranslationRepository {}

/// Mock PendingTranslationRepository
class MockPendingTranslationRepository extends Mock
    implements PendingTranslationRepository {}

/// Fake PendingTranslationModel for testing
class FakePendingTranslationModel extends Fake
    implements PendingTranslationModel {
  @override
  late Id id;

  @override
  late String sourceText;

  @override
  late String sourceLang;

  @override
  late String targetLang;

  @override
  late DateTime createdAt;

  @override
  late int retryCount;

  @override
  late DateTime? lastRetryAt;

  @override
  late String? errorMessage;

  @override
  late bool isSynced;
}
