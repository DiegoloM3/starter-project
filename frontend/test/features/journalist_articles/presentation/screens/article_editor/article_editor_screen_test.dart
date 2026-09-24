import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_article_by_id.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_article_cover.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/publish_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/update_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/upload_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/article_editor/article_editor_screen.dart';

import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';

import '../../../../../helpers/article_fixtures.dart';
import '../../../../../helpers/fake_article_thumbnail_repository.dart';
import '../../../../../helpers/fake_cover_image_picker_repository.dart';
import '../../../../../helpers/fake_journalist_article_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeJournalistArticleRepository articleRepository;
  late FakeArticleThumbnailRepository thumbnailRepository;
  late FakeCoverImagePickerRepository pickerRepository;
  late ArticleEditorCubit cubit;

  setUp(() {
    articleRepository = FakeJournalistArticleRepository();
    thumbnailRepository = FakeArticleThumbnailRepository();
    pickerRepository = FakeCoverImagePickerRepository();
    cubit = ArticleEditorCubit(
      GetArticleByIdUseCase(articleRepository),
      CreateArticleUseCase(articleRepository),
      UpdateArticleUseCase(articleRepository),
      PublishArticleUseCase(articleRepository),
      UploadArticleThumbnailUseCase(thumbnailRepository),
      PickArticleCoverUseCase(pickerRepository),
      journalistId: 'journalist-1',
      journalistName: 'Alex Rivera',
    );
  });

  tearDown(() => cubit.close());

  /// Opens the editor on a new article, or on [articleId] when one is named.
  Future<void> pumpScreen(WidgetTester tester, {String? articleId}) async {
    if (articleId == null) {
      cubit.startNewArticle();
    } else {
      await cubit.loadArticle(articleId);
    }

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<ArticleEditorCubit>.value(
          value: cubit,
          child: const ArticleEditorScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('offers an empty form for a new article', (tester) async {
    await pumpScreen(tester);

    expect(find.text('New article'), findsOneWidget);
    // An invitation to add a cover, not a report that there is none.
    expect(find.text('Add cover image'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Publish'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Save changes'), findsOneWidget);
  });

  testWidgets('keeps what the journalist types in the editor state',
      (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'Working title');

    expect(cubit.state.article.title, 'Working title');

    // Every edit schedules an autosave (see ArticleEditorCubit._scheduleAutosave);
    // let it fire so no Timer is left pending once the test tears down.
    await tester.pump(cubit.autosaveDelay);
  });

  testWidgets('stays open when the article autosaves', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, 'Working title');
    await tester.pump(cubit.autosaveDelay);
    await tester.pump();

    // The editor must survive an autosave: popping here is what used to throw
    // the journalist out of the article every couple of seconds.
    expect(find.byType(ArticleEditorScreen), findsOneWidget);
    expect(find.textContaining('Draft saved'), findsOneWidget);
    expect(articleRepository.createCallCount, 1);
  });

  testWidgets('explains why an empty article cannot be published',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Publish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // One message, above the form where it can be read, and no snack bar
    // saying the same thing at the same time in a different place.
    expect(find.textContaining('The article needs a title.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(articleRepository.createCallCount, 0);
  });

  testWidgets('the failure stays until it is dealt with', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Publish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Well past a snack bar's life. The message used to be gone by now, and
    // the form that caused it looked untouched.
    await tester.pump(const Duration(seconds: 10));

    expect(find.byType(AlertBanner), findsOneWidget);
  });

  /// Publishing is not something that can be done twice. "Save changes"
  /// already stores an edit and leaves the article public; a second button
  /// beside it only sent the journalist back through the "published!" screen
  /// for nothing.
  testWidgets('offers no Publish button on an article already published',
      (tester) async {
    articleRepository.articleByIdResult = DataSuccess(
      publishableArticle(status: ArticleStatus.published),
    );

    await pumpScreen(tester, articleId: 'article-1');

    expect(find.widgetWithText(FilledButton, 'Publish'), findsNothing);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('still offers Publish on a draft', (tester) async {
    await pumpScreen(tester);

    expect(find.widgetWithText(FilledButton, 'Publish'), findsOneWidget);
  });

  testWidgets('swaps the invitation for the cover once one is attached',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Add cover image'));
    await tester.pump();
    await tester.pump();

    // The empty state is gone and the two things you can do to a cover are
    // offered in its place.
    expect(find.text('Add cover image'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Replace'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Remove'), findsOneWidget);
  });

  testWidgets('removing the cover brings the invitation back', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Add cover image'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pump();

    expect(find.text('Add cover image'), findsOneWidget);
    expect(cubit.state.article.thumbnailUrl, isEmpty);
  });

  testWidgets('attaches a cover image through the upload use case',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Add cover image'));
    await tester.pump();
    await tester.pump();

    expect(thumbnailRepository.uploadCallCount, 1);
    expect(cubit.state.article.thumbnailUrl, isNotEmpty);
  });

  testWidgets(
      'paints its own background, so a pushed route is not a black void',
      (tester) async {
    await pumpScreen(tester);

    // This screen is opened by pushing a route, where its Scaffold is the
    // only surface there is. A transparent one shows the void behind the
    // route the moment the page transition finishes.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, isNot(Colors.transparent));
  });

  group('leaving with unsaved work', () {
    /// Puts the editor on a route that can actually be popped, so the guard
    /// has something to block.
    Future<void> pumpPushedEditor(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationDelegates,
          supportedLocales: testSupportedLocales,
          home: BlocProvider<ArticleEditorCubit>.value(
            value: cubit,
            child: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider<ArticleEditorCubit>.value(
                        value: cubit,
                        child: const ArticleEditorScreen(),
                      ),
                    ),
                  ),
                  child: const Text('Open editor'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
    }

    testWidgets('leaves quietly when nothing would be lost', (tester) async {
      await pumpPushedEditor(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleEditorScreen), findsNothing);
    });

    testWidgets('warns when there is writing that was never saved',
        (tester) async {
      await pumpPushedEditor(tester);
      // Content but no title: exactly what autosave does not cover.
      await tester.enterText(find.byType(TextField).last, 'The depot opens');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Your changes are not saved'), findsOneWidget);
      expect(find.byType(ArticleEditorScreen), findsOneWidget);
    });

    testWidgets('keep writing puts them back on the article', (tester) async {
      await pumpPushedEditor(tester);
      await tester.enterText(find.byType(TextField).last, 'The depot opens');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Keep writing'));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleEditorScreen), findsOneWidget);
      expect(articleRepository.createCallCount, 0);
    });

    testWidgets('discard leaves without saving', (tester) async {
      await pumpPushedEditor(tester);
      await tester.enterText(find.byType(TextField).last, 'The depot opens');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleEditorScreen), findsNothing);
      expect(articleRepository.createCallCount, 0);
    });

    testWidgets('offers only the two answers to the question asked',
        (tester) async {
      await pumpPushedEditor(tester);
      await tester.enterText(find.byType(TextField).last, 'The depot opens');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Saving belongs to the button on the screen behind, not to this
      // dialog: a third action turns a question into a menu.
      expect(find.widgetWithText(FilledButton, 'Keep writing'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Discard'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Save'), findsNothing);
    });
  });
}
