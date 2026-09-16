import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/publish_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/editor_suggestions_sheet.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/publish_success_view.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

import '../../../../helpers/feed_harness.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  Finder fieldLabelled(String label) => find.descendant(
        of: find.byWidgetPredicate((widget) => widget is LabeledTextField && widget.label == label),
        matching: find.byType(TextField),
      );

  Future<ShellHarness> pumpPublish(WidgetTester tester, {bool edit = false, ShellHarness? using}) async {
    final harness = using ?? ShellHarness();
    useScreen(tester, const Size(600, 1600));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.publish,
      routes: {
        AppRoutes.publish: (_) => PublishScreen(article: edit ? buildUserArticle(authorId: user.id) : null),
        AppRoutes.home: (_) => const Text('home'),
        AppRoutes.reader: (_) => const Text('reader'),
      },
      providers: harness.providers,
    );
    await tester.pumpAndSettle();
    return harness;
  }

  testWidgets('Publish stays disabled until title and text exist, then publishes and confirms',
      (tester) async {
    final harness = await pumpPublish(tester);
    final published = buildUserArticle(id: 'new', authorId: user.id).copyWith(title: 'Sea wall');
    when(() => harness.publishArticle(any())).thenAnswer((_) async => DataSuccess(published));

    final button = find.widgetWithText(FilledButton, 'Publish Article');
    expect(tester.widget<FilledButton>(button).enabled, isFalse);
    expect(find.text('Fill in the title and article text to publish.'), findsOneWidget);

    await tester.enterText(fieldLabelled('Title'), 'Sea wall');
    await tester.enterText(fieldLabelled('Article text'), 'A walk along the new sea wall.');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(button).enabled, isTrue);

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    final params = verify(() => harness.publishArticle(captureAny())).captured.single as PublishArticleParams;
    expect(params.draft.title, 'Sea wall');
    expect(find.byType(PublishSuccessView), findsOneWidget);
    expect(find.text('YOUR ARTICLE IS LIVE'), findsOneWidget);
    expect(harness.myArticlesCubit.state.articles, contains(published));

    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a rejected publish shows the reason and keeps the form', (tester) async {
    final harness = await pumpPublish(tester);
    when(() => harness.publishArticle(any())).thenAnswer((_) async => const DataFailed(Failure.network()));

    await tester.enterText(fieldLabelled('Title'), 'T');
    await tester.enterText(fieldLabelled('Article text'), 'B');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Publish Article'));
    await tester.tap(find.widgetWithText(FilledButton, 'Publish Article'));
    await tester.pumpAndSettle();

    expect(find.textContaining('internet connection'), findsOneWidget);
    expect(find.byType(PublishSuccessView), findsNothing);
  });

  testWidgets('editing preloads the fields, picks a photo and saves changes', (tester) async {
    final harness = await pumpPublish(tester, edit: true);
    when(() => harness.updateArticle(any()))
        .thenAnswer((_) async => DataSuccess(buildUserArticle(authorId: user.id)));

    expect(find.text('EDIT ARTICLE'), findsOneWidget);
    expect(tester.widget<TextField>(fieldLabelled('Title')).controller?.text, 'Title');

    await tester.ensureVisible(find.text('REMOVE'));
    await tester.tap(find.text('REMOVE'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add a photo'));
    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();
    verify(() => harness.pickImage(any())).called(1);

    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final params = verify(() => harness.updateArticle(captureAny())).captured.single as UpdateArticleParams;
    expect(params.newThumbnail, buildImage());
    expect(find.text('YOUR CHANGES ARE LIVE'), findsOneWidget);
    // Let the confirmation's entrance timers finish before the tree is torn down.
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('Ask the editor works with only the body and "Use this" fills the empty title', (tester) async {
    final harness = await pumpPublish(tester);

    await tester.enterText(fieldLabelled('Article text'), List.filled(45, 'word').join(' '));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ask the editor'));
    await tester.tap(find.text('Ask the editor'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorSuggestionsSheet), findsOneWidget);
    expect(find.text('Headline one'), findsOneWidget);
    verify(() => harness.suggestEdits(any())).called(1);

    await tester.tap(find.text('Use this').first);
    await tester.pumpAndSettle();

    expect(find.byType(EditorSuggestionsSheet), findsNothing);
    expect(tester.widget<TextField>(fieldLabelled('Title')).controller?.text, 'Headline one');
  });

  testWidgets('a kept draft comes back on the next visit and Clear wipes it', (tester) async {
    final harness = ShellHarness();
    when(() => harness.loadDraft(any()))
        .thenAnswer((_) async => const SavedDraft(title: 'Kept title', content: 'Kept body'));
    await pumpPublish(tester, using: harness);

    expect(tester.widget<TextField>(fieldLabelled('Title')).controller?.text, 'Kept title');
    expect(tester.widget<TextField>(fieldLabelled('Article text')).controller?.text, 'Kept body');
    expect(find.text('Your draft is back where you left it.'), findsOneWidget);

    await tester.ensureVisible(find.text('Clear draft'));
    await tester.tap(find.text('Clear draft'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(fieldLabelled('Title')).controller?.text, isEmpty);
    expect(find.text('Clear draft'), findsNothing);
    expect(find.text('Draft cleared.'), findsOneWidget);
    verify(() => harness.clearDraft(any())).called(1);
  });

  testWidgets('"Use this" on the summary fills the short description', (tester) async {
    await pumpPublish(tester);

    await tester.enterText(fieldLabelled('Article text'), List.filled(45, 'word').join(' '));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ask the editor'));
    await tester.tap(find.text('Ask the editor'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Use this').last);
    await tester.tap(find.text('Use this').last);
    await tester.pumpAndSettle();

    expect(find.byType(EditorSuggestionsSheet), findsNothing);
    expect(tester.widget<TextField>(fieldLabelled('Short description')).controller?.text, 'A short summary.');
  });

  testWidgets('Read it on the confirmation opens the new article', (tester) async {
    final harness = await pumpPublish(tester);
    when(() => harness.publishArticle(any()))
        .thenAnswer((_) async => DataSuccess(buildUserArticle(id: 'new', authorId: user.id)));

    await tester.enterText(fieldLabelled('Title'), 'T');
    await tester.enterText(fieldLabelled('Article text'), 'B');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Publish Article'));
    await tester.tap(find.widgetWithText(FilledButton, 'Publish Article'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read it'));
    await tester.pumpAndSettle();

    expect(find.text('reader'), findsOneWidget);
  });
}
