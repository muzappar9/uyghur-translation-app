// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TranslationState {
  String get sourceText => throw _privateConstructorUsedError;
  String get targetText => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String get sourceLanguage => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TranslationStateCopyWith<TranslationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationStateCopyWith<$Res> {
  factory $TranslationStateCopyWith(
          TranslationState value, $Res Function(TranslationState) then) =
      _$TranslationStateCopyWithImpl<$Res, TranslationState>;
  @useResult
  $Res call(
      {String sourceText,
      String targetText,
      bool isLoading,
      String? error,
      String sourceLanguage,
      String targetLanguage,
      bool isFavorite});
}

/// @nodoc
class _$TranslationStateCopyWithImpl<$Res, $Val extends TranslationState>
    implements $TranslationStateCopyWith<$Res> {
  _$TranslationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceText = null,
    Object? targetText = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? isFavorite = null,
  }) {
    return _then(_value.copyWith(
      sourceText: null == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String,
      targetText: null == targetText
          ? _value.targetText
          : targetText // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranslationStateImplCopyWith<$Res>
    implements $TranslationStateCopyWith<$Res> {
  factory _$$TranslationStateImplCopyWith(_$TranslationStateImpl value,
          $Res Function(_$TranslationStateImpl) then) =
      __$$TranslationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sourceText,
      String targetText,
      bool isLoading,
      String? error,
      String sourceLanguage,
      String targetLanguage,
      bool isFavorite});
}

/// @nodoc
class __$$TranslationStateImplCopyWithImpl<$Res>
    extends _$TranslationStateCopyWithImpl<$Res, _$TranslationStateImpl>
    implements _$$TranslationStateImplCopyWith<$Res> {
  __$$TranslationStateImplCopyWithImpl(_$TranslationStateImpl _value,
      $Res Function(_$TranslationStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sourceText = null,
    Object? targetText = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? isFavorite = null,
  }) {
    return _then(_$TranslationStateImpl(
      sourceText: null == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String,
      targetText: null == targetText
          ? _value.targetText
          : targetText // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TranslationStateImpl implements _TranslationState {
  const _$TranslationStateImpl(
      {this.sourceText = '',
      this.targetText = '',
      this.isLoading = false,
      this.error = null,
      this.sourceLanguage = 'en',
      this.targetLanguage = 'zh',
      this.isFavorite = false});

  @override
  @JsonKey()
  final String sourceText;
  @override
  @JsonKey()
  final String targetText;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;
  @override
  @JsonKey()
  final String sourceLanguage;
  @override
  @JsonKey()
  final String targetLanguage;
  @override
  @JsonKey()
  final bool isFavorite;

  @override
  String toString() {
    return 'TranslationState(sourceText: $sourceText, targetText: $targetText, isLoading: $isLoading, error: $error, sourceLanguage: $sourceLanguage, targetLanguage: $targetLanguage, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationStateImpl &&
            (identical(other.sourceText, sourceText) ||
                other.sourceText == sourceText) &&
            (identical(other.targetText, targetText) ||
                other.targetText == targetText) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.sourceLanguage, sourceLanguage) ||
                other.sourceLanguage == sourceLanguage) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sourceText, targetText,
      isLoading, error, sourceLanguage, targetLanguage, isFavorite);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationStateImplCopyWith<_$TranslationStateImpl> get copyWith =>
      __$$TranslationStateImplCopyWithImpl<_$TranslationStateImpl>(
          this, _$identity);
}

abstract class _TranslationState implements TranslationState {
  const factory _TranslationState(
      {final String sourceText,
      final String targetText,
      final bool isLoading,
      final String? error,
      final String sourceLanguage,
      final String targetLanguage,
      final bool isFavorite}) = _$TranslationStateImpl;

  @override
  String get sourceText;
  @override
  String get targetText;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  String get sourceLanguage;
  @override
  String get targetLanguage;
  @override
  bool get isFavorite;
  @override
  @JsonKey(ignore: true)
  _$$TranslationStateImplCopyWith<_$TranslationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
