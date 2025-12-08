// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Translation {
  String get id => throw _privateConstructorUsedError;
  String get sourceText => throw _privateConstructorUsedError;
  String get targetText => throw _privateConstructorUsedError;
  String get sourceLang => throw _privateConstructorUsedError;
  String get targetLang => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TranslationCopyWith<Translation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationCopyWith<$Res> {
  factory $TranslationCopyWith(
          Translation value, $Res Function(Translation) then) =
      _$TranslationCopyWithImpl<$Res, Translation>;
  @useResult
  $Res call(
      {String id,
      String sourceText,
      String targetText,
      String sourceLang,
      String targetLang,
      DateTime timestamp,
      bool isFavorite,
      String? notes});
}

/// @nodoc
class _$TranslationCopyWithImpl<$Res, $Val extends Translation>
    implements $TranslationCopyWith<$Res> {
  _$TranslationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceText = null,
    Object? targetText = null,
    Object? sourceLang = null,
    Object? targetLang = null,
    Object? timestamp = null,
    Object? isFavorite = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceText: null == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String,
      targetText: null == targetText
          ? _value.targetText
          : targetText // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLang: null == sourceLang
          ? _value.sourceLang
          : sourceLang // ignore: cast_nullable_to_non_nullable
              as String,
      targetLang: null == targetLang
          ? _value.targetLang
          : targetLang // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranslationImplCopyWith<$Res>
    implements $TranslationCopyWith<$Res> {
  factory _$$TranslationImplCopyWith(
          _$TranslationImpl value, $Res Function(_$TranslationImpl) then) =
      __$$TranslationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sourceText,
      String targetText,
      String sourceLang,
      String targetLang,
      DateTime timestamp,
      bool isFavorite,
      String? notes});
}

