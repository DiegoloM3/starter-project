import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class _SequenceRepository implements ArticleRepository {
  final List<DataState<List<ArticleEntity>>> _responses;
  int calls = 0;

  _SequenceRepository(this._responses);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async =>
      _responses[calls++];

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => const [];

  @override
  Future<void> saveArticle(ArticleEntity article) async {}

  @override
  Future<void> removeArticle(ArticleEntity article) async {}
}

Future<void> _waitForCalls(_SequenceRepository repository, int expected) async {
  while (repository.calls < expected) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('retries after repeated failure and then emits success safely',
      () async {
    const failure = DataFailed<List<ArticleEntity>>(AppFailure('Offline'));
    const success = DataSuccess<List<ArticleEntity>>([
      ArticleEntity(
        title: 'Recovered headline',
        url: 'https://example.test/recovered',
      ),
    ]);
    final repository = _SequenceRepository([failure, failure, success]);
    final bloc = RemoteArticlesBloc(GetArticleUseCase(repository));

    final firstFailure = bloc.stream.firstWhere(
      (state) => state is RemoteArticlesError,
    );
    bloc.add(const GetArticles());
    expect(await firstFailure, isA<RemoteArticlesError>());

    bloc.add(const GetArticles());
    await _waitForCalls(repository, 2);
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state, isA<RemoteArticlesError>());

    final recovered = bloc.stream.firstWhere(
      (state) => state is RemoteArticlesDone,
    );
    bloc.add(const GetArticles());
    final state = await recovered;

    expect((state as RemoteArticlesDone).articles!.single.title,
        'Recovered headline');
    await bloc.close();
  });
}
