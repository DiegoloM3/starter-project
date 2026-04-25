// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_editor_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ArticleEditorEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String value) titleChanged,
    required TResult Function(String value) descriptionChanged,
    required TResult Function(String value) contentChanged,
    required TResult Function(List<String> tags) tagsChanged,
    required TResult Function(
            String fileName, List<int> bytes, String contentType)
        thumbnailPicked,
    required TResult Function() submitted,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String value)? titleChanged,
    TResult? Function(String value)? descriptionChanged,
    TResult? Function(String value)? contentChanged,
    TResult? Function(List<String> tags)? tagsChanged,
    TResult? Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult? Function()? submitted,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String value)? titleChanged,
    TResult Function(String value)? descriptionChanged,
    TResult Function(String value)? contentChanged,
    TResult Function(List<String> tags)? tagsChanged,
    TResult Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult Function()? submitted,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ArticleEditorTitleChanged value) titleChanged,
    required TResult Function(ArticleEditorDescriptionChanged value)
        descriptionChanged,
    required TResult Function(ArticleEditorContentChanged value) contentChanged,
    required TResult Function(ArticleEditorTagsChanged value) tagsChanged,
    required TResult Function(ArticleEditorThumbnailPicked value)
        thumbnailPicked,
    required TResult Function(ArticleEditorSubmitted value) submitted,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult? Function(ArticleEditorDescriptionChanged value)?
        descriptionChanged,
    TResult? Function(ArticleEditorContentChanged value)? contentChanged,
    TResult? Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult? Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult? Function(ArticleEditorSubmitted value)? submitted,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult Function(ArticleEditorDescriptionChanged value)? descriptionChanged,
    TResult Function(ArticleEditorContentChanged value)? contentChanged,
    TResult Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult Function(ArticleEditorSubmitted value)? submitted,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleEditorEventCopyWith<$Res> {
  factory $ArticleEditorEventCopyWith(
          ArticleEditorEvent value, $Res Function(ArticleEditorEvent) then) =
      _$ArticleEditorEventCopyWithImpl<$Res, ArticleEditorEvent>;
}

/// @nodoc
class _$ArticleEditorEventCopyWithImpl<$Res, $Val extends ArticleEditorEvent>
    implements $ArticleEditorEventCopyWith<$Res> {
  _$ArticleEditorEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ArticleEditorTitleChangedImplCopyWith<$Res> {
  factory _$$ArticleEditorTitleChangedImplCopyWith(
          _$ArticleEditorTitleChangedImpl value,
          $Res Function(_$ArticleEditorTitleChangedImpl) then) =
      __$$ArticleEditorTitleChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$ArticleEditorTitleChangedImplCopyWithImpl<$Res>
    extends _$ArticleEditorEventCopyWithImpl<$Res,
        _$ArticleEditorTitleChangedImpl>
    implements _$$ArticleEditorTitleChangedImplCopyWith<$Res> {
  __$$ArticleEditorTitleChangedImplCopyWithImpl(
      _$ArticleEditorTitleChangedImpl _value,
      $Res Function(_$ArticleEditorTitleChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$ArticleEditorTitleChangedImpl(
      null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ArticleEditorTitleChangedImpl implements ArticleEditorTitleChanged {
  const _$ArticleEditorTitleChangedImpl(this.value);

  @override
  final String value;

  @override
  String toString() {
    return 'ArticleEditorEvent.titleChanged(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEditorTitleChangedImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleEditorTitleChangedImplCopyWith<_$ArticleEditorTitleChangedImpl>
      get copyWith => __$$ArticleEditorTitleChangedImplCopyWithImpl<
          _$ArticleEditorTitleChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String value) titleChanged,
    required TResult Function(String value) descriptionChanged,
    required TResult Function(String value) contentChanged,
    required TResult Function(List<String> tags) tagsChanged,
    required TResult Function(
            String fileName, List<int> bytes, String contentType)
        thumbnailPicked,
    required TResult Function() submitted,
  }) {
    return titleChanged(value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String value)? titleChanged,
    TResult? Function(String value)? descriptionChanged,
    TResult? Function(String value)? contentChanged,
    TResult? Function(List<String> tags)? tagsChanged,
    TResult? Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult? Function()? submitted,
  }) {
    return titleChanged?.call(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String value)? titleChanged,
    TResult Function(String value)? descriptionChanged,
    TResult Function(String value)? contentChanged,
    TResult Function(List<String> tags)? tagsChanged,
    TResult Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult Function()? submitted,
    required TResult orElse(),
  }) {
    if (titleChanged != null) {
      return titleChanged(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ArticleEditorTitleChanged value) titleChanged,
    required TResult Function(ArticleEditorDescriptionChanged value)
        descriptionChanged,
    required TResult Function(ArticleEditorContentChanged value) contentChanged,
    required TResult Function(ArticleEditorTagsChanged value) tagsChanged,
    required TResult Function(ArticleEditorThumbnailPicked value)
        thumbnailPicked,
    required TResult Function(ArticleEditorSubmitted value) submitted,
  }) {
    return titleChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult? Function(ArticleEditorDescriptionChanged value)?
        descriptionChanged,
    TResult? Function(ArticleEditorContentChanged value)? contentChanged,
    TResult? Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult? Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult? Function(ArticleEditorSubmitted value)? submitted,
  }) {
    return titleChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult Function(ArticleEditorDescriptionChanged value)? descriptionChanged,
    TResult Function(ArticleEditorContentChanged value)? contentChanged,
    TResult Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult Function(ArticleEditorSubmitted value)? submitted,
    required TResult orElse(),
  }) {
    if (titleChanged != null) {
      return titleChanged(this);
    }
    return orElse();
  }
}

