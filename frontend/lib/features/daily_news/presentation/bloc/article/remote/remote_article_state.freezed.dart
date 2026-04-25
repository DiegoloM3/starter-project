// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_article_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RemoteArticlesState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ArticleEntity> articles) done,
    required TResult Function(AppFailure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ArticleEntity> articles)? done,
    TResult? Function(AppFailure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ArticleEntity> articles)? done,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RemoteArticlesLoading value) loading,
    required TResult Function(RemoteArticlesDone value) done,
    required TResult Function(RemoteArticlesError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RemoteArticlesLoading value)? loading,
    TResult? Function(RemoteArticlesDone value)? done,
    TResult? Function(RemoteArticlesError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RemoteArticlesLoading value)? loading,
    TResult Function(RemoteArticlesDone value)? done,
    TResult Function(RemoteArticlesError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoteArticlesStateCopyWith<$Res> {
  factory $RemoteArticlesStateCopyWith(
          RemoteArticlesState value, $Res Function(RemoteArticlesState) then) =
      _$RemoteArticlesStateCopyWithImpl<$Res, RemoteArticlesState>;
}

/// @nodoc
class _$RemoteArticlesStateCopyWithImpl<$Res, $Val extends RemoteArticlesState>
    implements $RemoteArticlesStateCopyWith<$Res> {
  _$RemoteArticlesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RemoteArticlesLoadingImplCopyWith<$Res> {
  factory _$$RemoteArticlesLoadingImplCopyWith(
          _$RemoteArticlesLoadingImpl value,
          $Res Function(_$RemoteArticlesLoadingImpl) then) =
      __$$RemoteArticlesLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RemoteArticlesLoadingImplCopyWithImpl<$Res>
    extends _$RemoteArticlesStateCopyWithImpl<$Res, _$RemoteArticlesLoadingImpl>
    implements _$$RemoteArticlesLoadingImplCopyWith<$Res> {
  __$$RemoteArticlesLoadingImplCopyWithImpl(_$RemoteArticlesLoadingImpl _value,
      $Res Function(_$RemoteArticlesLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RemoteArticlesLoadingImpl implements RemoteArticlesLoading {
  const _$RemoteArticlesLoadingImpl();

  @override
  String toString() {
    return 'RemoteArticlesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteArticlesLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ArticleEntity> articles) done,
    required TResult Function(AppFailure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ArticleEntity> articles)? done,
    TResult? Function(AppFailure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ArticleEntity> articles)? done,
    TResult Function(AppFailure failure)? error,
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
    required TResult Function(RemoteArticlesLoading value) loading,
    required TResult Function(RemoteArticlesDone value) done,
    required TResult Function(RemoteArticlesError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RemoteArticlesLoading value)? loading,
    TResult? Function(RemoteArticlesDone value)? done,
    TResult? Function(RemoteArticlesError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RemoteArticlesLoading value)? loading,
    TResult Function(RemoteArticlesDone value)? done,
    TResult Function(RemoteArticlesError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class RemoteArticlesLoading implements RemoteArticlesState {
  const factory RemoteArticlesLoading() = _$RemoteArticlesLoadingImpl;
}

/// @nodoc
abstract class _$$RemoteArticlesDoneImplCopyWith<$Res> {
  factory _$$RemoteArticlesDoneImplCopyWith(_$RemoteArticlesDoneImpl value,
          $Res Function(_$RemoteArticlesDoneImpl) then) =
      __$$RemoteArticlesDoneImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ArticleEntity> articles});
}

/// @nodoc
class __$$RemoteArticlesDoneImplCopyWithImpl<$Res>
    extends _$RemoteArticlesStateCopyWithImpl<$Res, _$RemoteArticlesDoneImpl>
    implements _$$RemoteArticlesDoneImplCopyWith<$Res> {
  __$$RemoteArticlesDoneImplCopyWithImpl(_$RemoteArticlesDoneImpl _value,
      $Res Function(_$RemoteArticlesDoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? articles = null,
  }) {
    return _then(_$RemoteArticlesDoneImpl(
      null == articles
          ? _value._articles
          : articles // ignore: cast_nullable_to_non_nullable
              as List<ArticleEntity>,
    ));
  }
}

/// @nodoc

class _$RemoteArticlesDoneImpl implements RemoteArticlesDone {
  const _$RemoteArticlesDoneImpl(final List<ArticleEntity> articles)
      : _articles = articles;

  final List<ArticleEntity> _articles;
  @override
  List<ArticleEntity> get articles {
    if (_articles is EqualUnmodifiableListView) return _articles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_articles);
  }

  @override
  String toString() {
    return 'RemoteArticlesState.done(articles: $articles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteArticlesDoneImpl &&
            const DeepCollectionEquality().equals(other._articles, _articles));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_articles));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteArticlesDoneImplCopyWith<_$RemoteArticlesDoneImpl> get copyWith =>
      __$$RemoteArticlesDoneImplCopyWithImpl<_$RemoteArticlesDoneImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ArticleEntity> articles) done,
    required TResult Function(AppFailure failure) error,
  }) {
    return done(articles);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ArticleEntity> articles)? done,
    TResult? Function(AppFailure failure)? error,
  }) {
    return done?.call(articles);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ArticleEntity> articles)? done,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(articles);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RemoteArticlesLoading value) loading,
    required TResult Function(RemoteArticlesDone value) done,
    required TResult Function(RemoteArticlesError value) error,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RemoteArticlesLoading value)? loading,
    TResult? Function(RemoteArticlesDone value)? done,
    TResult? Function(RemoteArticlesError value)? error,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RemoteArticlesLoading value)? loading,
    TResult Function(RemoteArticlesDone value)? done,
    TResult Function(RemoteArticlesError value)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }
}

