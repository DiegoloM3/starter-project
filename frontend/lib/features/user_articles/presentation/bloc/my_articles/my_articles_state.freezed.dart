// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_articles_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MyArticlesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserArticleEntity> articles) success,
    required TResult Function(AppFailure failure) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserArticleEntity> articles)? success,
    TResult? Function(AppFailure failure)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserArticleEntity> articles)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MyArticlesInitial value) initial,
    required TResult Function(MyArticlesLoading value) loading,
    required TResult Function(MyArticlesSuccess value) success,
    required TResult Function(MyArticlesFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MyArticlesInitial value)? initial,
    TResult? Function(MyArticlesLoading value)? loading,
    TResult? Function(MyArticlesSuccess value)? success,
    TResult? Function(MyArticlesFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MyArticlesInitial value)? initial,
    TResult Function(MyArticlesLoading value)? loading,
    TResult Function(MyArticlesSuccess value)? success,
    TResult Function(MyArticlesFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyArticlesStateCopyWith<$Res> {
  factory $MyArticlesStateCopyWith(
          MyArticlesState value, $Res Function(MyArticlesState) then) =
      _$MyArticlesStateCopyWithImpl<$Res, MyArticlesState>;
}

/// @nodoc
class _$MyArticlesStateCopyWithImpl<$Res, $Val extends MyArticlesState>
    implements $MyArticlesStateCopyWith<$Res> {
  _$MyArticlesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MyArticlesInitialImplCopyWith<$Res> {
  factory _$$MyArticlesInitialImplCopyWith(_$MyArticlesInitialImpl value,
          $Res Function(_$MyArticlesInitialImpl) then) =
      __$$MyArticlesInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MyArticlesInitialImplCopyWithImpl<$Res>
    extends _$MyArticlesStateCopyWithImpl<$Res, _$MyArticlesInitialImpl>
    implements _$$MyArticlesInitialImplCopyWith<$Res> {
  __$$MyArticlesInitialImplCopyWithImpl(_$MyArticlesInitialImpl _value,
      $Res Function(_$MyArticlesInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MyArticlesInitialImpl implements MyArticlesInitial {
  const _$MyArticlesInitialImpl();

  @override
  String toString() {
    return 'MyArticlesState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MyArticlesInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserArticleEntity> articles) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserArticleEntity> articles)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserArticleEntity> articles)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MyArticlesInitial value) initial,
    required TResult Function(MyArticlesLoading value) loading,
    required TResult Function(MyArticlesSuccess value) success,
    required TResult Function(MyArticlesFailure value) failure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MyArticlesInitial value)? initial,
    TResult? Function(MyArticlesLoading value)? loading,
    TResult? Function(MyArticlesSuccess value)? success,
    TResult? Function(MyArticlesFailure value)? failure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MyArticlesInitial value)? initial,
    TResult Function(MyArticlesLoading value)? loading,
    TResult Function(MyArticlesSuccess value)? success,
    TResult Function(MyArticlesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class MyArticlesInitial implements MyArticlesState {
  const factory MyArticlesInitial() = _$MyArticlesInitialImpl;
}

/// @nodoc
abstract class _$$MyArticlesLoadingImplCopyWith<$Res> {
  factory _$$MyArticlesLoadingImplCopyWith(_$MyArticlesLoadingImpl value,
          $Res Function(_$MyArticlesLoadingImpl) then) =
      __$$MyArticlesLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MyArticlesLoadingImplCopyWithImpl<$Res>
    extends _$MyArticlesStateCopyWithImpl<$Res, _$MyArticlesLoadingImpl>
    implements _$$MyArticlesLoadingImplCopyWith<$Res> {
  __$$MyArticlesLoadingImplCopyWithImpl(_$MyArticlesLoadingImpl _value,
      $Res Function(_$MyArticlesLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MyArticlesLoadingImpl implements MyArticlesLoading {
  const _$MyArticlesLoadingImpl();

  @override
  String toString() {
    return 'MyArticlesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MyArticlesLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserArticleEntity> articles) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserArticleEntity> articles)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserArticleEntity> articles)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MyArticlesInitial value) initial,
    required TResult Function(MyArticlesLoading value) loading,
    required TResult Function(MyArticlesSuccess value) success,
    required TResult Function(MyArticlesFailure value) failure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MyArticlesInitial value)? initial,
    TResult? Function(MyArticlesLoading value)? loading,
    TResult? Function(MyArticlesSuccess value)? success,
    TResult? Function(MyArticlesFailure value)? failure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MyArticlesInitial value)? initial,
    TResult Function(MyArticlesLoading value)? loading,
    TResult Function(MyArticlesSuccess value)? success,
    TResult Function(MyArticlesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class MyArticlesLoading implements MyArticlesState {
  const factory MyArticlesLoading() = _$MyArticlesLoadingImpl;
}

/// @nodoc
abstract class _$$MyArticlesSuccessImplCopyWith<$Res> {
  factory _$$MyArticlesSuccessImplCopyWith(_$MyArticlesSuccessImpl value,
          $Res Function(_$MyArticlesSuccessImpl) then) =
      __$$MyArticlesSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<UserArticleEntity> articles});
}

/// @nodoc
class __$$MyArticlesSuccessImplCopyWithImpl<$Res>
    extends _$MyArticlesStateCopyWithImpl<$Res, _$MyArticlesSuccessImpl>
    implements _$$MyArticlesSuccessImplCopyWith<$Res> {
  __$$MyArticlesSuccessImplCopyWithImpl(_$MyArticlesSuccessImpl _value,
      $Res Function(_$MyArticlesSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? articles = null,
  }) {
    return _then(_$MyArticlesSuccessImpl(
      null == articles
          ? _value._articles
          : articles // ignore: cast_nullable_to_non_nullable
              as List<UserArticleEntity>,
    ));
  }
}

/// @nodoc

class _$MyArticlesSuccessImpl implements MyArticlesSuccess {
  const _$MyArticlesSuccessImpl(final List<UserArticleEntity> articles)
      : _articles = articles;

  final List<UserArticleEntity> _articles;
  @override
  List<UserArticleEntity> get articles {
    if (_articles is EqualUnmodifiableListView) return _articles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_articles);
  }

  @override
  String toString() {
    return 'MyArticlesState.success(articles: $articles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyArticlesSuccessImpl &&
            const DeepCollectionEquality().equals(other._articles, _articles));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_articles));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MyArticlesSuccessImplCopyWith<_$MyArticlesSuccessImpl> get copyWith =>
      __$$MyArticlesSuccessImplCopyWithImpl<_$MyArticlesSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserArticleEntity> articles) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return success(articles);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserArticleEntity> articles)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return success?.call(articles);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserArticleEntity> articles)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(articles);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MyArticlesInitial value) initial,
    required TResult Function(MyArticlesLoading value) loading,
    required TResult Function(MyArticlesSuccess value) success,
    required TResult Function(MyArticlesFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MyArticlesInitial value)? initial,
    TResult? Function(MyArticlesLoading value)? loading,
    TResult? Function(MyArticlesSuccess value)? success,
    TResult? Function(MyArticlesFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MyArticlesInitial value)? initial,
    TResult Function(MyArticlesLoading value)? loading,
    TResult Function(MyArticlesSuccess value)? success,
    TResult Function(MyArticlesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class MyArticlesSuccess implements MyArticlesState {
  const factory MyArticlesSuccess(final List<UserArticleEntity> articles) =
      _$MyArticlesSuccessImpl;

  List<UserArticleEntity> get articles;
  @JsonKey(ignore: true)
  _$$MyArticlesSuccessImplCopyWith<_$MyArticlesSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MyArticlesFailureImplCopyWith<$Res> {
  factory _$$MyArticlesFailureImplCopyWith(_$MyArticlesFailureImpl value,
          $Res Function(_$MyArticlesFailureImpl) then) =
      __$$MyArticlesFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$MyArticlesFailureImplCopyWithImpl<$Res>
    extends _$MyArticlesStateCopyWithImpl<$Res, _$MyArticlesFailureImpl>
    implements _$$MyArticlesFailureImplCopyWith<$Res> {
  __$$MyArticlesFailureImplCopyWithImpl(_$MyArticlesFailureImpl _value,
      $Res Function(_$MyArticlesFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$MyArticlesFailureImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as AppFailure,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $AppFailureCopyWith<$Res> get failure {
    return $AppFailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$MyArticlesFailureImpl implements MyArticlesFailure {
  const _$MyArticlesFailureImpl(this.failure);

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'MyArticlesState.failure(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyArticlesFailureImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MyArticlesFailureImplCopyWith<_$MyArticlesFailureImpl> get copyWith =>
      __$$MyArticlesFailureImplCopyWithImpl<_$MyArticlesFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserArticleEntity> articles) success,
    required TResult Function(AppFailure failure) failure,
  }) {
    return failure(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserArticleEntity> articles)? success,
    TResult? Function(AppFailure failure)? failure,
  }) {
    return failure?.call(this.failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserArticleEntity> articles)? success,
    TResult Function(AppFailure failure)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this.failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MyArticlesInitial value) initial,
    required TResult Function(MyArticlesLoading value) loading,
    required TResult Function(MyArticlesSuccess value) success,
    required TResult Function(MyArticlesFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MyArticlesInitial value)? initial,
    TResult? Function(MyArticlesLoading value)? loading,
    TResult? Function(MyArticlesSuccess value)? success,
    TResult? Function(MyArticlesFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MyArticlesInitial value)? initial,
    TResult Function(MyArticlesLoading value)? loading,
    TResult Function(MyArticlesSuccess value)? success,
    TResult Function(MyArticlesFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class MyArticlesFailure implements MyArticlesState {
  const factory MyArticlesFailure(final AppFailure failure) =
      _$MyArticlesFailureImpl;

  AppFailure get failure;
  @JsonKey(ignore: true)
  _$$MyArticlesFailureImplCopyWith<_$MyArticlesFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
