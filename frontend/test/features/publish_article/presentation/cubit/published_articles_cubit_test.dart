import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/entities/publishable_article.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/repository/read_published_articles_repository.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/get_published_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/published_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/publish_article/presentation/cubit/published_articles_state.dart';

import '../../support/fake_read_published_articles_repository.dart';

class ControlledReadRepository implements ReadPublishedArticlesRepository {
  final requests = <Completer<List<PublishableArticle>>>[];

  @override
  Future<List<PublishableArticle>> getPublishedArticles() {
    final request = Completer<List<PublishableArticle>>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  test('emits loading then success and preserves repository order', () async {
    final repository = ControlledReadRepository();
    final cubit = PublishedArticlesCubit(
      GetPublishedArticlesUseCase(repository),
    );
    final states = <PublishedArticlesState>[];
    final subscription = cubit.stream.listen(states.add);

    final load = cubit.load();
    expect(repository.requests, hasLength(1));
    repository.requests.single.complete([
      publishedArticle(id: 'newest'),
      publishedArticle(id: 'oldest'),
    ]);
    await load;
    await Future<void>.delayed(Duration.zero);

    expect(states.map((state) => state.status), [
      PublishedArticlesStatus.loading,
      PublishedArticlesStatus.success,
    ]);
    expect(cubit.state.articles.map((article) => article.id), [
      'newest',
      'oldest',
    ]);
    await subscription.cancel();
    await cubit.close();
  });

  test('emits a successful empty state', () async {
    final repository = FakeReadPublishedArticlesRepository();
    final cubit = PublishedArticlesCubit(
      GetPublishedArticlesUseCase(repository),
    );

    await cubit.load();

    expect(cubit.state.status, PublishedArticlesStatus.success);
    expect(cubit.state.articles, isEmpty);
    await cubit.close();
  });

  test('emits failure and allows retry', () async {
    final repository = FakeReadPublishedArticlesRepository()
      ..error = StateError('unavailable');
    final cubit = PublishedArticlesCubit(
      GetPublishedArticlesUseCase(repository),
    );

    await cubit.load();
    expect(cubit.state.status, PublishedArticlesStatus.failure);

    repository
      ..error = null
      ..articles = [publishedArticle()];
    await cubit.load();

    expect(cubit.state.status, PublishedArticlesStatus.success);
    expect(cubit.state.articles, hasLength(1));
    expect(repository.calls, 2);
    await cubit.close();
  });

  test('ignores concurrent load requests', () async {
    final repository = ControlledReadRepository();
    final cubit = PublishedArticlesCubit(
      GetPublishedArticlesUseCase(repository),
    );

    final first = cubit.load();
    final second = cubit.load();
    expect(repository.requests, hasLength(1));
    repository.requests.single.complete([]);
    await Future.wait([first, second]);

    expect(cubit.state.status, PublishedArticlesStatus.success);
    await cubit.close();
  });
}