abstract class RemoteArticlesDone implements RemoteArticlesState {
  const factory RemoteArticlesDone(final List<ArticleEntity> articles) =
      _$RemoteArticlesDoneImpl;

  List<ArticleEntity> get articles;
  @JsonKey(ignore: true)
  _$$RemoteArticlesDoneImplCopyWith<_$RemoteArticlesDoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RemoteArticlesErrorImplCopyWith<$Res> {
  factory _$$RemoteArticlesErrorImplCopyWith(_$RemoteArticlesErrorImpl value,
          $Res Function(_$RemoteArticlesErrorImpl) then) =
      __$$RemoteArticlesErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$RemoteArticlesErrorImplCopyWithImpl<$Res>
    extends _$RemoteArticlesStateCopyWithImpl<$Res, _$RemoteArticlesErrorImpl>
    implements _$$RemoteArticlesErrorImplCopyWith<$Res> {
  __$$RemoteArticlesErrorImplCopyWithImpl(_$RemoteArticlesErrorImpl _value,
      $Res Function(_$RemoteArticlesErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$RemoteArticlesErrorImpl(
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

class _$RemoteArticlesErrorImpl implements RemoteArticlesError {
  const _$RemoteArticlesErrorImpl(this.failure);

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'RemoteArticlesState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteArticlesErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteArticlesErrorImplCopyWith<_$RemoteArticlesErrorImpl> get copyWith =>
      __$$RemoteArticlesErrorImplCopyWithImpl<_$RemoteArticlesErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(List<ArticleEntity> articles) done,
    required TResult Function(AppFailure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(List<ArticleEntity> articles)? done,
    TResult? Function(AppFailure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(List<ArticleEntity> articles)? done,
    TResult Function(AppFailure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RemoteArticlesLoading value) loading,
    required TResult Function(RemoteArticlesDone value) done,
    required TResult Function(RemoteArticlesError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RemoteArticlesLoading value)? loading,
    TResult? Function(RemoteArticlesDone value)? done,
    TResult? Function(RemoteArticlesError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RemoteArticlesLoading value)? loading,
    TResult Function(RemoteArticlesDone value)? done,
    TResult Function(RemoteArticlesError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class RemoteArticlesError implements RemoteArticlesState {
  const factory RemoteArticlesError(final AppFailure failure) =
      _$RemoteArticlesErrorImpl;

  AppFailure get failure;
  @JsonKey(ignore: true)
  _$$RemoteArticlesErrorImplCopyWith<_$RemoteArticlesErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
