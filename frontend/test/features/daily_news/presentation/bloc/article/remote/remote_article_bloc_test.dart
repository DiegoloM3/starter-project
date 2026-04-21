import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

void main() {
  group('RemoteArticlesBloc', () {
    test('emits done for a successful empty payload', () async {
      final bloc = RemoteArticlesBloc(
        GetArticleUseCase(
          _FakeArticleRepository(
            newsArticles: const DataSuccess(<ArticleEntity>[]),
          ),
        ),
      );

      bloc.add(const GetArticles());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RemoteArticlesDone>().having(
            (state) => state.articles,
            'articles',
            isEmpty,
          ),
        ]),
      );

      await bloc.close();
    });

    test('emits error when the use case fails', () async {
      const error = ArticleFetchException('boom');
      final bloc = RemoteArticlesBloc(
        GetArticleUseCase(
          _FakeArticleRepository(
            newsArticles: const DataFailed<List<ArticleEntity>>(error),
          ),
        ),
      );

      bloc.add(const GetArticles());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RemoteArticlesError>().having(
            (state) => state.error,
            'error',
            same(error),
          ),
        ]),
      );

      await bloc.close();
    });
  });
}

class _FakeArticleRepository implements ArticleRepository {
  final DataState<List<ArticleEntity>> newsArticles;

  _FakeArticleRepository({required this.newsArticles});

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async =>
      newsArticles;

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => const [];

  @override
  Future<void> removeArticle(ArticleEntity article) async {}

  @override
  Future<void> saveArticle(ArticleEntity article) async {}
}
