import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/publish/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/publish_article/publish_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_thumbnail_preview.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/attach_image_button.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/loading_overlay.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockPickArticleThumbnailUseCase extends Mock implements PickArticleThumbnailUseCase {}

void main() {
  late MockPublishArticleUseCase publishArticle;
  late MockPickArticleThumbnailUseCase pickArticleThumbnail;

  setUpAll(() {
    registerFallbackValue(const PublishArticleParams(ArticleDraftEntity(title: '', content: '')));
  });

  setUp(() {
    publishArticle = MockPublishArticleUseCase();
    pickArticleThumbnail = MockPickArticleThumbnailUseCase();
    sl.registerFactory<PublishArticleCubit>(() => PublishArticleCubit(publishArticle, pickArticleThumbnail));
  });

  tearDown(() => sl.reset());

  Future<void> pumpPublishArticleScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublishArticleView())),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  void stubPublicationResult(DataState<void> result) {
    when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) async => result);
  }

  group('PublishArticleView', () {
    testWidgets('shows the empty draft of the prototype', (tester) async {
      await pumpPublishArticleScreen(tester);

      expect(find.text('Write your title here...'), findsOneWidget);
      expect(find.text('Add article here, .....'), findsOneWidget);
      expect(find.byType(AttachImageButton), findsOneWidget);
      expect(find.text('Publish Article'), findsOneWidget);
    });

    testWidgets('shows what is missing when publishing an empty draft', (tester) async {
      stubPublicationResult(const DataFailed(ArticleDraftValidationException([
        ArticleDraftError.emptyTitle,
        ArticleDraftError.emptyContent,
        ArticleDraftError.missingThumbnail,
      ])));
      await pumpPublishArticleScreen(tester);

      await tester.tap(find.text('Publish Article'));
      await tester.pumpAndSettle();

      expect(find.text('Please write a title.'), findsOneWidget);
      expect(find.text('Please write the article.'), findsOneWidget);
      expect(find.text('Please attach an image.'), findsOneWidget);
    });

    testWidgets('publishes the written title and content', (tester) async {
      stubPublicationResult(const DataSuccess(null));
      await pumpPublishArticleScreen(tester);

      await tester.enterText(find.byType(TextField).first, 'Breaking News!');
      await tester.enterText(find.byType(TextField).last, 'This is breaking news!');
      await tester.tap(find.text('Publish Article'));
      await tester.pumpAndSettle();

      final params = verify(() => publishArticle(params: captureAny(named: 'params'))).captured.single
          as PublishArticleParams;
      expect(params.draft.title, 'Breaking News!');
      expect(params.draft.content, 'This is breaking news!');
    });

    testWidgets('shows a loading overlay while publishing', (tester) async {
      final publication = Completer<DataState<void>>();
      when(() => publishArticle(params: any(named: 'params'))).thenAnswer((_) => publication.future);
      await pumpPublishArticleScreen(tester);

      await tester.tap(find.text('Publish Article'));
      await tester.pump();

      expect(find.byType(LoadingOverlay), findsOneWidget);
      publication.complete(const DataSuccess(null));
      await tester.pumpAndSettle();
    });

    testWidgets('confirms the publication and goes back', (tester) async {
      stubPublicationResult(const DataSuccess(null));
      await pumpPublishArticleScreen(tester);

      await tester.tap(find.text('Publish Article'));
      await tester.pumpAndSettle();

      expect(find.byType(PublishArticleView), findsNothing);
      expect(find.text('Article published successfully.'), findsOneWidget);
    });

    testWidgets('reports an unexpected failure and stays on the screen', (tester) async {
      stubPublicationResult(DataFailed(Exception('No connection')));
      await pumpPublishArticleScreen(tester);

      await tester.tap(find.text('Publish Article'));
      await tester.pumpAndSettle();

      expect(find.byType(PublishArticleView), findsOneWidget);
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    });

    testWidgets('replaces the attach button with the picked image, which can be changed', (tester) async {
      when(() => pickArticleThumbnail()).thenAnswer((_) async => const DataSuccess('/images/thumbnail.jpg'));
      await pumpPublishArticleScreen(tester);

      await tester.tap(find.byType(AttachImageButton));
      await tester.pumpAndSettle();

      expect(find.byType(AttachImageButton), findsNothing);
      expect(find.byType(ArticleThumbnailPreview), findsOneWidget);

      await tester.tap(find.byType(ArticleThumbnailPreview));
      await tester.pumpAndSettle();

      verify(() => pickArticleThumbnail()).called(2);
    });
  });
}
