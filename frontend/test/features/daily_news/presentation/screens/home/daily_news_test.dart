import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/news_article_card.dart';

import '../../../../../helpers/fake_article_repository.dart';
import '../../../../../helpers/localized_app.dart';

void main() {
  late FakeArticleRepository repository;
  late RemoteArticlesBloc bloc;

  setUp(() {
    repository = FakeArticleRepository();
  });

  tearDown(() => bloc.close());

  /// Builds the screen and its bloc.
  ///
  /// The bloc is created **here and not in `setUp`**: `setUp` runs outside the
  /// fake clock `testWidgets` installs, so a bloc built there answers its
  /// events against the real clock and `tester.pump()` never advances it.
  ///
  /// [themeMode] is a parameter because one of these tests is about what
  /// happens when the device changes it while the screen is on show.
  Future<void> pumpScreen(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    bloc = RemoteArticlesBloc(GetArticlesUseCase(repository));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme(),
        darkTheme: darkTheme(),
        themeMode: themeMode,
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<RemoteArticlesBloc>.value(
          value: bloc,
          child: const DailyNews(),
        ),
      ),
    );
    bloc.add(const GetArticles());
    // pump, not pumpAndSettle: the cards hold image widgets that never reach
    // a settled state in a test environment.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// The colour the reader actually sees on a chip's label, after the theme,
  /// the chip's defaults and the widget's own style have all had their say.
  Color? labelColorOf(WidgetTester tester, String label) {
    final element = tester.element(find.text(label));
    final text = element.widget as Text;

    return DefaultTextStyle.of(element).style.merge(text.style).color;
  }

  testWidgets('offers every section of the paper', (tester) async {
    await pumpScreen(tester);

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Business'), findsOneWidget);

    // The filter scrolls sideways, so the last sections are off screen until
    // the reader drags it. They have to be reachable, not merely declared.
    await tester.scrollUntilVisible(
      find.text('Entertainment'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Entertainment'), findsOneWidget);
  });

  testWidgets('gives the first headline the lead treatment', (tester) async {
    repository.newsArticlesResult = DataSuccess([
      newsArticle(title: 'Harbour Reopens After Nine Months'),
      newsArticle(title: 'City Council Approves Transit Plan'),
    ]);

    await pumpScreen(tester);

    expect(find.byType(LeadArticleCard), findsOneWidget);
    expect(find.byType(CompactArticleCard), findsOneWidget);
    expect(find.text('Harbour Reopens After Nine Months'), findsOneWidget);
  });

  testWidgets('tapping a section asks the api for it', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Sports'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(repository.lastRequestedCategory, NewsCategory.sports);
  });

  testWidgets('says so when a section has no headlines', (tester) async {
    await pumpScreen(tester);

    expect(find.text('No news right now'), findsOneWidget);
    // The filter stays on show, so the reader can leave an empty section.
    expect(find.byType(ChoiceChip), findsWidgets);
  });

  testWidgets('offers a retry when the news cannot be loaded', (tester) async {
    repository.newsArticlesResult = DataFailed(Exception('offline'));

    await pumpScreen(tester);
    expect(find.text('We could not load the news.'), findsOneWidget);

    repository.newsArticlesResult = DataSuccess([
      newsArticle(title: 'Harbour Reopens After Nine Months'),
    ]);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Harbour Reopens After Nine Months'), findsOneWidget);
  });

  /// Regression: the section labels used to vanish when the device was
  /// flipped to dark mode with the feed already open.
  ///
  /// The cause was where the theme was read from. `ListView.itemBuilder` is
  /// handed the sliver's context, not the item's, so the `Theme.of` call that
  /// coloured these labels resolved against a context the list does not
  /// rebuild on a theme change: the chips were repainted dark while their
  /// labels kept the light theme's near black, which is invisible on them.
  testWidgets('section labels follow a theme change', (tester) async {
    await pumpScreen(tester, themeMode: ThemeMode.light);
    expect(labelColorOf(tester, 'Business'), AppColors.lightText);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme(),
        darkTheme: darkTheme(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: BlocProvider<RemoteArticlesBloc>.value(
          value: bloc,
          child: const DailyNews(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(labelColorOf(tester, 'Business'), AppColors.darkText);
  });
}
