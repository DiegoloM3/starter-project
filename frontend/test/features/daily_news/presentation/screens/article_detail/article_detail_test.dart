import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/article_detail/article_detail.dart';

import '../../../../../helpers/fake_article_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeArticleRepository repository;
  late LocalArticleBloc bloc;

  final article = newsArticle(title: 'Retro Vinyl Returns');

  setUp(() {
    repository = FakeArticleRepository();
  });

  tearDown(() => bloc.close());

  // The bloc is built here rather than in setUp: see the note in
  // saved_article_test.dart — one built in setUp runs against the real clock
  // and never advances under `tester.pump()`.
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
          child: ArticleDetailsView(article: article),
        ),
      ),
    );

    bloc.add(const GetSavedArticles());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('offers to save an article that is not saved yet',
      (tester) async {
    await pumpScreen(tester);

    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
  });

  testWidgets('comes back as saved for an article already in the list',
      (tester) async {
    // The stored copy carries the id the database gave it; the one on screen
    // came from the API and has none. The button must still say Saved.
    repository.savedArticles.add(newsArticle(title: 'Retro Vinyl Returns'));

    await pumpScreen(tester);

    expect(find.widgetWithText(FilledButton, 'Saved'), findsOneWidget);
  });

  testWidgets('saving once cannot save twice', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.widgetWithText(FilledButton, 'Saved'), findsOneWidget);
    expect(repository.savedArticles, hasLength(1));

    // Tapping again takes it back out instead of storing a second copy.
    await tester.tap(find.widgetWithText(FilledButton, 'Saved'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repository.savedArticles, isEmpty);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
  });
}