abstract class ArticleEditorTitleChanged implements ArticleEditorEvent {
  const factory ArticleEditorTitleChanged(final String value) =
      _$ArticleEditorTitleChangedImpl;

  String get value;
  @JsonKey(ignore: true)
  _$$ArticleEditorTitleChangedImplCopyWith<_$ArticleEditorTitleChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ArticleEditorDescriptionChangedImplCopyWith<$Res> {
  factory _$$ArticleEditorDescriptionChangedImplCopyWith(
          _$ArticleEditorDescriptionChangedImpl value,
          $Res Function(_$ArticleEditorDescriptionChangedImpl) then) =
      __$$ArticleEditorDescriptionChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$ArticleEditorDescriptionChangedImplCopyWithImpl<$Res>
    extends _$ArticleEditorEventCopyWithImpl<$Res,
        _$ArticleEditorDescriptionChangedImpl>
    implements _$$ArticleEditorDescriptionChangedImplCopyWith<$Res> {
  __$$ArticleEditorDescriptionChangedImplCopyWithImpl(
      _$ArticleEditorDescriptionChangedImpl _value,
      $Res Function(_$ArticleEditorDescriptionChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$ArticleEditorDescriptionChangedImpl(
      null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ArticleEditorDescriptionChangedImpl
    implements ArticleEditorDescriptionChanged {
  const _$ArticleEditorDescriptionChangedImpl(this.value);

  @override
  final String value;

  @override
  String toString() {
    return 'ArticleEditorEvent.descriptionChanged(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEditorDescriptionChangedImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleEditorDescriptionChangedImplCopyWith<
          _$ArticleEditorDescriptionChangedImpl>
      get copyWith => __$$ArticleEditorDescriptionChangedImplCopyWithImpl<
          _$ArticleEditorDescriptionChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String value) titleChanged,
    required TResult Function(String value) descriptionChanged,
    required TResult Function(String value) contentChanged,
    required TResult Function(List<String> tags) tagsChanged,
    required TResult Function(
            String fileName, List<int> bytes, String contentType)
        thumbnailPicked,
    required TResult Function() submitted,
  }) {
    return descriptionChanged(value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String value)? titleChanged,
    TResult? Function(String value)? descriptionChanged,
    TResult? Function(String value)? contentChanged,
    TResult? Function(List<String> tags)? tagsChanged,
    TResult? Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult? Function()? submitted,
  }) {
    return descriptionChanged?.call(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String value)? titleChanged,
    TResult Function(String value)? descriptionChanged,
    TResult Function(String value)? contentChanged,
    TResult Function(List<String> tags)? tagsChanged,
    TResult Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult Function()? submitted,
    required TResult orElse(),
  }) {
    if (descriptionChanged != null) {
      return descriptionChanged(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ArticleEditorTitleChanged value) titleChanged,
    required TResult Function(ArticleEditorDescriptionChanged value)
        descriptionChanged,
    required TResult Function(ArticleEditorContentChanged value) contentChanged,
    required TResult Function(ArticleEditorTagsChanged value) tagsChanged,
    required TResult Function(ArticleEditorThumbnailPicked value)
        thumbnailPicked,
    required TResult Function(ArticleEditorSubmitted value) submitted,
  }) {
    return descriptionChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult? Function(ArticleEditorDescriptionChanged value)?
        descriptionChanged,
    TResult? Function(ArticleEditorContentChanged value)? contentChanged,
    TResult? Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult? Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult? Function(ArticleEditorSubmitted value)? submitted,
  }) {
    return descriptionChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult Function(ArticleEditorDescriptionChanged value)? descriptionChanged,
    TResult Function(ArticleEditorContentChanged value)? contentChanged,
    TResult Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult Function(ArticleEditorSubmitted value)? submitted,
    required TResult orElse(),
  }) {
    if (descriptionChanged != null) {
      return descriptionChanged(this);
    }
    return orElse();
  }
}

