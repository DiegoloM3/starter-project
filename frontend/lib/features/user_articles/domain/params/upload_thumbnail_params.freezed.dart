// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_thumbnail_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UploadThumbnailParams {
  String get authorId => throw _privateConstructorUsedError;
  String get articleId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  List<int> get bytes => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UploadThumbnailParamsCopyWith<UploadThumbnailParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadThumbnailParamsCopyWith<$Res> {
  factory $UploadThumbnailParamsCopyWith(UploadThumbnailParams value,
          $Res Function(UploadThumbnailParams) then) =
      _$UploadThumbnailParamsCopyWithImpl<$Res, UploadThumbnailParams>;
  @useResult
  $Res call(
      {String authorId,
      String articleId,
      String fileName,
      List<int> bytes,
      String contentType});
}

/// @nodoc
class _$UploadThumbnailParamsCopyWithImpl<$Res,
        $Val extends UploadThumbnailParams>
    implements $UploadThumbnailParamsCopyWith<$Res> {
  _$UploadThumbnailParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorId = null,
    Object? articleId = null,
    Object? fileName = null,
    Object? bytes = null,
    Object? contentType = null,
  }) {
    return _then(_value.copyWith(
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      articleId: null == articleId
          ? _value.articleId
          : articleId // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      bytes: null == bytes
          ? _value.bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UploadThumbnailParamsImplCopyWith<$Res>
    implements $UploadThumbnailParamsCopyWith<$Res> {
  factory _$$UploadThumbnailParamsImplCopyWith(
          _$UploadThumbnailParamsImpl value,
          $Res Function(_$UploadThumbnailParamsImpl) then) =
      __$$UploadThumbnailParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String authorId,
      String articleId,
      String fileName,
      List<int> bytes,
      String contentType});
}

/// @nodoc
class __$$UploadThumbnailParamsImplCopyWithImpl<$Res>
    extends _$UploadThumbnailParamsCopyWithImpl<$Res,
        _$UploadThumbnailParamsImpl>
    implements _$$UploadThumbnailParamsImplCopyWith<$Res> {
  __$$UploadThumbnailParamsImplCopyWithImpl(_$UploadThumbnailParamsImpl _value,
      $Res Function(_$UploadThumbnailParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? authorId = null,
    Object? articleId = null,
    Object? fileName = null,
    Object? bytes = null,
    Object? contentType = null,
  }) {
    return _then(_$UploadThumbnailParamsImpl(
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      articleId: null == articleId
          ? _value.articleId
          : articleId // ignore: cast_nullable_to_non_nullable
              as String,
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

class _$UploadThumbnailParamsImpl implements _UploadThumbnailParams {
  const _$UploadThumbnailParamsImpl(
      {required this.authorId,
      required this.articleId,
      required this.fileName,
      required final List<int> bytes,
      required this.contentType})
      : _bytes = bytes;

  @override
  final String authorId;
  @override
  final String articleId;
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
    return 'UploadThumbnailParams(authorId: $authorId, articleId: $articleId, fileName: $fileName, bytes: $bytes, contentType: $contentType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadThumbnailParamsImpl &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.articleId, articleId) ||
                other.articleId == articleId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality().equals(other._bytes, _bytes) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, authorId, articleId, fileName,
      const DeepCollectionEquality().hash(_bytes), contentType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadThumbnailParamsImplCopyWith<_$UploadThumbnailParamsImpl>
      get copyWith => __$$UploadThumbnailParamsImplCopyWithImpl<
          _$UploadThumbnailParamsImpl>(this, _$identity);
}

abstract class _UploadThumbnailParams implements UploadThumbnailParams {
  const factory _UploadThumbnailParams(
      {required final String authorId,
      required final String articleId,
      required final String fileName,
      required final List<int> bytes,
      required final String contentType}) = _$UploadThumbnailParamsImpl;

  @override
  String get authorId;
  @override
  String get articleId;
  @override
  String get fileName;
  @override
  List<int> get bytes;
  @override
  String get contentType;
  @override
  @JsonKey(ignore: true)
  _$$UploadThumbnailParamsImplCopyWith<_$UploadThumbnailParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
