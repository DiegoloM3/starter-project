import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/error_type.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../../fakes/fake_remote_news_repository.dart';

List<ArticleEntity> _generateArticles(int count, {int startId = 0}) {
  return List.generate(
    count,
    (i) => ArticleEntity(
      id: startId + i,
      title: 'Article ${startId + i}',
      url: 'https://example.com/${startId + i}',
    ),
  );
}

void main() {
  late FakeRemoteNewsRepository repository;
  late RemoteArticlesBloc bloc;

  setUp(() {
    repository = FakeRemoteNewsRepository();
    bloc = RemoteArticlesBloc(GetArticleUseCase(repository));
  });

  tearDown(() {
    bloc.close();
  });

  group('RemoteArticlesBloc', () {
    test('initial state is Loading', () {
      expect(bloc.state, isA<RemoteArticlesLoading>());
    });

    test('emits Done with articles on success', () async {
      const articles = [
        ArticleEntity(title: 'API Article', url: 'https://example.com'),
      ];
      repository.getResult = const DataSuccess(articles);

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesDone>());
      final doneState = bloc.state as RemoteArticlesDone;
      expect(doneState.articles?.length, 1);
      expect(doneState.articles?.first.title, 'API Article');
    });

    test('emits Done with empty list when no articles', () async {
      repository.getResult = const DataSuccess([]);

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesDone>());
      expect((bloc.state as RemoteArticlesDone).articles, isEmpty);
    });

    test('emits Cached with articles on DataSuccess with isCached', () async {
      const cached = [
        ArticleEntity(title: 'Cached Article', url: 'https://cached.com'),
      ];
      repository.getResult = const DataSuccess(cached, isCached: true);

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesCached>());
      final cachedState = bloc.state as RemoteArticlesCached;
      expect(cachedState.articles?.length, 1);
      expect(cachedState.articles?.first.title, 'Cached Article');
    });

    test('emits Error with correct ErrorType on failure', () async {
      repository.getResult = const DataFailed(NetworkFailure());

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesError>());
      expect(
        (bloc.state as RemoteArticlesError).errorType,
        ErrorType.network,
      );
    });

    test('emits Error with server ErrorType on server failure', () async {
      repository.getResult = const DataFailed(ServerFailure());

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesError>());
      expect(
        (bloc.state as RemoteArticlesError).errorType,
        ErrorType.server,
      );
    });

    test('reloads articles when GetArticles dispatched again', () async {
      repository.getResult = const DataSuccess([
        ArticleEntity(title: 'First'),
      ]);

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);
      expect((bloc.state as RemoteArticlesDone).articles?.first.title, 'First');

      repository.getResult = const DataSuccess([
        ArticleEntity(title: 'First'),
        ArticleEntity(title: 'Second'),
      ]);

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);
      expect((bloc.state as RemoteArticlesDone).articles?.length, 2);
    });

    test('hasMore is true when page returns articles', () async {
      repository.getResult = DataSuccess(_generateArticles(18));

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesDone>());
      expect(bloc.state.hasMore, isTrue);
    });

    test('hasMore is false when page returns empty list', () async {
      repository.getResult = const DataSuccess([]);

      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesDone>());
      expect(bloc.state.hasMore, isFalse);
    });
  });

  group('LoadMoreArticles', () {
    test('appends new articles to existing list', () async {
      repository.getResult = DataSuccess(_generateArticles(20));
      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);
      expect(bloc.state.articles?.length, 20);

      repository.getResult = DataSuccess(_generateArticles(10, startId: 20));
      bloc.add(const LoadMoreArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesDone>());
      expect(bloc.state.articles?.length, 30);
    });

    test('sets hasMore false when new page returns empty', () async {
      repository.getResult = DataSuccess(_generateArticles(18));
      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      repository.getResult = const DataSuccess([]);
      bloc.add(const LoadMoreArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state.hasMore, isFalse);
      expect(bloc.state.articles?.length, 18);
    });

    test('does nothing when hasMore is false', () async {
      repository.getResult = const DataSuccess([]);
      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);
      expect(bloc.state.hasMore, isFalse);

      bloc.add(const LoadMoreArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles, isEmpty);
    });

    test('keeps existing articles on load more failure', () async {
      repository.getResult = DataSuccess(_generateArticles(20));
      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      repository.getResult = const DataFailed(NetworkFailure());
      bloc.add(const LoadMoreArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state, isA<RemoteArticlesDone>());
      expect(bloc.state.articles?.length, 20);
      expect(bloc.state.hasMore, isFalse);
    });

    test('GetArticles resets pagination after LoadMore', () async {
      repository.getResult = DataSuccess(_generateArticles(18));
      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      repository.getResult = DataSuccess(_generateArticles(15, startId: 18));
      bloc.add(const LoadMoreArticles());
      await Future.delayed(Duration.zero);
      expect(bloc.state.articles?.length, 33);

      repository.getResult = DataSuccess(_generateArticles(5));
      bloc.add(const GetArticles());
      await Future.delayed(Duration.zero);

      expect(bloc.state.articles?.length, 5);
      expect(bloc.state.hasMore, isTrue);
    });
  });
}