abstract class ArticleEditorDescriptionChanged implements ArticleEditorEvent {
  const factory ArticleEditorDescriptionChanged(final String value) =
      _$ArticleEditorDescriptionChangedImpl;

  String get value;
  @JsonKey(ignore: true)
  _$$ArticleEditorDescriptionChangedImplCopyWith<
          _$ArticleEditorDescriptionChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ArticleEditorContentChangedImplCopyWith<$Res> {
  factory _$$ArticleEditorContentChangedImplCopyWith(
          _$ArticleEditorContentChangedImpl value,
          $Res Function(_$ArticleEditorContentChangedImpl) then) =
      __$$ArticleEditorContentChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String value});
}

/// @nodoc
class __$$ArticleEditorContentChangedImplCopyWithImpl<$Res>
    extends _$ArticleEditorEventCopyWithImpl<$Res,
        _$ArticleEditorContentChangedImpl>
    implements _$$ArticleEditorContentChangedImplCopyWith<$Res> {
  __$$ArticleEditorContentChangedImplCopyWithImpl(
      _$ArticleEditorContentChangedImpl _value,
      $Res Function(_$ArticleEditorContentChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$ArticleEditorContentChangedImpl(
      null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ArticleEditorContentChangedImpl implements ArticleEditorContentChanged {
  const _$ArticleEditorContentChangedImpl(this.value);

  @override
  final String value;

  @override
  String toString() {
    return 'ArticleEditorEvent.contentChanged(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEditorContentChangedImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleEditorContentChangedImplCopyWith<_$ArticleEditorContentChangedImpl>
      get copyWith => __$$ArticleEditorContentChangedImplCopyWithImpl<
          _$ArticleEditorContentChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String value) titleChanged,
    required TResult Function(String value) descriptionChanged,
    required TResult Function(String value) contentChanged,
    required TResult Function(List<String> tags) tagsChanged,
    required TResult Function(
            String fileName, List<int> bytes, String contentType)
        thumbnailPicked,
    required TResult Function() submitted,
  }) {
    return contentChanged(value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String value)? titleChanged,
    TResult? Function(String value)? descriptionChanged,
    TResult? Function(String value)? contentChanged,
    TResult? Function(List<String> tags)? tagsChanged,
    TResult? Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult? Function()? submitted,
  }) {
    return contentChanged?.call(value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String value)? titleChanged,
    TResult Function(String value)? descriptionChanged,
    TResult Function(String value)? contentChanged,
    TResult Function(List<String> tags)? tagsChanged,
    TResult Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult Function()? submitted,
    required TResult orElse(),
  }) {
    if (contentChanged != null) {
      return contentChanged(value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ArticleEditorTitleChanged value) titleChanged,
    required TResult Function(ArticleEditorDescriptionChanged value)
        descriptionChanged,
    required TResult Function(ArticleEditorContentChanged value) contentChanged,
    required TResult Function(ArticleEditorTagsChanged value) tagsChanged,
    required TResult Function(ArticleEditorThumbnailPicked value)
        thumbnailPicked,
    required TResult Function(ArticleEditorSubmitted value) submitted,
  }) {
    return contentChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult? Function(ArticleEditorDescriptionChanged value)?
        descriptionChanged,
    TResult? Function(ArticleEditorContentChanged value)? contentChanged,
    TResult? Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult? Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult? Function(ArticleEditorSubmitted value)? submitted,
  }) {
    return contentChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult Function(ArticleEditorDescriptionChanged value)? descriptionChanged,
    TResult Function(ArticleEditorContentChanged value)? contentChanged,
    TResult Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult Function(ArticleEditorSubmitted value)? submitted,
    required TResult orElse(),
  }) {
    if (contentChanged != null) {
      return contentChanged(this);
    }
    return orElse();
  }
}

