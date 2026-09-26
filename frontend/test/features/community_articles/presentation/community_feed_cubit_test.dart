import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';

class _GatedRepository implements CommunityArticleRepository {
  final Completer<void> started = Completer<void>();
  final Completer<DataState<List<CommunityArticleEntity>>> response =
      Completer<DataState<List<CommunityArticleEntity>>>();
  int loadCalls = 0;

  @override
  Future<DataState<List<CommunityArticleEntity>>> getPublishedArticles() async {
    loadCalls++;
    if (!started.isCompleted) started.complete();
    return response.future;
  }

  @override
  Future<DataState<CommunityArticleEntity>> publishArticle(
    PublishArticleParams params,
  ) async =>
      const DataFailed(AppFailure('Not used in this test.'));

  @override
  Future<DataState<ArticleImageEntity?>> pickImage() async =>
      const DataSuccess(null);
}

const _article = CommunityArticleEntity(
  id: 'article-1',
  author: 'Reporter',
  title: 'A community article',
  description: 'A description',
  url: '',
  urlToImage: 'https://example.test/image.png',
  publishedAt: '2026-09-25T00:00:00Z',
  content: 'A body long enough for this focused Cubit test.',
  thumbnailPath: 'media/articles/user/article-1/image.png',
  payloadHash: 'hash',
  ownerUid: 'user',
);

void main() {
  test('ignores an overlapping load while the first request is pending',
      () async {
    final repository = _GatedRepository();
    final cubit = CommunityFeedCubit(GetCommunityArticlesUseCase(repository));
    addTearDown(cubit.close);

    final first = cubit.load();
    await repository.started.future;
    final second = cubit.load();

    expect(repository.loadCalls, 1);
    repository.response.complete(const DataSuccess([_article]));
    await Future.wait([first, second]);

    expect(cubit.state, isA<CommunityFeedLoaded>());
    expect((cubit.state as CommunityFeedLoaded).articles, [_article]);
  });

  test('does not emit when a pending load completes after close', () async {
    final repository = _GatedRepository();
    final cubit = CommunityFeedCubit(GetCommunityArticlesUseCase(repository));

    final load = cubit.load();
    await repository.started.future;
    await cubit.close();
    repository.response.complete(const DataSuccess([_article]));
    await load;

    expect(cubit.isClosed, isTrue);
  });
}
