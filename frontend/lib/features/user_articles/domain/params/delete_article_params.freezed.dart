// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_article_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeleteArticleParams {
  String get id => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeleteArticleParamsCopyWith<DeleteArticleParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeleteArticleParamsCopyWith<$Res> {
  factory $DeleteArticleParamsCopyWith(
          DeleteArticleParams value, $Res Function(DeleteArticleParams) then) =
      _$DeleteArticleParamsCopyWithImpl<$Res, DeleteArticleParams>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$DeleteArticleParamsCopyWithImpl<$Res, $Val extends DeleteArticleParams>
    implements $DeleteArticleParamsCopyWith<$Res> {
  _$DeleteArticleParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeleteArticleParamsImplCopyWith<$Res>
    implements $DeleteArticleParamsCopyWith<$Res> {
  factory _$$DeleteArticleParamsImplCopyWith(_$DeleteArticleParamsImpl value,
          $Res Function(_$DeleteArticleParamsImpl) then) =
      __$$DeleteArticleParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$DeleteArticleParamsImplCopyWithImpl<$Res>
    extends _$DeleteArticleParamsCopyWithImpl<$Res, _$DeleteArticleParamsImpl>
    implements _$$DeleteArticleParamsImplCopyWith<$Res> {
  __$$DeleteArticleParamsImplCopyWithImpl(_$DeleteArticleParamsImpl _value,
      $Res Function(_$DeleteArticleParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$DeleteArticleParamsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DeleteArticleParamsImpl implements _DeleteArticleParams {
  const _$DeleteArticleParamsImpl({required this.id});

  @override
  final String id;

  @override
  String toString() {
    return 'DeleteArticleParams(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteArticleParamsImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteArticleParamsImplCopyWith<_$DeleteArticleParamsImpl> get copyWith =>
      __$$DeleteArticleParamsImplCopyWithImpl<_$DeleteArticleParamsImpl>(
          this, _$identity);
}

abstract class _DeleteArticleParams implements DeleteArticleParams {
  const factory _DeleteArticleParams({required final String id}) =
      _$DeleteArticleParamsImpl;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$DeleteArticleParamsImplCopyWith<_$DeleteArticleParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
