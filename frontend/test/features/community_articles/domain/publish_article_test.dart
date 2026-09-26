import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/publish_article.dart';

class FakeRepository implements CommunityArticleRepository {
  int publishCalls = 0;
  PublishArticleParams? lastParams;

  @override
  Future<DataState<List<CommunityArticleEntity>>>
      getPublishedArticles() async => const DataSuccess([]);
  @override
  Future<DataState<ArticleImageEntity?>> pickImage() async =>
      const DataSuccess(null);
  @override
  Future<DataState<CommunityArticleEntity>> publishArticle(
      PublishArticleParams params) async {
    publishCalls++;
    lastParams = params;
    return DataSuccess(CommunityArticleEntity(
      id: params.clientId,
      author: 'Reporter',
      title: params.title,
      description: params.content,
      url: '',
      urlToImage: '',
      publishedAt: '',
      content: params.content,
      thumbnailPath: '',
      payloadHash: '',
      ownerUid: 'owner',
    ));
  }
}

ArticleImageEntity validImage() => const ArticleImageEntity(
      bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
      fileName: 'story.png',
      mimeType: 'image/png',
    );

PublishArticleParams validParams(
        {String? title, String? content, ArticleImageEntity? image}) =>
    PublishArticleParams(
      clientId: 'test',
      title: title ?? 'A valid title',
      content: content ?? 'This body is long enough to publish safely.',
      image: image ?? validImage(),
    );

void main() {
  test('rejects title and body before reaching a repository', () async {
    final repository = FakeRepository();
    final result =
        await PublishArticleUseCase(repository)(const PublishArticleParams(
      clientId: 'test',
      title: 'no',
      content: 'too short',
    ));
    expect(result, isA<DataFailed<CommunityArticleEntity>>());
    expect(repository.publishCalls, 0);
  });

  test('requires an image even when title and body are valid', () async {
    final repository = FakeRepository();
    final result =
        await PublishArticleUseCase(repository)(const PublishArticleParams(
      clientId: 'test',
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    ));

    expect(result, isA<DataFailed<CommunityArticleEntity>>());
    expect(result.error!.message, contains('image'));
    expect(repository.publishCalls, 0);
  });

  test('rejects unsupported image bytes', () async {
    final repository = FakeRepository();
    final result = await PublishArticleUseCase(repository)(validParams(
      image: const ArticleImageEntity(
        bytes: [1, 2, 3, 4],
        fileName: 'story.png',
        mimeType: 'image/png',
      ),
    ));

    expect(result, isA<DataFailed<CommunityArticleEntity>>());
    expect(result.error!.message, contains('valid JPEG'));
    expect(repository.publishCalls, 0);
  });

  test('rejects images larger than 5 MB', () async {
    final repository = FakeRepository();
    final bytes = <int>[
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      ...List<int>.filled(5 * 1024 * 1024, 0),
    ];
    final result = await PublishArticleUseCase(repository)(validParams(
      image: ArticleImageEntity(
        bytes: bytes,
        fileName: 'story.png',
        mimeType: 'image/png',
      ),
    ));

    expect(result, isA<DataFailed<CommunityArticleEntity>>());
    expect(result.error!.message, contains('5 MB'));
    expect(repository.publishCalls, 0);
  });

  test('enforces title and body bounds', () async {
    final repository = FakeRepository();
    final shortTitle =
        await PublishArticleUseCase(repository)(validParams(title: '1234'));
    final longTitle =
        await PublishArticleUseCase(repository)(validParams(title: 'x' * 121));
    final shortBody =
        await PublishArticleUseCase(repository)(validParams(content: 'x' * 19));
    final longBody = await PublishArticleUseCase(repository)(
        validParams(content: 'x' * 10001));

    expect(shortTitle, isA<DataFailed<CommunityArticleEntity>>());
    expect(longTitle, isA<DataFailed<CommunityArticleEntity>>());
    expect(shortBody, isA<DataFailed<CommunityArticleEntity>>());
    expect(longBody, isA<DataFailed<CommunityArticleEntity>>());
    expect(repository.publishCalls, 0);
  });

  test('passes trimmed valid content to the repository', () async {
    final repository = FakeRepository();
    final result = await PublishArticleUseCase(repository)(PublishArticleParams(
      clientId: 'test',
      title: '  A valid title  ',
      content: '  This body is long enough to publish safely.  ',
      image: validImage(),
    ));
    expect(result, isA<DataSuccess<CommunityArticleEntity>>());
    expect(repository.publishCalls, 1);
    expect(repository.lastParams!.title, 'A valid title');
    expect(repository.lastParams!.content,
        'This body is long enough to publish safely.');
    expect(repository.lastParams!.image, validImage());
  });
}
