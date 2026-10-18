import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/exceptions/article_exceptions.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_draft.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/article_image.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/articles/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/publish_article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/upload_article_image.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/article_editor/article_editor_state.dart';

import '../article_presentation_test_data.dart';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockUpdateArticleUseCase extends Mock implements UpdateArticleUseCase {}

class MockUploadArticleImageUseCase extends Mock implements UploadArticleImageUseCase {}

void main() {
  late MockPublishArticleUseCase publishArticle;
  late MockUpdateArticleUseCase updateArticle;
  late MockUploadArticleImageUseCase uploadArticleImage;
  final article = buildArticle();
  final image = Uint8List(10);
  final draft = ArticleDraft(
    title: 'Title',
    description: 'Description',
    content: ArticleContent.fromPlainText('Content'),
    topics: const {ArticleTopic.technology},
  );

  setUpAll(() {
    registerFallbackValue(PublishArticleParams(draft: draft, thumbnail: ArticleImage(image)));
    registerFallbackValue(UpdateArticleParams(articleId: '', draft: draft));
    registerFallbackValue(ArticleImage(image));
  });

  setUp(() {
    publishArticle = MockPublishArticleUseCase();
    updateArticle = MockUpdateArticleUseCase();
    uploadArticleImage = MockUploadArticleImageUseCase();
  });

  ArticleEditorCubit buildCubit() => ArticleEditorCubit(publishArticle, updateArticle, uploadArticleImage);

  Future<void> submit(ArticleEditorCubit cubit, {String? articleId, Uint8List? thumbnail}) {
    return cubit.submit(
      articleId: articleId,
      title: ' Title ',
      description: 'Description',
      content: draft.content,
      topics: draft.topics,
      thumbnail: thumbnail,
    );
  }

  blocTest<ArticleEditorCubit, ArticleEditorState>(
    'publishes a new article with its thumbnail',
    setUp: () => when(() => publishArticle(any())).thenAnswer((_) async => DataSuccess(article)),
    build: buildCubit,
    act: (cubit) => submit(cubit, thumbnail: image),
    expect:
        () => [
          const ArticleEditorState(status: ArticleEditorStatus.submitting),
          ArticleEditorState(status: ArticleEditorStatus.success, savedArticle: article),
        ],
    verify: (_) {
      final params = verify(() => publishArticle(captureAny())).captured.single as PublishArticleParams;
      expect(params.draft.title, 'Title');
      expect(params.thumbnail.bytes, image);
    },
  );

  blocTest<ArticleEditorCubit, ArticleEditorState>(
    'updates an existing article',
    setUp: () => when(() => updateArticle(any())).thenAnswer((_) async => DataSuccess(article)),
    build: buildCubit,
    act: (cubit) => submit(cubit, articleId: article.id),
    expect:
        () => [
          const ArticleEditorState(status: ArticleEditorStatus.submitting),
          ArticleEditorState(status: ArticleEditorStatus.success, savedArticle: article),
        ],
    verify: (_) {
      final params = verify(() => updateArticle(captureAny())).captured.single as UpdateArticleParams;
      expect(params.articleId, article.id);
      expect(params.newThumbnail, isNull);
    },
  );

  blocTest<ArticleEditorCubit, ArticleEditorState>(
    'fails with the validation errors',
    setUp:
        () => when(
          () => publishArticle(any()),
        ).thenAnswer((_) async => const DataFailed(ArticleValidationException({ArticleValidationError.imageEmpty}))),
    build: buildCubit,
    act: (cubit) => submit(cubit),
    expect:
        () => const [
          ArticleEditorState(status: ArticleEditorStatus.submitting),
          ArticleEditorState(
            status: ArticleEditorStatus.failure,
            validationErrors: {ArticleValidationError.imageEmpty},
          ),
        ],
  );

  group('uploadContentImage', () {
    blocTest<ArticleEditorCubit, ArticleEditorState>(
      'returns the URL of the uploaded image',
      setUp: () => when(() => uploadArticleImage(any())).thenAnswer((_) async => const DataSuccess('https://img')),
      build: buildCubit,
      act: (cubit) async => expect(await cubit.uploadContentImage(image), 'https://img'),
      expect: () => const [ArticleEditorState(isUploadingImage: true), ArticleEditorState()],
    );

    blocTest<ArticleEditorCubit, ArticleEditorState>(
      'returns null and reports the failure',
      setUp: () => when(() => uploadArticleImage(any())).thenAnswer((_) async => DataFailed(Exception('offline'))),
      build: buildCubit,
      act: (cubit) async => expect(await cubit.uploadContentImage(image), isNull),
      expect:
          () => const [
            ArticleEditorState(isUploadingImage: true),
            ArticleEditorState(status: ArticleEditorStatus.imageUploadFailure),
          ],
    );
  });
}
