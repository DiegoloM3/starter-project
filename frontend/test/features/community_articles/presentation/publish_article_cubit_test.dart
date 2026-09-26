import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/publish_article_cubit.dart';

const image = ArticleImageEntity(
  bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
  fileName: 'story.png',
  mimeType: 'image/png',
);

const replacementImage = ArticleImageEntity(
  bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
  fileName: 'replacement.png',
  mimeType: 'image/png',
);

class TestRepository implements CommunityArticleRepository {
  int publishCalls = 0;
  final requests = <PublishArticleParams>[];
  final responses = <DataState<CommunityArticleEntity>>[];
  final imageResponses = <DataState<ArticleImageEntity?>>[];
  Completer<void>? pickGate;
  int pickCalls = 0;
  final Completer<void> gate = Completer<void>();
  bool waitForGate = false;

  @override
  Future<DataState<List<CommunityArticleEntity>>>
      getPublishedArticles() async => const DataSuccess([]);

  @override
  Future<DataState<ArticleImageEntity?>> pickImage() async {
    pickCalls++;
    if (pickGate != null) await pickGate!.future;
    if (imageResponses.isNotEmpty) return imageResponses.removeAt(0);
    return const DataSuccess(image);
  }

  @override
  Future<DataState<CommunityArticleEntity>> publishArticle(
      PublishArticleParams params) async {
    publishCalls++;
    requests.add(params);
    if (waitForGate) await gate.future;
    if (responses.isNotEmpty) return responses.removeAt(0);
    return DataSuccess(_articleFor(params));
  }

  CommunityArticleEntity _articleFor(PublishArticleParams params) =>
      CommunityArticleEntity(
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
      );
}

Future<PublishArticleCubit> createCubit(TestRepository repository) async {
  final cubit = PublishArticleCubit(
    PublishArticleUseCase(repository),
    PickArticleImageUseCase(repository),
  );
  await cubit.selectImage();
  final cropState = cubit.state as PublishArticleCropRequired;
  cubit.confirmImageCrop(cropState.sourceImage);
  return cubit;
}

