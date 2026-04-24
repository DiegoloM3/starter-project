import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/delete_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/my_articles/my_articles_state.dart';

class _MockGetMyArticles extends Mock implements GetMyArticlesUseCase {}

class _MockDeleteArticle extends Mock implements DeleteArticleUseCase {}

UserArticleEntity _article(String id) {
  return UserArticleEntity(
    id: id,
    authorId: 'u1',
    authorName: 'Author',
    title: 'Title $id',
    description: 'desc',
    content: 'c' * 60,
    thumbnailURL: 'https://cdn.test/$id.jpg',
    publishedAt: DateTime(2026, 4, 24),
    updatedAt: DateTime(2026, 4, 24),
  );
}

void main() {
  late _MockGetMyArticles getMyArticles;
  late _MockDeleteArticle deleteArticle;

  setUpAll(() {
    registerFallbackValue(const DeleteArticleParams(id: 'x'));
  });

  setUp(() {
    getMyArticles = _MockGetMyArticles();
    deleteArticle = _MockDeleteArticle();
  });

  MyArticlesCubit build() => MyArticlesCubit(
        getMyArticles: getMyArticles,
        deleteArticle: deleteArticle,
      );

  blocTest<MyArticlesCubit, MyArticlesState>(
    'load emits loading -> success on repository Right',
    setUp: () {
      when(() => getMyArticles('u1')).thenAnswer(
        (_) async => Right<AppFailure, List<UserArticleEntity>>(
          [_article('a'), _article('b')],
        ),
      );
    },
    build: build,
    act: (cubit) => cubit.load('u1'),
    expect: () => [
      const MyArticlesState.loading(),
      isA<MyArticlesSuccess>()
          .having((s) => s.articles.length, 'length', 2),
    ],
  );

  blocTest<MyArticlesCubit, MyArticlesState>(
    'load emits loading -> failure on repository Left',
    setUp: () {
      when(() => getMyArticles('u1')).thenAnswer(
        (_) async => const Left<AppFailure, List<UserArticleEntity>>(
          AppFailure.network(message: 'offline'),
        ),
      );
    },
    build: build,
    act: (cubit) => cubit.load('u1'),
    expect: () => [
      const MyArticlesState.loading(),
      isA<MyArticlesFailure>(),
    ],
  );

  blocTest<MyArticlesCubit, MyArticlesState>(
    'delete optimistically removes the article on Right',
    setUp: () {
      when(() => getMyArticles('u1')).thenAnswer(
        (_) async => Right<AppFailure, List<UserArticleEntity>>(
          [_article('a'), _article('b')],
        ),
      );
      when(() => deleteArticle(any())).thenAnswer(
        (_) async => const Right<AppFailure, Unit>(unit),
      );
    },
    build: build,
    act: (cubit) async {
      await cubit.load('u1');
      await cubit.delete(authorId: 'u1', id: 'a');
    },
    skip: 2,
    expect: () => [
      isA<MyArticlesSuccess>()
          .having((s) => s.articles.single.id, 'id', 'b'),
    ],
  );
}
