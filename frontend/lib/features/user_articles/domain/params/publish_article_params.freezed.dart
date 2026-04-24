// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publish_article_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PublishArticleParams {
  String get id => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get thumbnailURL => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PublishArticleParamsCopyWith<PublishArticleParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublishArticleParamsCopyWith<$Res> {
  factory $PublishArticleParamsCopyWith(PublishArticleParams value,
          $Res Function(PublishArticleParams) then) =
      _$PublishArticleParamsCopyWithImpl<$Res, PublishArticleParams>;
  @useResult
  $Res call(
      {String id,
      String authorId,
      String authorName,
      String title,
      String description,
      String content,
      String thumbnailURL,
      List<String> tags});
}

/// @nodoc
class _$PublishArticleParamsCopyWithImpl<$Res,
        $Val extends PublishArticleParams>
    implements $PublishArticleParamsCopyWith<$Res> {
  _$PublishArticleParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? thumbnailURL = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
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
      thumbnailURL: null == thumbnailURL
          ? _value.thumbnailURL
          : thumbnailURL // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublishArticleParamsImplCopyWith<$Res>
    implements $PublishArticleParamsCopyWith<$Res> {
  factory _$$PublishArticleParamsImplCopyWith(_$PublishArticleParamsImpl value,
          $Res Function(_$PublishArticleParamsImpl) then) =
      __$$PublishArticleParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String authorId,
      String authorName,
      String title,
      String description,
      String content,
      String thumbnailURL,
      List<String> tags});
}

/// @nodoc
class __$$PublishArticleParamsImplCopyWithImpl<$Res>
    extends _$PublishArticleParamsCopyWithImpl<$Res, _$PublishArticleParamsImpl>
    implements _$$PublishArticleParamsImplCopyWith<$Res> {
  __$$PublishArticleParamsImplCopyWithImpl(_$PublishArticleParamsImpl _value,
      $Res Function(_$PublishArticleParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? title = null,
    Object? description = null,
    Object? content = null,
    Object? thumbnailURL = null,
    Object? tags = null,
  }) {
    return _then(_$PublishArticleParamsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
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
      thumbnailURL: null == thumbnailURL
          ? _value.thumbnailURL
          : thumbnailURL // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$PublishArticleParamsImpl implements _PublishArticleParams {
  const _$PublishArticleParamsImpl(
      {required this.id,
      required this.authorId,
      required this.authorName,
      required this.title,
      required this.description,
      required this.content,
      required this.thumbnailURL,
      final List<String> tags = const <String>[]})
      : _tags = tags;

  @override
  final String id;
  @override
  final String authorId;
  @override
  final String authorName;
  @override
  final String title;
  @override
  final String description;
  @override
  final String content;
  @override
  final String thumbnailURL;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'PublishArticleParams(id: $id, authorId: $authorId, authorName: $authorName, title: $title, description: $description, content: $content, thumbnailURL: $thumbnailURL, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublishArticleParamsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.thumbnailURL, thumbnailURL) ||
                other.thumbnailURL == thumbnailURL) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      authorId,
      authorName,
      title,
      description,
      content,
      thumbnailURL,
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PublishArticleParamsImplCopyWith<_$PublishArticleParamsImpl>
      get copyWith =>
          __$$PublishArticleParamsImplCopyWithImpl<_$PublishArticleParamsImpl>(
              this, _$identity);
}

abstract class _PublishArticleParams implements PublishArticleParams {
  const factory _PublishArticleParams(
      {required final String id,
      required final String authorId,
      required final String authorName,
      required final String title,
      required final String description,
      required final String content,
      required final String thumbnailURL,
      final List<String> tags}) = _$PublishArticleParamsImpl;

  @override
  String get id;
  @override
  String get authorId;
  @override
  String get authorName;
  @override
  String get title;
  @override
  String get description;
  @override
  String get content;
  @override
  String get thumbnailURL;
  @override
  List<String> get tags;
  @override
  @JsonKey(ignore: true)
  _$$PublishArticleParamsImplCopyWith<_$PublishArticleParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