abstract class ArticleEditorContentChanged implements ArticleEditorEvent {
  const factory ArticleEditorContentChanged(final String value) =
      _$ArticleEditorContentChangedImpl;

  String get value;
  @JsonKey(ignore: true)
  _$$ArticleEditorContentChangedImplCopyWith<_$ArticleEditorContentChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ArticleEditorTagsChangedImplCopyWith<$Res> {
  factory _$$ArticleEditorTagsChangedImplCopyWith(
          _$ArticleEditorTagsChangedImpl value,
          $Res Function(_$ArticleEditorTagsChangedImpl) then) =
      __$$ArticleEditorTagsChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<String> tags});
}

/// @nodoc
class __$$ArticleEditorTagsChangedImplCopyWithImpl<$Res>
    extends _$ArticleEditorEventCopyWithImpl<$Res,
        _$ArticleEditorTagsChangedImpl>
    implements _$$ArticleEditorTagsChangedImplCopyWith<$Res> {
  __$$ArticleEditorTagsChangedImplCopyWithImpl(
      _$ArticleEditorTagsChangedImpl _value,
      $Res Function(_$ArticleEditorTagsChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tags = null,
  }) {
    return _then(_$ArticleEditorTagsChangedImpl(
      null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$ArticleEditorTagsChangedImpl implements ArticleEditorTagsChanged {
  const _$ArticleEditorTagsChangedImpl(final List<String> tags) : _tags = tags;

  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'ArticleEditorEvent.tagsChanged(tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEditorTagsChangedImpl &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleEditorTagsChangedImplCopyWith<_$ArticleEditorTagsChangedImpl>
      get copyWith => __$$ArticleEditorTagsChangedImplCopyWithImpl<
          _$ArticleEditorTagsChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String value) titleChanged,
    required TResult Function(String value) descriptionChanged,
    required TResult Function(String value) contentChanged,
    required TResult Function(List<String> tags) tagsChanged,
    required TResult Function(
            String fileName, List<int> bytes, String contentType)
        thumbnailPicked,
    required TResult Function() submitted,
  }) {
    return tagsChanged(tags);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String value)? titleChanged,
    TResult? Function(String value)? descriptionChanged,
    TResult? Function(String value)? contentChanged,
    TResult? Function(List<String> tags)? tagsChanged,
    TResult? Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult? Function()? submitted,
  }) {
    return tagsChanged?.call(tags);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String value)? titleChanged,
    TResult Function(String value)? descriptionChanged,
    TResult Function(String value)? contentChanged,
    TResult Function(List<String> tags)? tagsChanged,
    TResult Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult Function()? submitted,
    required TResult orElse(),
  }) {
    if (tagsChanged != null) {
      return tagsChanged(tags);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ArticleEditorTitleChanged value) titleChanged,
    required TResult Function(ArticleEditorDescriptionChanged value)
        descriptionChanged,
    required TResult Function(ArticleEditorContentChanged value) contentChanged,
    required TResult Function(ArticleEditorTagsChanged value) tagsChanged,
    required TResult Function(ArticleEditorThumbnailPicked value)
        thumbnailPicked,
    required TResult Function(ArticleEditorSubmitted value) submitted,
  }) {
    return tagsChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult? Function(ArticleEditorDescriptionChanged value)?
        descriptionChanged,
    TResult? Function(ArticleEditorContentChanged value)? contentChanged,
    TResult? Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult? Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult? Function(ArticleEditorSubmitted value)? submitted,
  }) {
    return tagsChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult Function(ArticleEditorDescriptionChanged value)? descriptionChanged,
    TResult Function(ArticleEditorContentChanged value)? contentChanged,
    TResult Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult Function(ArticleEditorSubmitted value)? submitted,
    required TResult orElse(),
  }) {
    if (tagsChanged != null) {
      return tagsChanged(this);
    }
    return orElse();
  }
}

