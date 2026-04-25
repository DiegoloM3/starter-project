// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ArticleEditorState {
  String? get editingId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get thumbnailURL => throw _privateConstructorUsedError;
  String? get pendingFileName => throw _privateConstructorUsedError;
  List<int>? get pendingBytes => throw _privateConstructorUsedError;
  String? get pendingContentType => throw _privateConstructorUsedError;
  EditorStatus get status => throw _privateConstructorUsedError;
  UserArticleEntity? get saved => throw _privateConstructorUsedError;
  AppFailure? get failure => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ArticleEditorStateCopyWith<ArticleEditorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleEditorStateCopyWith<$Res> {
  factory $ArticleEditorStateCopyWith(
          ArticleEditorState value, $Res Function(ArticleEditorState) then) =
      _$ArticleEditorStateCopyWithImpl<$Res, ArticleEditorState>;
  @useResult
  $Res call(
      {String? editingId,
      String title,
      String description,
      String content,
      List<String> tags,
      String thumbnailURL,
      String? pendingFileName,
      List<int>? pendingBytes,
      String? pendingContentType,
      EditorStatus status,
      UserArticleEntity? saved,
      AppFailure? failure});

  $UserArticleEntityCopyWith<$Res>? get saved;
  $AppFailureCopyWith<$Res>? get failure;
}

