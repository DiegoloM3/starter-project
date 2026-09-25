import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_page.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/latest_ticker.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/connectivity/domain/repository/connectivity_repository.dart';
import 'package:news_app_clean_architecture/shared/connectivity/domain/usecases/watch_connectivity_usecase.dart';
import 'package:news_app_clean_architecture/shared/connectivity/presentation/bloc/connectivity_cubit.dart';

/// Thirty stories without photos, so nothing reaches the network.
class _ManyStories implements GetArticleUseCase {
  final DateTime? savedAt;

  _ManyStories({this.savedAt});

  @override
  Future<DataState<NewsPage>> call({NewsQuery? params}) async {
    return DataSuccess(NewsPage(
      articles: [
        for (var i = 0; i < 30; i++)
          ArticleEntity(url: 'u$i', title: 'Story $i', author: 'Author'),
      ],
      hasMore: false,
      savedAt: savedAt,
    ));
  }
}

/// Answers a category on demand, so a test can inspect the screen while
/// one is still loading -- the exact moment Jano's report happened at:
/// switching to a category with nothing cached for it yet.
class _OnDemandStories implements GetArticleUseCase {
  final _pending = <NewsCategory, Completer<DataState<NewsPage>>>{};

  Future<void> resolve(
      NewsCategory category, List<ArticleEntity> articles) async {
    _pending[category]!.complete(
      DataSuccess(NewsPage(articles: articles, hasMore: false)),
    );
  }

  @override
  Future<DataState<NewsPage>> call({NewsQuery? params}) {
    final completer = Completer<DataState<NewsPage>>();
    _pending[params!.category] = completer;
    return completer.future;
  }
}

class _NoSavedArticles implements ArticleRepository {
  @override
  Future<List<ArticleEntity>> getSavedArticles() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Signal extends ChangeNotifier {
  void fire() => notifyListeners();
}

/// A connectivity signal a test can drive by hand, instead of the real
/// plugin -- silent (no events at all) until a test calls [goOffline] or
/// [goOnline].
class _FakeConnectivityRepository implements ConnectivityRepository {
  final _controller = StreamController<bool>.broadcast();

  void goOffline() => _controller.add(false);
  void goOnline() => _controller.add(true);
  void dispose() => _controller.close();

  @override
  Stream<bool> watch() => _controller.stream;
}

/// Never emits, so every test that isn't specifically about connectivity
/// sees the app exactly as if it were always online.
ConnectivityCubit _onlineConnectivity() {
  final cubit = ConnectivityCubit(
    WatchConnectivityUseCase(_FakeConnectivityRepository()),
  );
  addTearDown(cubit.close);
  return cubit;
}

Future<void> _pumpNews(
  WidgetTester tester,
  _Signal signal, {
  DateTime? savedAt,
  ConnectivityCubit? connectivity,
}) async {
  final saved = _NoSavedArticles();
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RemoteArticlesBloc(_ManyStories(savedAt: savedAt))
            ..add(const GetArticles()),
        ),
        BlocProvider(
          create: (_) => LocalArticleBloc(
            GetSavedArticleUseCase(saved),
            SaveArticleUseCase(saved),
            RemoveArticleUseCase(saved),
          ),
        ),
        BlocProvider<ConnectivityCubit>.value(
          value: connectivity ?? _onlineConnectivity(),
        ),
      ],
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: DailyNews(scrollToTop: signal),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<ScrollPosition> _pumpScrolledDown(
  WidgetTester tester,
  _Signal signal,
) async {
  await _pumpNews(tester, signal);
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
  await tester.pumpAndSettle();
  final position =
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  expect(position.pixels, greaterThan(0));
  return position;
}

void main() {
  testWidgets('tapping "Daily News" scrolls back to the top', (tester) async {
    final signal = _Signal();
    addTearDown(signal.dispose);
    final position = await _pumpScrolledDown(tester, signal);

    await tester.tap(find.text('Daily News', findRichText: true));
    await tester.pumpAndSettle();

    expect(position.pixels, 0);
  });

  testWidgets('tapping the News tab again scrolls back to the top',
      (tester) async {
    final signal = _Signal();
    addTearDown(signal.dispose);
    final position = await _pumpScrolledDown(tester, signal);

    signal.fire();
    await tester.pumpAndSettle();

    expect(position.pixels, 0);
  });

  testWidgets('offline, says the stories are the saved copy', (tester) async {
    final signal = _Signal();
    addTearDown(signal.dispose);

    await _pumpNews(tester, signal, savedAt: DateTime.now());

    expect(find.textContaining('Offline'), findsOneWidget);
    expect(find.text("You're all caught up"), findsNothing);
  });

  testWidgets(
      'switching to a category with nothing cached yet never throws, '
      'and the strip at the top settles in the same way once it loads',
      (tester) async {
    final signal = _Signal();
    addTearDown(signal.dispose);
    final useCase = _OnDemandStories();
    final saved = _NoSavedArticles();
    late final RemoteArticlesBloc bloc;
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              bloc = RemoteArticlesBloc(useCase)..add(const GetArticles());
              return bloc;
            },
          ),
          BlocProvider(
            create: (_) => LocalArticleBloc(
              GetSavedArticleUseCase(saved),
              SaveArticleUseCase(saved),
              RemoveArticleUseCase(saved),
            ),
          ),
          BlocProvider<ConnectivityCubit>.value(value: _onlineConnectivity()),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: DailyNews(scrollToTop: signal),
        ),
      ),
    );
    await useCase.resolve(NewsCategory.top, [const ArticleEntity(url: 'a')]);
    await tester.pumpAndSettle();

    // Switching to Sports: nothing cached for it, so this pumps a frame
    // where the bloc is loading -- with no ticker text on screen yet.
    bloc.add(const GetArticles(category: NewsCategory.sports));
    // Two pumps: one for the bloc's stream to pick up the event, one for
    // its synchronous `emit(RemoteArticlesLoading(...))` to reach the build.
    await tester.pump();
    await tester.pump();
    // The strip crossfades rather than swapping instantly -- Top's ticker
    // is still fading out at this exact instant, so give the transition
    // its full 250ms before checking what settled in its place.
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(LatestTicker), findsNothing);
    // The mechanism this regression test actually guards: without it, the
    // strip's own appearance/disappearance is a plain `if`, and only
    // whichever category happened to already be cached looked stable.
    expect(find.byType(AnimatedSize), findsAtLeastNWidgets(2));

    await useCase.resolve(
        NewsCategory.sports, [const ArticleEntity(url: 'b', title: 'Score')]);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LatestTicker), findsOneWidget);
  });

  testWidgets(
      'losing the connection mid-read shows the offline banner, without '
      'waiting for a new fetch',
      (tester) async {
    final signal = _Signal();
    addTearDown(signal.dispose);
    final connectivityRepo = _FakeConnectivityRepository();
    addTearDown(connectivityRepo.dispose);
    final connectivityCubit =
        ConnectivityCubit(WatchConnectivityUseCase(connectivityRepo));
    addTearDown(connectivityCubit.close);

    await _pumpNews(tester, signal, connectivity: connectivityCubit);
    expect(find.textContaining('Offline'), findsNothing);

    // Nothing re-fetched the section -- the radio just dropped while the
    // reader was already looking at it.
    connectivityRepo.goOffline();
    await tester.pumpAndSettle();

    expect(find.textContaining('Offline'), findsOneWidget);

    connectivityRepo.goOnline();
    await tester.pumpAndSettle();

    expect(find.textContaining('Offline'), findsNothing);
  });
}
