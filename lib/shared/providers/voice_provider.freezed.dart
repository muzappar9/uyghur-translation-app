// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VoiceState {
  bool get isListening => throw _privateConstructorUsedError;
  String get recognizedText => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isProcessing => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  bool get hasPermission => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VoiceStateCopyWith<VoiceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceStateCopyWith<$Res> {
  factory $VoiceStateCopyWith(
          VoiceState value, $Res Function(VoiceState) then) =
      _$VoiceStateCopyWithImpl<$Res, VoiceState>;
  @useResult
  $Res call(
      {bool isListening,
      String recognizedText,
      String? error,
      bool isProcessing,
      String language,
      bool hasPermission});
}

/// @nodoc
class _$VoiceStateCopyWithImpl<$Res, $Val extends VoiceState>
    implements $VoiceStateCopyWith<$Res> {
  _$VoiceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isListening = null,
    Object? recognizedText = null,
    Object? error = freezed,
    Object? isProcessing = null,
    Object? language = null,
    Object? hasPermission = null,
  }) {
    return _then(_value.copyWith(
      isListening: null == isListening
          ? _value.isListening
          : isListening // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$VoiceStateImplCopyWith<$Res>
    implements $VoiceStateCopyWith<$Res> {
  factory _$$VoiceStateImplCopyWith(
          _$VoiceStateImpl value, $Res Function(_$VoiceStateImpl) then) =
      __$$VoiceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isListening,
      String recognizedText,
      String? error,
      bool isProcessing,
      String language,
      bool hasPermission});
}

/// @nodoc
class __$$VoiceStateImplCopyWithImpl<$Res>
    extends _$VoiceStateCopyWithImpl<$Res, _$VoiceStateImpl>
    implements _$$VoiceStateImplCopyWith<$Res> {
  __$$VoiceStateImplCopyWithImpl(
      _$VoiceStateImpl _value, $Res Function(_$VoiceStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isListening = null,
    Object? recognizedText = null,
    Object? error = freezed,
    Object? isProcessing = null,
    Object? language = null,
    Object? hasPermission = null,
  }) {
    return _then(_$VoiceStateImpl(
      isListening: null == isListening
          ? _value.isListening
          : isListening // ignore: cast_nullable_to_non_nullable
              as bool,
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

class _$VoiceStateImpl implements _VoiceState {
  const _$VoiceStateImpl(
      {this.isListening = false,
      this.recognizedText = '',
      this.error = null,
      this.isProcessing = false,
      this.language = 'en',
      this.hasPermission = false});

  @override
  @JsonKey()
  final bool isListening;
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
    return 'VoiceState(isListening: $isListening, recognizedText: $recognizedText, error: $error, isProcessing: $isProcessing, language: $language, hasPermission: $hasPermission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceStateImpl &&
            (identical(other.isListening, isListening) ||
                other.isListening == isListening) &&
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
  int get hashCode => Object.hash(runtimeType, isListening, recognizedText,
      error, isProcessing, language, hasPermission);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceStateImplCopyWith<_$VoiceStateImpl> get copyWith =>
      __$$VoiceStateImplCopyWithImpl<_$VoiceStateImpl>(this, _$identity);
}

abstract class _VoiceState implements VoiceState {
  const factory _VoiceState(
      {final bool isListening,
      final String recognizedText,
      final String? error,
      final bool isProcessing,
      final String language,
      final bool hasPermission}) = _$VoiceStateImpl;

  @override
  bool get isListening;
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
  _$$VoiceStateImplCopyWith<_$VoiceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
