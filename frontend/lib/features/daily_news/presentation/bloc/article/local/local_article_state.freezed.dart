// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_article_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LocalArticlesState {
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
    required TResult Function(LocalArticlesLoading value) loading,
    required TResult Function(LocalArticlesDone value) done,
    required TResult Function(LocalArticlesError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalArticlesLoading value)? loading,
    TResult? Function(LocalArticlesDone value)? done,
    TResult? Function(LocalArticlesError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalArticlesLoading value)? loading,
    TResult Function(LocalArticlesDone value)? done,
    TResult Function(LocalArticlesError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalArticlesStateCopyWith<$Res> {
  factory $LocalArticlesStateCopyWith(
          LocalArticlesState value, $Res Function(LocalArticlesState) then) =
      _$LocalArticlesStateCopyWithImpl<$Res, LocalArticlesState>;
}

/// @nodoc
class _$LocalArticlesStateCopyWithImpl<$Res, $Val extends LocalArticlesState>
    implements $LocalArticlesStateCopyWith<$Res> {
  _$LocalArticlesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LocalArticlesLoadingImplCopyWith<$Res> {
  factory _$$LocalArticlesLoadingImplCopyWith(_$LocalArticlesLoadingImpl value,
          $Res Function(_$LocalArticlesLoadingImpl) then) =
      __$$LocalArticlesLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LocalArticlesLoadingImplCopyWithImpl<$Res>
    extends _$LocalArticlesStateCopyWithImpl<$Res, _$LocalArticlesLoadingImpl>
    implements _$$LocalArticlesLoadingImplCopyWith<$Res> {
  __$$LocalArticlesLoadingImplCopyWithImpl(_$LocalArticlesLoadingImpl _value,
      $Res Function(_$LocalArticlesLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LocalArticlesLoadingImpl implements LocalArticlesLoading {
  const _$LocalArticlesLoadingImpl();

  @override
  String toString() {
    return 'LocalArticlesState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalArticlesLoadingImpl);
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
    required TResult Function(LocalArticlesLoading value) loading,
    required TResult Function(LocalArticlesDone value) done,
    required TResult Function(LocalArticlesError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalArticlesLoading value)? loading,
    TResult? Function(LocalArticlesDone value)? done,
    TResult? Function(LocalArticlesError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalArticlesLoading value)? loading,
    TResult Function(LocalArticlesDone value)? done,
    TResult Function(LocalArticlesError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class LocalArticlesLoading implements LocalArticlesState {
  const factory LocalArticlesLoading() = _$LocalArticlesLoadingImpl;
}

/// @nodoc
abstract class _$$LocalArticlesDoneImplCopyWith<$Res> {
  factory _$$LocalArticlesDoneImplCopyWith(_$LocalArticlesDoneImpl value,
          $Res Function(_$LocalArticlesDoneImpl) then) =
      __$$LocalArticlesDoneImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ArticleEntity> articles});
}

/// @nodoc
class __$$LocalArticlesDoneImplCopyWithImpl<$Res>
    extends _$LocalArticlesStateCopyWithImpl<$Res, _$LocalArticlesDoneImpl>
    implements _$$LocalArticlesDoneImplCopyWith<$Res> {
  __$$LocalArticlesDoneImplCopyWithImpl(_$LocalArticlesDoneImpl _value,
      $Res Function(_$LocalArticlesDoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? articles = null,
  }) {
    return _then(_$LocalArticlesDoneImpl(
      null == articles
          ? _value._articles
          : articles // ignore: cast_nullable_to_non_nullable
              as List<ArticleEntity>,
    ));
  }
}

/// @nodoc

class _$LocalArticlesDoneImpl implements LocalArticlesDone {
  const _$LocalArticlesDoneImpl(final List<ArticleEntity> articles)
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
    return 'LocalArticlesState.done(articles: $articles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalArticlesDoneImpl &&
            const DeepCollectionEquality().equals(other._articles, _articles));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_articles));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalArticlesDoneImplCopyWith<_$LocalArticlesDoneImpl> get copyWith =>
      __$$LocalArticlesDoneImplCopyWithImpl<_$LocalArticlesDoneImpl>(
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
    required TResult Function(LocalArticlesLoading value) loading,
    required TResult Function(LocalArticlesDone value) done,
    required TResult Function(LocalArticlesError value) error,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalArticlesLoading value)? loading,
    TResult? Function(LocalArticlesDone value)? done,
    TResult? Function(LocalArticlesError value)? error,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalArticlesLoading value)? loading,
    TResult Function(LocalArticlesDone value)? done,
    TResult Function(LocalArticlesError value)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }
}

abstract class LocalArticlesDone implements LocalArticlesState {
  const factory LocalArticlesDone(final List<ArticleEntity> articles) =
      _$LocalArticlesDoneImpl;

  List<ArticleEntity> get articles;
  @JsonKey(ignore: true)
  _$$LocalArticlesDoneImplCopyWith<_$LocalArticlesDoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LocalArticlesErrorImplCopyWith<$Res> {
  factory _$$LocalArticlesErrorImplCopyWith(_$LocalArticlesErrorImpl value,
          $Res Function(_$LocalArticlesErrorImpl) then) =
      __$$LocalArticlesErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AppFailure failure});

  $AppFailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$LocalArticlesErrorImplCopyWithImpl<$Res>
    extends _$LocalArticlesStateCopyWithImpl<$Res, _$LocalArticlesErrorImpl>
    implements _$$LocalArticlesErrorImplCopyWith<$Res> {
  __$$LocalArticlesErrorImplCopyWithImpl(_$LocalArticlesErrorImpl _value,
      $Res Function(_$LocalArticlesErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$LocalArticlesErrorImpl(
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

class _$LocalArticlesErrorImpl implements LocalArticlesError {
  const _$LocalArticlesErrorImpl(this.failure);

  @override
  final AppFailure failure;

  @override
  String toString() {
    return 'LocalArticlesState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalArticlesErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalArticlesErrorImplCopyWith<_$LocalArticlesErrorImpl> get copyWith =>
      __$$LocalArticlesErrorImplCopyWithImpl<_$LocalArticlesErrorImpl>(
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
    required TResult Function(LocalArticlesLoading value) loading,
    required TResult Function(LocalArticlesDone value) done,
    required TResult Function(LocalArticlesError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LocalArticlesLoading value)? loading,
    TResult? Function(LocalArticlesDone value)? done,
    TResult? Function(LocalArticlesError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LocalArticlesLoading value)? loading,
    TResult Function(LocalArticlesDone value)? done,
    TResult Function(LocalArticlesError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class LocalArticlesError implements LocalArticlesState {
  const factory LocalArticlesError(final AppFailure failure) =
      _$LocalArticlesErrorImpl;

  AppFailure get failure;
  @JsonKey(ignore: true)
  _$$LocalArticlesErrorImplCopyWith<_$LocalArticlesErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
