// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OcrState {
  String? get imagePath => throw _privateConstructorUsedError;
  String get recognizedText => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isProcessing => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  bool get hasPermission => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OcrStateCopyWith<OcrState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OcrStateCopyWith<$Res> {
  factory $OcrStateCopyWith(OcrState value, $Res Function(OcrState) then) =
      _$OcrStateCopyWithImpl<$Res, OcrState>;
  @useResult
  $Res call(
      {String? imagePath,
      String recognizedText,
      String? error,
      bool isProcessing,
      String language,
      bool hasPermission});
}

/// @nodoc
class _$OcrStateCopyWithImpl<$Res, $Val extends OcrState>
    implements $OcrStateCopyWith<$Res> {
  _$OcrStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = freezed,
    Object? recognizedText = null,
    Object? error = freezed,
    Object? isProcessing = null,
    Object? language = null,
    Object? hasPermission = null,
  }) {
    return _then(_value.copyWith(
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      recognizedText: null == recognizedText
          ? _value.recognizedText
          : recognizedText // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      hasPermission: null == hasPermission
          ? _value.hasPermission
          : hasPermission // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OcrStateImplCopyWith<$Res>
    implements $OcrStateCopyWith<$Res> {
  factory _$$OcrStateImplCopyWith(
          _$OcrStateImpl value, $Res Function(_$OcrStateImpl) then) =
      __$$OcrStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? imagePath,
      String recognizedText,
      String? error,
      bool isProcessing,
      String language,
      bool hasPermission});
}

/// @nodoc
class __$$OcrStateImplCopyWithImpl<$Res>
    extends _$OcrStateCopyWithImpl<$Res, _$OcrStateImpl>
    implements _$$OcrStateImplCopyWith<$Res> {
  __$$OcrStateImplCopyWithImpl(
      _$OcrStateImpl _value, $Res Function(_$OcrStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = freezed,
    Object? recognizedText = null,
    Object? error = freezed,
    Object? isProcessing = null,
    Object? language = null,
    Object? hasPermission = null,
  }) {
    return _then(_$OcrStateImpl(
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      recognizedText: null == recognizedText
          ? _value.recognizedText
          : recognizedText // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      hasPermission: null == hasPermission
          ? _value.hasPermission
          : hasPermission // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$OcrStateImpl implements _OcrState {
  const _$OcrStateImpl(
      {this.imagePath = null,
      this.recognizedText = '',
      this.error = null,
      this.isProcessing = false,
      this.language = 'en',
      this.hasPermission = false});

  @override
  @JsonKey()
  final String? imagePath;
  @override
  @JsonKey()
  final String recognizedText;
  @override
  @JsonKey()
  final String? error;
  @override
  @JsonKey()
  final bool isProcessing;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final bool hasPermission;

  @override
  String toString() {
    return 'OcrState(imagePath: $imagePath, recognizedText: $recognizedText, error: $error, isProcessing: $isProcessing, language: $language, hasPermission: $hasPermission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OcrStateImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.recognizedText, recognizedText) ||
                other.recognizedText == recognizedText) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.hasPermission, hasPermission) ||
                other.hasPermission == hasPermission));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imagePath, recognizedText, error,
      isProcessing, language, hasPermission);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OcrStateImplCopyWith<_$OcrStateImpl> get copyWith =>
      __$$OcrStateImplCopyWithImpl<_$OcrStateImpl>(this, _$identity);
}

abstract class _OcrState implements OcrState {
  const factory _OcrState(
      {final String? imagePath,
      final String recognizedText,
      final String? error,
      final bool isProcessing,
      final String language,
      final bool hasPermission}) = _$OcrStateImpl;

  @override
  String? get imagePath;
  @override
  String get recognizedText;
  @override
  String? get error;
  @override
  bool get isProcessing;
  @override
  String get language;
  @override
  bool get hasPermission;
  @override
  @JsonKey(ignore: true)
  _$$OcrStateImplCopyWith<_$OcrStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
