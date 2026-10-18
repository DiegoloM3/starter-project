import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles_by_authors.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_for_you_articles.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles/articles_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles/articles_state.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/get_followed_user_ids.dart';

import '../article_presentation_test_data.dart';

class MockGetFollowedUserIdsUseCase extends Mock implements GetFollowedUserIdsUseCase {}

class MockGetForYouArticlesUseCase extends Mock implements GetForYouArticlesUseCase {}

class MockGetArticlesByAuthorsUseCase extends Mock implements GetArticlesByAuthorsUseCase {}

void main() {
  late MockGetFollowedUserIdsUseCase getFollowedUserIds;
  late MockGetForYouArticlesUseCase getForYouArticles;
  late MockGetArticlesByAuthorsUseCase getArticlesByAuthors;
  final forYouArticles = [buildArticle(id: 'for-you')];
  final followingArticles = [buildArticle(id: 'following')];
  final loadedState = ArticlesState(
    status: ArticlesStatus.success,
    forYouArticles: forYouArticles,
    followingArticles: followingArticles,
  );

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getFollowedUserIds = MockGetFollowedUserIdsUseCase();
    getForYouArticles = MockGetForYouArticlesUseCase();
    getArticlesByAuthors = MockGetArticlesByAuthorsUseCase();
    when(() => getFollowedUserIds(any())).thenAnswer((_) async => const DataSuccess(['followed']));
    when(() => getForYouArticles(['followed'])).thenAnswer((_) async => DataSuccess(forYouArticles));
    when(() => getArticlesByAuthors(['followed'])).thenAnswer((_) async => DataSuccess(followingArticles));
  });

  ArticlesCubit buildCubit() => ArticlesCubit(getFollowedUserIds, getForYouArticles, getArticlesByAuthors);

  test('starts without articles', () {
    expect(buildCubit().state, const ArticlesState());
  });

  blocTest<ArticlesCubit, ArticlesState>(
    'loads the articles for you and those of the followed users',
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [const ArticlesState(status: ArticlesStatus.loading), loadedState],
  );

  blocTest<ArticlesCubit, ArticlesState>(
    'keeps the current articles while refreshing and when it fails',
    setUp: () => when(() => getForYouArticles(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: buildCubit,
    seed: () => loadedState,
    act: (cubit) => cubit.load(),
    expect:
        () => [
          ArticlesState(
            status: ArticlesStatus.loading,
            forYouArticles: forYouArticles,
            followingArticles: followingArticles,
          ),
          ArticlesState(
            status: ArticlesStatus.failure,
            forYouArticles: forYouArticles,
            followingArticles: followingArticles,
          ),
        ],
  );

  blocTest<ArticlesCubit, ArticlesState>(
    'fails when the followed users cannot be loaded',
    setUp: () => when(() => getFollowedUserIds(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect:
        () => [
          const ArticlesState(status: ArticlesStatus.loading),
          const ArticlesState(status: ArticlesStatus.failure),
        ],
    verify: (_) => verifyNever(() => getForYouArticles(any())),
  );
}
