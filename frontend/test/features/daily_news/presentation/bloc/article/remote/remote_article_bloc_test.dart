import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_news_feed.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class MockGetNewsFeedUseCase extends Mock implements GetNewsFeedUseCase {}

void main() {
  late MockGetNewsFeedUseCase getNewsFeed;
  late RemoteArticlesBloc bloc;

  setUp(() {
    getNewsFeed = MockGetNewsFeedUseCase();
    bloc = RemoteArticlesBloc(getNewsFeed);
  });

  tearDown(() => bloc.close());

  group('RemoteArticlesBloc', () {
    test('starts loading', () {
      expect(bloc.state, const RemoteArticlesLoading());
    });

    test('emits the articles of the news feed', () async {
      const articles = [ArticleEntity(title: 'Breaking News!')];
      when(() => getNewsFeed()).thenAnswer((_) async => const DataSuccess(articles));

      bloc.add(const GetArticles());

      await expectLater(bloc.stream, emits(const RemoteArticlesDone(articles)));
    });

    test('emits an empty feed instead of loading forever', () async {
      when(() => getNewsFeed()).thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));

      bloc.add(const GetArticles());

      await expectLater(bloc.stream, emits(const RemoteArticlesDone([])));
    });

    test('emits an error when the news feed fails', () async {
      final error = Exception('No connection');
      when(() => getNewsFeed()).thenAnswer((_) async => DataFailed(error));

      bloc.add(const GetArticles());

      await expectLater(bloc.stream, emits(RemoteArticlesError(error)));
    });

    test('shows the loading indicator again when retrying after an error', () async {
      const articles = [ArticleEntity(title: 'Breaking News!')];
      final error = Exception('No connection');
      when(() => getNewsFeed()).thenAnswer((_) async => DataFailed(error));
      bloc.add(const GetArticles());
      await expectLater(bloc.stream, emits(RemoteArticlesError(error)));
      when(() => getNewsFeed()).thenAnswer((_) async => const DataSuccess(articles));

      bloc.add(const GetArticles());

      await expectLater(bloc.stream, emitsInOrder([
        const RemoteArticlesLoading(),
        const RemoteArticlesDone(articles),
      ]));
    });

    test('keeps the current articles while the feed is refreshed', () async {
      const articles = [ArticleEntity(title: 'Breaking News!')];
      const newArticles = [ArticleEntity(title: 'Latest news'), ArticleEntity(title: 'Breaking News!')];
      when(() => getNewsFeed()).thenAnswer((_) async => const DataSuccess(articles));
      bloc.add(const GetArticles());
      await expectLater(bloc.stream, emits(const RemoteArticlesDone(articles)));
      when(() => getNewsFeed()).thenAnswer((_) async => const DataSuccess(newArticles));

      bloc.add(const GetArticles());

      await expectLater(bloc.stream, emitsInOrder([
        const RemoteArticlesRefreshing(articles),
        const RemoteArticlesDone(newArticles),
      ]));
    });
  });
}