abstract class ArticleEditorTagsChanged implements ArticleEditorEvent {
  const factory ArticleEditorTagsChanged(final List<String> tags) =
      _$ArticleEditorTagsChangedImpl;

  List<String> get tags;
  @JsonKey(ignore: true)
  _$$ArticleEditorTagsChangedImplCopyWith<_$ArticleEditorTagsChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ArticleEditorThumbnailPickedImplCopyWith<$Res> {
  factory _$$ArticleEditorThumbnailPickedImplCopyWith(
          _$ArticleEditorThumbnailPickedImpl value,
          $Res Function(_$ArticleEditorThumbnailPickedImpl) then) =
      __$$ArticleEditorThumbnailPickedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String fileName, List<int> bytes, String contentType});
}

/// @nodoc
class __$$ArticleEditorThumbnailPickedImplCopyWithImpl<$Res>
    extends _$ArticleEditorEventCopyWithImpl<$Res,
        _$ArticleEditorThumbnailPickedImpl>
    implements _$$ArticleEditorThumbnailPickedImplCopyWith<$Res> {
  __$$ArticleEditorThumbnailPickedImplCopyWithImpl(
      _$ArticleEditorThumbnailPickedImpl _value,
      $Res Function(_$ArticleEditorThumbnailPickedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileName = null,
    Object? bytes = null,
    Object? contentType = null,
  }) {
    return _then(_$ArticleEditorThumbnailPickedImpl(
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      bytes: null == bytes
          ? _value._bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ArticleEditorThumbnailPickedImpl
    implements ArticleEditorThumbnailPicked {
  const _$ArticleEditorThumbnailPickedImpl(
      {required this.fileName,
      required final List<int> bytes,
      required this.contentType})
      : _bytes = bytes;

  @override
  final String fileName;
  final List<int> _bytes;
  @override
  List<int> get bytes {
    if (_bytes is EqualUnmodifiableListView) return _bytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bytes);
  }

  @override
  final String contentType;

  @override
  String toString() {
    return 'ArticleEditorEvent.thumbnailPicked(fileName: $fileName, bytes: $bytes, contentType: $contentType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEditorThumbnailPickedImpl &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality().equals(other._bytes, _bytes) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fileName,
      const DeepCollectionEquality().hash(_bytes), contentType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleEditorThumbnailPickedImplCopyWith<
          _$ArticleEditorThumbnailPickedImpl>
      get copyWith => __$$ArticleEditorThumbnailPickedImplCopyWithImpl<
          _$ArticleEditorThumbnailPickedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String value) titleChanged,
    required TResult Function(String value) descriptionChanged,
    required TResult Function(String value) contentChanged,
    required TResult Function(List<String> tags) tagsChanged,
    required TResult Function(
            String fileName, List<int> bytes, String contentType)
        thumbnailPicked,
    required TResult Function() submitted,
  }) {
    return thumbnailPicked(fileName, bytes, contentType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String value)? titleChanged,
    TResult? Function(String value)? descriptionChanged,
    TResult? Function(String value)? contentChanged,
    TResult? Function(List<String> tags)? tagsChanged,
    TResult? Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult? Function()? submitted,
  }) {
    return thumbnailPicked?.call(fileName, bytes, contentType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String value)? titleChanged,
    TResult Function(String value)? descriptionChanged,
    TResult Function(String value)? contentChanged,
    TResult Function(List<String> tags)? tagsChanged,
    TResult Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult Function()? submitted,
    required TResult orElse(),
  }) {
    if (thumbnailPicked != null) {
      return thumbnailPicked(fileName, bytes, contentType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ArticleEditorTitleChanged value) titleChanged,
    required TResult Function(ArticleEditorDescriptionChanged value)
        descriptionChanged,
    required TResult Function(ArticleEditorContentChanged value) contentChanged,
    required TResult Function(ArticleEditorTagsChanged value) tagsChanged,
    required TResult Function(ArticleEditorThumbnailPicked value)
        thumbnailPicked,
    required TResult Function(ArticleEditorSubmitted value) submitted,
  }) {
    return thumbnailPicked(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult? Function(ArticleEditorDescriptionChanged value)?
        descriptionChanged,
    TResult? Function(ArticleEditorContentChanged value)? contentChanged,
    TResult? Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult? Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult? Function(ArticleEditorSubmitted value)? submitted,
  }) {
    return thumbnailPicked?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult Function(ArticleEditorDescriptionChanged value)? descriptionChanged,
    TResult Function(ArticleEditorContentChanged value)? contentChanged,
    TResult Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult Function(ArticleEditorSubmitted value)? submitted,
    required TResult orElse(),
  }) {
    if (thumbnailPicked != null) {
      return thumbnailPicked(this);
    }
    return orElse();
  }
}

