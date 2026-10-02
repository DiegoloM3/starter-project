import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_thumbnail_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/journalist_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/publish_article/publish_article_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/publish_article/publish_article_screen.dart';

/// Publishes every article it receives in the name of the signed-in journalist, as Firestore and Cloud Storage would.
class FakeJournalistArticleRepository implements JournalistArticleRepository {
  @override
  Future<DataState<List<JournalistArticleEntity>>> getPublishedArticles() async => const DataSuccess([]);

  @override
  Future<DataState<JournalistArticleEntity>> publishArticle(ArticleDraftEntity draft) async {
    return DataSuccess(JournalistArticleEntity(
      id: 'article1',
      title: draft.title,
      description: draft.description,
      content: draft.content,
      author: 'Jane Doe',
      authorId: 'janeDoeUid',
      thumbnailURL: 'https://example.com/media%2Farticles%2Farticle1.png',
      publishedAt: DateTime.utc(2026, 10, 1),
    ));
  }
}

/// Returns a 1x1 PNG, as if the journalist had chosen it in the gallery.
class FakeArticleThumbnailRepository implements ArticleThumbnailRepository {
  static const String _pngInBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==';

  @override
  Future<DataState<ArticleThumbnailEntity?>> pickThumbnailFromGallery() async {
    return DataSuccess(ArticleThumbnailEntity(bytes: base64Decode(_pngInBase64), fileExtension: 'png'));
  }
}

/// User journey "publish an article", with the real cubit and use cases and fake repositories.
void main() {
  Object? closedWith;

  Future<void> openPublishArticleScreen(WidgetTester tester) async {
    closedWith = null;
    // Screen of the Pixel 8 used as Android emulator (412 x 914 logical pixels).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    // Like the home screen, the screen that opens the form stays below it, so the toast is shown over it.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => closedWith = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => PublishArticleCubit(
                    PublishArticleUseCase(FakeJournalistArticleRepository()),
                    PickArticleThumbnailUseCase(FakeArticleThumbnailRepository()),
                  ),
                  child: const PublishArticleScreen(),
                ),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  /// Fields are found by their hint, shown inside them while they are empty.
  Future<void> fillIn(WidgetTester tester, String hint, String text) async {
    final field = find.widgetWithText(TextField, hint);
    // The form is a lazy list: fields below the screen are only built after scrolling to them.
    await tester.scrollUntilVisible(field, 100,
        scrollable: find.byType(Scrollable).first);
    await tester.enterText(field, text);
  }

  testWidgets('does not show errors before trying to publish', (tester) async {
    await openPublishArticleScreen(tester);

    expect(find.text('This field is required'), findsNothing);
  });

  testWidgets('shows what is missing when publishing an empty article',
      (tester) async {
    await openPublishArticleScreen(tester);

    await tester.tap(find.text('Publish Article').last);
    await tester.pumpAndSettle();

    expect(find.text('This field is required'), findsNWidgets(3));
    expect(find.text('Attach a thumbnail for the article'), findsOneWidget);
    expect(closedWith, isNull);
  });

  testWidgets('shows the preview of the attached image', (tester) async {
    await openPublishArticleScreen(tester);

    await tester.tap(find.text('Attach Image'));
    await tester.pumpAndSettle();

    expect(find.text('Attach Image'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Change image'), findsOneWidget);
  });

  testWidgets('publishes a complete article, tells the journalist and closes',
      (tester) async {
    await openPublishArticleScreen(tester);

    await fillIn(tester, 'Write your title here…', 'Local startup brings clean water');
    await tester.tap(find.text('Attach Image'));
    await tester.pumpAndSettle();
    await fillIn(tester, 'A short summary for the article list', 'A low-cost filter for rural towns.');
    await fillIn(tester, 'Add article here…', 'When the first prototype was installed...');
    await tester.tap(find.text('Publish Article').last);
    await tester.pumpAndSettle();

    expect(find.text('Article published'), findsOneWidget);
    expect(closedWith, isA<JournalistArticleEntity>());
    final article = closedWith! as JournalistArticleEntity;
    expect(article.title, 'Local startup brings clean water');
    expect(article.author, 'Jane Doe');
    // The toast closes by itself after a few seconds.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