/// @nodoc
class _$ArticleEditorStateCopyWithImpl<$Res, $Val extends ArticleEditorState>
    implements $ArticleEditorStateCopyWith<$Res> {
  _$ArticleEditorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? editingId = freezed,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? tags = null,
    Object? thumbnailURL = null,
    Object? pendingFileName = freezed,
    Object? pendingBytes = freezed,
    Object? pendingContentType = freezed,
    Object? status = null,
    Object? saved = freezed,
    Object? failure = freezed,
  }) {
    return _then(_value.copyWith(
      editingId: freezed == editingId
          ? _value.editingId
          : editingId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      thumbnailURL: null == thumbnailURL
          ? _value.thumbnailURL
          : thumbnailURL // ignore: cast_nullable_to_non_nullable
              as String,
      pendingFileName: freezed == pendingFileName
          ? _value.pendingFileName
          : pendingFileName // ignore: cast_nullable_to_non_nullable
              as String?,
      pendingBytes: freezed == pendingBytes
          ? _value.pendingBytes
          : pendingBytes // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      pendingContentType: freezed == pendingContentType
          ? _value.pendingContentType
          : pendingContentType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EditorStatus,
      saved: freezed == saved
          ? _value.saved
          : saved // ignore: cast_nullable_to_non_nullable
              as UserArticleEntity?,
      failure: freezed == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserArticleEntityCopyWith<$Res>? get saved {
    if (_value.saved == null) {
      return null;
    }

    return $UserArticleEntityCopyWith<$Res>(_value.saved!, (value) {
      return _then(_value.copyWith(saved: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res>? get failure {
    if (_value.failure == null) {
      return null;
    }

    return $AppFailureCopyWith<$Res>(_value.failure!, (value) {
      return _then(_value.copyWith(failure: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ArticleEditorStateImplCopyWith<$Res>
    implements $ArticleEditorStateCopyWith<$Res> {
  factory _$$ArticleEditorStateImplCopyWith(_$ArticleEditorStateImpl value,
          $Res Function(_$ArticleEditorStateImpl) then) =
      __$$ArticleEditorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? editingId,
      String title,
      String description,
      String content,
      List<String> tags,
      String thumbnailURL,
      String? pendingFileName,
      List<int>? pendingBytes,
      String? pendingContentType,
      EditorStatus status,
      UserArticleEntity? saved,
      AppFailure? failure});

  @override
  $UserArticleEntityCopyWith<$Res>? get saved;
  @override
  $AppFailureCopyWith<$Res>? get failure;
}

/// @nodoc
class __$$ArticleEditorStateImplCopyWithImpl<$Res>
    extends _$ArticleEditorStateCopyWithImpl<$Res, _$ArticleEditorStateImpl>
    implements _$$ArticleEditorStateImplCopyWith<$Res> {
  __$$ArticleEditorStateImplCopyWithImpl(_$ArticleEditorStateImpl _value,
      $Res Function(_$ArticleEditorStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? editingId = freezed,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? tags = null,
    Object? thumbnailURL = null,
    Object? pendingFileName = freezed,
    Object? pendingBytes = freezed,
    Object? pendingContentType = freezed,
    Object? status = null,
    Object? saved = freezed,
    Object? failure = freezed,
  }) {
    return _then(_$ArticleEditorStateImpl(
      editingId: freezed == editingId
          ? _value.editingId
          : editingId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      thumbnailURL: null == thumbnailURL
          ? _value.thumbnailURL
          : thumbnailURL // ignore: cast_nullable_to_non_nullable
              as String,
      pendingFileName: freezed == pendingFileName
          ? _value.pendingFileName
          : pendingFileName // ignore: cast_nullable_to_non_nullable
              as String?,
      pendingBytes: freezed == pendingBytes
          ? _value._pendingBytes
          : pendingBytes // ignore: cast_nullable_to_non_nullable
              as List<int>?,
      pendingContentType: freezed == pendingContentType
          ? _value.pendingContentType
          : pendingContentType // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EditorStatus,
      saved: freezed == saved
          ? _value.saved
          : saved // ignore: cast_nullable_to_non_nullable
              as UserArticleEntity?,
      failure: freezed == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as AppFailure?,
    ));
  }
}

/// @nodoc

class _$ArticleEditorStateImpl extends _ArticleEditorState {
  const _$ArticleEditorStateImpl(
      {required this.editingId,
      required this.title,
      required this.description,
      required this.content,
      required final List<String> tags,
      required this.thumbnailURL,
      this.pendingFileName,
      final List<int>? pendingBytes,
      this.pendingContentType,
      this.status = EditorStatus.idle,
      this.saved,
      this.failure})
      : _tags = tags,
        _pendingBytes = pendingBytes,
        super._();

  @override
  final String? editingId;
  @override
  final String title;
  @override
  final String description;
  @override
  final String content;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String thumbnailURL;
  @override
  final String? pendingFileName;
  final List<int>? _pendingBytes;
  @override
  List<int>? get pendingBytes {
    final value = _pendingBytes;
    if (value == null) return null;
    if (_pendingBytes is EqualUnmodifiableListView) return _pendingBytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? pendingContentType;
  @override
  @JsonKey()
  final EditorStatus status;
  @override
  final UserArticleEntity? saved;
  @override
  final AppFailure? failure;

  @override
  String toString() {
    return 'ArticleEditorState(editingId: $editingId, title: $title, description: $description, content: $content, tags: $tags, thumbnailURL: $thumbnailURL, pendingFileName: $pendingFileName, pendingBytes: $pendingBytes, pendingContentType: $pendingContentType, status: $status, saved: $saved, failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEditorStateImpl &&
            (identical(other.editingId, editingId) ||
                other.editingId == editingId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.thumbnailURL, thumbnailURL) ||
                other.thumbnailURL == thumbnailURL) &&
            (identical(other.pendingFileName, pendingFileName) ||
                other.pendingFileName == pendingFileName) &&
            const DeepCollectionEquality()
                .equals(other._pendingBytes, _pendingBytes) &&
            (identical(other.pendingContentType, pendingContentType) ||
                other.pendingContentType == pendingContentType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.saved, saved) || other.saved == saved) &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      editingId,
      title,
      description,
      content,
      const DeepCollectionEquality().hash(_tags),
      thumbnailURL,
      pendingFileName,
      const DeepCollectionEquality().hash(_pendingBytes),
      pendingContentType,
      status,
      saved,
      failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleEditorStateImplCopyWith<_$ArticleEditorStateImpl> get copyWith =>
      __$$ArticleEditorStateImplCopyWithImpl<_$ArticleEditorStateImpl>(
          this, _$identity);
}

abstract class _ArticleEditorState extends ArticleEditorState {
  const factory _ArticleEditorState(
      {required final String? editingId,
      required final String title,
      required final String description,
      required final String content,
      required final List<String> tags,
      required final String thumbnailURL,
      final String? pendingFileName,
      final List<int>? pendingBytes,
      final String? pendingContentType,
      final EditorStatus status,
      final UserArticleEntity? saved,
      final AppFailure? failure}) = _$ArticleEditorStateImpl;
  const _ArticleEditorState._() : super._();

  @override
  String? get editingId;
  @override
  String get title;
  @override
  String get description;
  @override
  String get content;
  @override
  List<String> get tags;
  @override
  String get thumbnailURL;
  @override
  String? get pendingFileName;
  @override
  List<int>? get pendingBytes;
  @override
  String? get pendingContentType;
  @override
  EditorStatus get status;
  @override
  UserArticleEntity? get saved;
  @override
  AppFailure? get failure;
  @override
  @JsonKey(ignore: true)
  _$$ArticleEditorStateImplCopyWith<_$ArticleEditorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
