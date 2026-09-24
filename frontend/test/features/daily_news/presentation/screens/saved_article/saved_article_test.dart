import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/saved_article/saved_article.dart';

import '../../../../../helpers/fake_article_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeArticleRepository repository;
  late LocalArticleBloc bloc;

  setUp(() {
    repository = FakeArticleRepository();
  });

  tearDown(() => bloc.close());

  /// Builds the screen and its bloc.
  ///
  /// The bloc is created **here and not in `setUp`**, which matters more than
  /// it looks: `setUp` runs outside the fake clock that `testWidgets`
  /// installs, so a bloc built there processes its events against the real
  /// clock and `tester.pump()` never advances it. The screen would sit in its
  /// loading state for the whole test.
  Future<void> pumpScreen(WidgetTester tester) async {
    bloc = LocalArticleBloc(
      GetSavedArticlesUseCase(repository),
      SaveArticleUseCase(repository),
      RemoveArticleUseCase(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<LocalArticleBloc>.value(
          value: bloc,
          child: const SavedArticles(),
        ),
      ),
    );
    bloc.add(const GetSavedArticles());
    // pump, not pumpAndSettle: the cards hold image widgets that never reach
    // a settled state in a test environment, and this screen has no animation
    // worth waiting on anyway.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('lists what the reader kept', (tester) async {
    repository.savedArticles.add(newsArticle(title: 'Retro Vinyl Returns'));

    await pumpScreen(tester);

    expect(find.text('Retro Vinyl Returns'), findsOneWidget);
  });

  testWidgets('explains how to fill an empty list', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.textContaining('tap Save'), findsOneWidget);
  });

  testWidgets('removes an article and offers to put it back', (tester) async {
    repository.savedArticles.add(newsArticle(title: 'Retro Vinyl Returns'));
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repository.removeCallCount, 1);
    expect(find.text('Removed from saved.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('undo puts the article back', (tester) async {
    repository.savedArticles.add(newsArticle(title: 'Retro Vinyl Returns'));
    await pumpScreen(tester);
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pump();
    // Long enough for the snack bar to finish sliding in: tapping it
    // mid-animation lands on where it is about to be, not on where it is.
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.text('Undo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repository.saveCallCount, 1);
    expect(find.text('Retro Vinyl Returns'), findsOneWidget);
  });

  /// The offer to undo is a moment, not a fixture.
  ///
  /// It was outliving the screen it belonged to — still sitting there ten
  /// seconds later, and still there after switching tabs, offering to put
  /// back an article the reader could no longer see. The cause was not the
  /// duration: `SnackBar.persist` defaults to `action != null`, so offering
  /// Undo at all made the message permanent.
  testWidgets('the offer to undo takes itself back', (tester) async {
    repository.savedArticles.add(newsArticle(title: 'Retro Vinyl Returns'));
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Undo'), findsOneWidget);

    // Past the life it is given, plus the slide back out.
    await tester.pump(kUndoDuration);
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('removing two in a row leaves one offer, not a queue',
      (tester) async {
    repository.savedArticles
      ..add(newsArticle(
        title: 'Retro Vinyl Returns',
        url: 'https://example.com/vinyl',
      ))
      ..add(newsArticle(
        title: 'The night bus driver',
        url: 'https://example.com/night-bus',
      ));
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.bookmark).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.bookmark).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // The second removal replaces the first message rather than queueing
    // behind it, so one offer is on screen and it belongs to what just
    // happened.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(repository.removeCallCount, 2);
  });
}
