import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation.freezed.dart';

/// 翻译结果实体
@freezed
class Translation with _$Translation {
  const factory Translation({
    required String id,
    required String sourceText,
    required String targetText,
    required String sourceLang,
    required String targetLang,
    required DateTime timestamp,
    @Default(false) bool isFavorite,
    @Default(null) String? notes,
  }) = _Translation;
}

/// 翻译请求对象
@freezed
class TranslationRequest with _$TranslationRequest {
  const factory TranslationRequest({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) = _TranslationRequest;
}

/// 全局应用状态
@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default('zh') String currentLanguage,
    @Default('en') String sourceLanguage,
    @Default('zh') String targetLanguage,
    @Default(false) bool isDarkMode,
    @Default(null) String? userId,
    @Default(false) bool isInitialized,
    @Default(true) bool isOnline,
  }) = _AppState;
}