void main() {
  test('ignores a second image picker request while the first is pending',
      () async {
    final repository = TestRepository()..pickGate = Completer<void>();
    final cubit = PublishArticleCubit(
      PublishArticleUseCase(repository),
      PickArticleImageUseCase(repository),
    );

    final first = cubit.selectImage();
    final second = cubit.selectImage();

    expect(repository.pickCalls, 1);
    repository.pickGate!.complete();
    await Future.wait([first, second]);
    expect(cubit.state, isA<PublishArticleCropRequired>());
    await cubit.close();
  });

  test('ignores stale crop confirmation and cancellation sessions', () async {
    final repository = TestRepository()
      ..imageResponses.addAll([
        const DataSuccess(image),
        const DataSuccess(replacementImage),
      ]);
    final cubit = PublishArticleCubit(
      PublishArticleUseCase(repository),
      PickArticleImageUseCase(repository),
    );

    await cubit.selectImage();
    final firstCrop = cubit.state as PublishArticleCropRequired;
    await cubit.selectImage();
    final secondCrop = cubit.state as PublishArticleCropRequired;

    cubit.confirmImageCrop(
      firstCrop.sourceImage,
      sessionId: firstCrop.sessionId,
    );
    cubit.cancelImageCrop(sessionId: firstCrop.sessionId);

    expect(cubit.image, isNull);
    expect(cubit.state, isA<PublishArticleCropRequired>());
    expect(
      (cubit.state as PublishArticleCropRequired).sessionId,
      secondCrop.sessionId,
    );

    cubit.confirmImageCrop(
      replacementImage,
      sessionId: secondCrop.sessionId,
    );
    expect(cubit.image, same(replacementImage));
    expect(cubit.state, isA<PublishArticleIdle>());
    await cubit.close();
  });

  test('does not publish a selected image before crop confirmation', () async {
    final repository = TestRepository();
    final cubit = PublishArticleCubit(
      PublishArticleUseCase(repository),
      PickArticleImageUseCase(repository),
    );

    await cubit.selectImage();

    expect(cubit.image, isNull);
    expect(cubit.state, isA<PublishArticleCropRequired>());
    final cropState = cubit.state as PublishArticleCropRequired;
    cubit.confirmImageCrop(cropState.sourceImage);
    expect(cubit.image, same(image));
    await cubit.close();
  });

  test('canceling crop keeps the existing confirmed image', () async {
    final repository = TestRepository();
    final cubit = await createCubit(repository);
    final confirmed = cubit.image;

    await cubit.selectImage();
    expect(cubit.state, isA<PublishArticleCropRequired>());
    cubit.cancelImageCrop();

    expect(cubit.image, same(confirmed));
    expect(cubit.state, isA<PublishArticleIdle>());
    await cubit.close();
  });

  test('adjust crop uses the original source rather than the cropped bytes',
      () async {
    final repository = TestRepository();
    final cubit = await createCubit(repository);
    final original = cubit.cropSourceImage;

    cubit.adjustImage();

    final state = cubit.state as PublishArticleCropRequired;
    expect(state.sourceImage, same(original));
    await cubit.close();
  });

  test('ignores duplicate submit while the first request is pending', () async {
    final repository = TestRepository()..waitForGate = true;
    final cubit = await createCubit(repository);
    final first = cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );
    final second = cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );

    expect(repository.publishCalls, 1);
    expect(cubit.state, isA<PublishArticleSubmitting>());
    repository.gate.complete();
    await Future.wait([first, second]);
    expect(cubit.state, isA<PublishArticleSuccess>());
    await cubit.close();
  });

  test('generates a browser-compatible client request ID', () async {
    final repository = TestRepository();
    final cubit = await createCubit(repository);

    await cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );

    expect(repository.requests.single.clientId, startsWith('article-'));
    await cubit.close();
  });

  test('emits failure and reuses the request ID for an identical retry',
      () async {
    final repository = TestRepository()
      ..responses.addAll([
        const DataFailed(AppFailure('temporary failure')),
        DataSuccess(CommunityArticleEntity(
          id: 'article',
          author: 'Reporter',
          title: 'A valid title',
          description: 'This body is long enough to publish safely.',
          url: '',
          urlToImage: '',
          publishedAt: '',
          content: 'This body is long enough to publish safely.',
          thumbnailPath: '',
          payloadHash: '',
          ownerUid: 'owner',
        )),
      ]);
    final cubit = await createCubit(repository);

    await cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );
    expect(cubit.state, isA<PublishArticleFailure>());
    await cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );

    expect(repository.publishCalls, 2);
    expect(repository.requests[0].clientId, repository.requests[1].clientId);
    expect(cubit.state, isA<PublishArticleSuccess>());
    await cubit.close();
  });

  test('keeps the image and request identity when replacement is canceled',
      () async {
    final repository = TestRepository()
      ..responses.addAll([
        const DataFailed(AppFailure('temporary failure')),
        DataSuccess(CommunityArticleEntity(
          id: 'article',
          author: 'Reporter',
          title: 'A valid title',
          description: 'This body is long enough to publish safely.',
          url: '',
          urlToImage: '',
          publishedAt: '',
          content: 'This body is long enough to publish safely.',
          thumbnailPath: '',
          payloadHash: '',
          ownerUid: 'owner',
        )),
      ]);
    final cubit = await createCubit(repository);
    repository.imageResponses.add(const DataSuccess(null));

    await cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );
    expect(cubit.state, isA<PublishArticleFailure>());
    final firstRequest = repository.requests.single;

    await cubit.selectImage();
    expect(cubit.image, same(image));

    await cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );

    expect(repository.requests[1].clientId, firstRequest.clientId);
    expect(repository.requests[1].image, same(image));
    expect(cubit.state, isA<PublishArticleSuccess>());
    await cubit.close();
  });

  test('generates a new request ID after the retry payload changes', () async {
    final repository = TestRepository()
      ..responses.addAll([
        const DataFailed(AppFailure('temporary failure')),
        DataSuccess(CommunityArticleEntity(
          id: 'article',
          author: 'Reporter',
          title: 'A changed title',
          description: 'This body is long enough to publish safely.',
          url: '',
          urlToImage: '',
          publishedAt: '',
          content: 'This body is long enough to publish safely.',
          thumbnailPath: '',
          payloadHash: '',
          ownerUid: 'owner',
        )),
      ]);
    final cubit = await createCubit(repository);

    await cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );
    await cubit.submit(
      title: 'A changed title',
      content: 'This body is long enough to publish safely.',
    );

    expect(repository.requests[0].clientId,
        isNot(repository.requests[1].clientId));
    await cubit.close();
  });

  test('does not emit after close while a request is pending', () async {
    final repository = TestRepository()..waitForGate = true;
    final cubit = await createCubit(repository);
    final submit = cubit.submit(
      title: 'A valid title',
      content: 'This body is long enough to publish safely.',
    );
    await cubit.close();
    repository.gate.complete();

    await expectLater(submit, completes);
    expect(repository.publishCalls, 1);
  });
}