/// @nodoc
class __$$TranslationImplCopyWithImpl<$Res>
    extends _$TranslationCopyWithImpl<$Res, _$TranslationImpl>
    implements _$$TranslationImplCopyWith<$Res> {
  __$$TranslationImplCopyWithImpl(
      _$TranslationImpl _value, $Res Function(_$TranslationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceText = null,
    Object? targetText = null,
    Object? sourceLang = null,
    Object? targetLang = null,
    Object? timestamp = null,
    Object? isFavorite = null,
    Object? notes = freezed,
  }) {
    return _then(_$TranslationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceText: null == sourceText
          ? _value.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String,
      targetText: null == targetText
          ? _value.targetText
          : targetText // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLang: null == sourceLang
          ? _value.sourceLang
          : sourceLang // ignore: cast_nullable_to_non_nullable
              as String,
      targetLang: null == targetLang
          ? _value.targetLang
          : targetLang // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TranslationImpl implements _Translation {
  const _$TranslationImpl(
      {required this.id,
      required this.sourceText,
      required this.targetText,
      required this.sourceLang,
      required this.targetLang,
      required this.timestamp,
      this.isFavorite = false,
      this.notes = null});

  @override
  final String id;
  @override
  final String sourceText;
  @override
  final String targetText;
  @override
  final String sourceLang;
  @override
  final String targetLang;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  @JsonKey()
  final String? notes;

  @override
  String toString() {
    return 'Translation(id: $id, sourceText: $sourceText, targetText: $targetText, sourceLang: $sourceLang, targetLang: $targetLang, timestamp: $timestamp, isFavorite: $isFavorite, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceText, sourceText) ||
                other.sourceText == sourceText) &&
            (identical(other.targetText, targetText) ||
                other.targetText == targetText) &&
            (identical(other.sourceLang, sourceLang) ||
                other.sourceLang == sourceLang) &&
            (identical(other.targetLang, targetLang) ||
                other.targetLang == targetLang) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, sourceText, targetText,
      sourceLang, targetLang, timestamp, isFavorite, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationImplCopyWith<_$TranslationImpl> get copyWith =>
      __$$TranslationImplCopyWithImpl<_$TranslationImpl>(this, _$identity);
}

abstract class _Translation implements Translation {
  const factory _Translation(
      {required final String id,
      required final String sourceText,
      required final String targetText,
      required final String sourceLang,
      required final String targetLang,
      required final DateTime timestamp,
      final bool isFavorite,
      final String? notes}) = _$TranslationImpl;

  @override
  String get id;
  @override
  String get sourceText;
  @override
  String get targetText;
  @override
  String get sourceLang;
  @override
  String get targetLang;
  @override
  DateTime get timestamp;
  @override
  bool get isFavorite;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$TranslationImplCopyWith<_$TranslationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TranslationRequest {
  String get text => throw _privateConstructorUsedError;
  String get sourceLang => throw _privateConstructorUsedError;
  String get targetLang => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TranslationRequestCopyWith<TranslationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationRequestCopyWith<$Res> {
  factory $TranslationRequestCopyWith(
          TranslationRequest value, $Res Function(TranslationRequest) then) =
      _$TranslationRequestCopyWithImpl<$Res, TranslationRequest>;
  @useResult
  $Res call({String text, String sourceLang, String targetLang});
}

/// @nodoc
class _$TranslationRequestCopyWithImpl<$Res, $Val extends TranslationRequest>
    implements $TranslationRequestCopyWith<$Res> {
  _$TranslationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? sourceLang = null,
    Object? targetLang = null,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLang: null == sourceLang
          ? _value.sourceLang
          : sourceLang // ignore: cast_nullable_to_non_nullable
              as String,
      targetLang: null == targetLang
          ? _value.targetLang
          : targetLang // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranslationRequestImplCopyWith<$Res>
    implements $TranslationRequestCopyWith<$Res> {
  factory _$$TranslationRequestImplCopyWith(_$TranslationRequestImpl value,
          $Res Function(_$TranslationRequestImpl) then) =
      __$$TranslationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, String sourceLang, String targetLang});
}

/// @nodoc
class __$$TranslationRequestImplCopyWithImpl<$Res>
    extends _$TranslationRequestCopyWithImpl<$Res, _$TranslationRequestImpl>
    implements _$$TranslationRequestImplCopyWith<$Res> {
  __$$TranslationRequestImplCopyWithImpl(_$TranslationRequestImpl _value,
      $Res Function(_$TranslationRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? sourceLang = null,
    Object? targetLang = null,
  }) {
    return _then(_$TranslationRequestImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLang: null == sourceLang
          ? _value.sourceLang
          : sourceLang // ignore: cast_nullable_to_non_nullable
              as String,
      targetLang: null == targetLang
          ? _value.targetLang
          : targetLang // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TranslationRequestImpl implements _TranslationRequest {
  const _$TranslationRequestImpl(
      {required this.text, required this.sourceLang, required this.targetLang});

  @override
  final String text;
  @override
  final String sourceLang;
  @override
  final String targetLang;

  @override
  String toString() {
    return 'TranslationRequest(text: $text, sourceLang: $sourceLang, targetLang: $targetLang)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationRequestImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.sourceLang, sourceLang) ||
                other.sourceLang == sourceLang) &&
            (identical(other.targetLang, targetLang) ||
                other.targetLang == targetLang));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, sourceLang, targetLang);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationRequestImplCopyWith<_$TranslationRequestImpl> get copyWith =>
      __$$TranslationRequestImplCopyWithImpl<_$TranslationRequestImpl>(
          this, _$identity);
}

abstract class _TranslationRequest implements TranslationRequest {
  const factory _TranslationRequest(
      {required final String text,
      required final String sourceLang,
      required final String targetLang}) = _$TranslationRequestImpl;

  @override
  String get text;
  @override
  String get sourceLang;
  @override
  String get targetLang;
  @override
  @JsonKey(ignore: true)
  _$$TranslationRequestImplCopyWith<_$TranslationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppState {
  String get currentLanguage => throw _privateConstructorUsedError;
  String get sourceLanguage => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  bool get isDarkMode => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppStateCopyWith<AppState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStateCopyWith<$Res> {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) then) =
      _$AppStateCopyWithImpl<$Res, AppState>;
  @useResult
  $Res call(
      {String currentLanguage,
      String sourceLanguage,
      String targetLanguage,
      bool isDarkMode,
      String? userId,
      bool isInitialized,
      bool isOnline});
}

/// @nodoc
class _$AppStateCopyWithImpl<$Res, $Val extends AppState>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLanguage = null,
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? isDarkMode = null,
    Object? userId = freezed,
    Object? isInitialized = null,
    Object? isOnline = null,
  }) {
    return _then(_value.copyWith(
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppStateImplCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$$AppStateImplCopyWith(
          _$AppStateImpl value, $Res Function(_$AppStateImpl) then) =
      __$$AppStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String currentLanguage,
      String sourceLanguage,
      String targetLanguage,
      bool isDarkMode,
      String? userId,
      bool isInitialized,
      bool isOnline});
}

/// @nodoc
class __$$AppStateImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$AppStateImpl>
    implements _$$AppStateImplCopyWith<$Res> {
  __$$AppStateImplCopyWithImpl(
      _$AppStateImpl _value, $Res Function(_$AppStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLanguage = null,
    Object? sourceLanguage = null,
    Object? targetLanguage = null,
    Object? isDarkMode = null,
    Object? userId = freezed,
    Object? isInitialized = null,
    Object? isOnline = null,
  }) {
    return _then(_$AppStateImpl(
      currentLanguage: null == currentLanguage
          ? _value.currentLanguage
          : currentLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      sourceLanguage: null == sourceLanguage
          ? _value.sourceLanguage
          : sourceLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      targetLanguage: null == targetLanguage
          ? _value.targetLanguage
          : targetLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AppStateImpl implements _AppState {
  const _$AppStateImpl(
      {this.currentLanguage = 'zh',
      this.sourceLanguage = 'en',
      this.targetLanguage = 'zh',
      this.isDarkMode = false,
      this.userId = null,
      this.isInitialized = false,
      this.isOnline = true});

  @override
  @JsonKey()
  final String currentLanguage;
  @override
  @JsonKey()
  final String sourceLanguage;
  @override
  @JsonKey()
  final String targetLanguage;
  @override
  @JsonKey()
  final bool isDarkMode;
  @override
  @JsonKey()
  final String? userId;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool isOnline;

  @override
  String toString() {
    return 'AppState(currentLanguage: $currentLanguage, sourceLanguage: $sourceLanguage, targetLanguage: $targetLanguage, isDarkMode: $isDarkMode, userId: $userId, isInitialized: $isInitialized, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppStateImpl &&
            (identical(other.currentLanguage, currentLanguage) ||
                other.currentLanguage == currentLanguage) &&
            (identical(other.sourceLanguage, sourceLanguage) ||
                other.sourceLanguage == sourceLanguage) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.isDarkMode, isDarkMode) ||
                other.isDarkMode == isDarkMode) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline));
  }

  @override
  int get hashCode => Object.hash(runtimeType, currentLanguage, sourceLanguage,
      targetLanguage, isDarkMode, userId, isInitialized, isOnline);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      __$$AppStateImplCopyWithImpl<_$AppStateImpl>(this, _$identity);
}

abstract class _AppState implements AppState {
  const factory _AppState(
      {final String currentLanguage,
      final String sourceLanguage,
      final String targetLanguage,
      final bool isDarkMode,
      final String? userId,
      final bool isInitialized,
      final bool isOnline}) = _$AppStateImpl;

  @override
  String get currentLanguage;
  @override
  String get sourceLanguage;
  @override
  String get targetLanguage;
  @override
  bool get isDarkMode;
  @override
  String? get userId;
  @override
  bool get isInitialized;
  @override
  bool get isOnline;
  @override
  @JsonKey(ignore: true)
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
