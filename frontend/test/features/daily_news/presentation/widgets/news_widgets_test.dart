import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/featured_carousel.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/latest_ticker.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/story_tiles.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

class _NoSavedArticles implements ArticleRepository {
  @override
  Future<List<ArticleEntity>> getSavedArticles() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(
  Widget child, {
  double width = 412,
  double textScale = 1,
  bool reduceMotion = false,
}) {
  final repository = _NoSavedArticles();
  return BlocProvider(
    create: (_) => LocalArticleBloc(
      GetSavedArticleUseCase(repository),
      SaveArticleUseCase(repository),
      RemoveArticleUseCase(repository),
    ),
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reduceMotion,
        ),
        child: Scaffold(body: SizedBox(width: width, child: child)),
      ),
    ),
  );
}

const _longStory = ArticleEntity(
  url: 'https://example.com/a',
  title: 'A very long headline that goes on and on about the storm that hit '
      'the coast overnight and everything that happened after it',
  description: 'A summary that is also long enough to need two full lines '
      'on any phone, and then some more words after that.',
  author: 'A reporter with a rather long name',
  sourceName: 'The Very Long Name of a Newspaper',
);

void main() {
  group('Marquee', () {
    // As in the app: a ticker in a Column, where height is unbounded.
    testWidgets('lays out inside an unbounded-height column', (tester) async {
      await tester.pumpWidget(_app(
        Column(
          children: [
            LatestTicker(
              article: const ArticleEntity(
                title: 'A headline far too long to fit on one line of this '
                    'narrow phone screen, so it has to scroll sideways',
              ),
              onTap: () {},
            ),
          ],
        ),
        width: 320,
      ));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });

    testWidgets('stays still when the headline fits', (tester) async {
      await tester.pumpWidget(_app(const Marquee(text: 'Short')));

      expect(find.text('Short'), findsOneWidget);
    });

    testWidgets('scrolls a headline that does not fit', (tester) async {
      await tester.pumpWidget(_app(
        const SizedBox(
            width: 120,
            child: Marquee(text: 'A headline far too long for this space')),
      ));

      // Two copies back to back make the loop seamless.
      expect(find.text('A headline far too long for this space'),
          findsNWidgets(2));
      await tester.pump(const Duration(seconds: 1));
    });
  });

  for (final (width, scale) in [(320.0, 1.0), (412.0, 1.0), (320.0, 1.3)]) {
    testWidgets(
        'featured card fits a ${width.toInt()}dp phone at ${scale}x text',
        (tester) async {
      await tester.pumpWidget(_app(
        FeaturedCarousel(
            articles: const [_longStory], onArticlePressed: (_) {}),
        width: width,
        textScale: scale,
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }

  group('FeaturedCarousel auto-advance', () {
    const stories = [
      ArticleEntity(url: 'a', title: 'First story'),
      ArticleEntity(url: 'b', title: 'Second story'),
    ];
    double? page(WidgetTester tester) =>
        tester.widget<PageView>(find.byType(PageView)).controller!.page;

    testWidgets('moves to the next card after a few seconds', (tester) async {
      await tester.pumpWidget(_app(
        FeaturedCarousel(articles: stories, onArticlePressed: (_) {}),
      ));
      expect(page(tester), 0);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(page(tester), 1);
    });

    testWidgets('holds still when the phone asks for less motion',
        (tester) async {
      await tester.pumpWidget(_app(
        FeaturedCarousel(articles: stories, onArticlePressed: (_) {}),
        reduceMotion: true,
      ));

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(page(tester), 0);
    });
  });

  testWidgets('a story row with its photo bookmark fits a 320dp phone',
      (tester) async {
    await tester.pumpWidget(_app(
      StoryRow(article: _longStory, onTap: () {}),
      width: 320,
      textScale: 1.3,
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      "an offline story row never attempts a network image fetch",
      (tester) async {
    await tester.pumpWidget(_app(
      StoryRow(article: _longStory, onTap: () {}, isOffline: true),
    ));
    await tester.pump();

    expect(find.byType(CachedNetworkImage), findsNothing);
  });
}
