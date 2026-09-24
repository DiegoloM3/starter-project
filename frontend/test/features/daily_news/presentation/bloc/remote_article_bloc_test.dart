import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../../helpers/fake_article_repository.dart';

void main() {
  late FakeArticleRepository repository;

  setUp(() {
    repository = FakeArticleRepository();
  });

  RemoteArticlesBloc buildBloc() =>
      RemoteArticlesBloc(GetArticlesUseCase(repository));

  Future<RemoteArticlesState> loadWith(GetArticles event) async {
    final bloc = buildBloc();
    bloc.add(event);
    await Future.delayed(const Duration(milliseconds: 50));
    final state = bloc.state;
    await bloc.close();

    return state;
  }

  test('asks the api for the section that was chosen', () async {
    await loadWith(const GetArticles(category: NewsCategory.technology));

    expect(repository.lastRequestedCategory, NewsCategory.technology);
  });

  test('defaults to general news', () async {
    await loadWith(const GetArticles());

    expect(repository.lastRequestedCategory, NewsCategory.general);
  });

  test('every state carries the section, including while loading', () async {
    final bloc = buildBloc();
    bloc.add(const GetArticles(category: NewsCategory.sports));
    await Future.delayed(Duration.zero);

    // The chip must stay on what was tapped while the request is in flight.
    expect(bloc.state.category, NewsCategory.sports);

    await bloc.close();
  });

  test('an empty section is an answer, not a failure', () async {
    // This used to leave the feed loading forever: neither branch emitted
    // anything when the API came back with nothing.
    repository.newsArticlesResult = const DataSuccess([]);

    final state = await loadWith(const GetArticles());

    expect(state, isA<RemoteArticlesDone>());
    expect(state.articles, isEmpty);
  });

  test('reports a failure with the section it was trying to load', () async {
    repository.newsArticlesResult = const DataFailed(FormatException('boom'));

    final state = await loadWith(
      const GetArticles(category: NewsCategory.health),
    );

    expect(state, isA<RemoteArticlesError>());
    expect(state.category, NewsCategory.health);
  });
}