abstract class ArticleEditorThumbnailPicked implements ArticleEditorEvent {
  const factory ArticleEditorThumbnailPicked(
      {required final String fileName,
      required final List<int> bytes,
      required final String contentType}) = _$ArticleEditorThumbnailPickedImpl;

  String get fileName;
  List<int> get bytes;
  String get contentType;
  @JsonKey(ignore: true)
  _$$ArticleEditorThumbnailPickedImplCopyWith<
          _$ArticleEditorThumbnailPickedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ArticleEditorSubmittedImplCopyWith<$Res> {
  factory _$$ArticleEditorSubmittedImplCopyWith(
          _$ArticleEditorSubmittedImpl value,
          $Res Function(_$ArticleEditorSubmittedImpl) then) =
      __$$ArticleEditorSubmittedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ArticleEditorSubmittedImplCopyWithImpl<$Res>
    extends _$ArticleEditorEventCopyWithImpl<$Res, _$ArticleEditorSubmittedImpl>
    implements _$$ArticleEditorSubmittedImplCopyWith<$Res> {
  __$$ArticleEditorSubmittedImplCopyWithImpl(
      _$ArticleEditorSubmittedImpl _value,
      $Res Function(_$ArticleEditorSubmittedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ArticleEditorSubmittedImpl implements ArticleEditorSubmitted {
  const _$ArticleEditorSubmittedImpl();

  @override
  String toString() {
    return 'ArticleEditorEvent.submitted()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEditorSubmittedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String value) titleChanged,
    required TResult Function(String value) descriptionChanged,
    required TResult Function(String value) contentChanged,
    required TResult Function(List<String> tags) tagsChanged,
    required TResult Function(
            String fileName, List<int> bytes, String contentType)
        thumbnailPicked,
    required TResult Function() submitted,
  }) {
    return submitted();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String value)? titleChanged,
    TResult? Function(String value)? descriptionChanged,
    TResult? Function(String value)? contentChanged,
    TResult? Function(List<String> tags)? tagsChanged,
    TResult? Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult? Function()? submitted,
  }) {
    return submitted?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String value)? titleChanged,
    TResult Function(String value)? descriptionChanged,
    TResult Function(String value)? contentChanged,
    TResult Function(List<String> tags)? tagsChanged,
    TResult Function(String fileName, List<int> bytes, String contentType)?
        thumbnailPicked,
    TResult Function()? submitted,
    required TResult orElse(),
  }) {
    if (submitted != null) {
      return submitted();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ArticleEditorTitleChanged value) titleChanged,
    required TResult Function(ArticleEditorDescriptionChanged value)
        descriptionChanged,
    required TResult Function(ArticleEditorContentChanged value) contentChanged,
    required TResult Function(ArticleEditorTagsChanged value) tagsChanged,
    required TResult Function(ArticleEditorThumbnailPicked value)
        thumbnailPicked,
    required TResult Function(ArticleEditorSubmitted value) submitted,
  }) {
    return submitted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult? Function(ArticleEditorDescriptionChanged value)?
        descriptionChanged,
    TResult? Function(ArticleEditorContentChanged value)? contentChanged,
    TResult? Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult? Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult? Function(ArticleEditorSubmitted value)? submitted,
  }) {
    return submitted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ArticleEditorTitleChanged value)? titleChanged,
    TResult Function(ArticleEditorDescriptionChanged value)? descriptionChanged,
    TResult Function(ArticleEditorContentChanged value)? contentChanged,
    TResult Function(ArticleEditorTagsChanged value)? tagsChanged,
    TResult Function(ArticleEditorThumbnailPicked value)? thumbnailPicked,
    TResult Function(ArticleEditorSubmitted value)? submitted,
    required TResult orElse(),
  }) {
    if (submitted != null) {
      return submitted(this);
    }
    return orElse();
  }
}

abstract class ArticleEditorSubmitted implements ArticleEditorEvent {
  const factory ArticleEditorSubmitted() = _$ArticleEditorSubmittedImpl;
}
