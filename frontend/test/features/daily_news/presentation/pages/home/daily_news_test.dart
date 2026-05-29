import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/search/search_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/search/search_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/search/search_articles_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/empty_state_widget.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/skeleton_article_tile.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../helpers/test_fixtures.dart';

// ---------------------------------------------------------------------------
// Fake BLoCs — stubs that don't require real use cases
// ---------------------------------------------------------------------------
class FakeFeedBloc extends Fake implements FeedBloc {
  FakeFeedBloc(this._state);

  FeedState _state;
  final _controller = StreamController<FeedState>.broadcast();

  @override
  FeedState get state => _state;

  @override
  Stream<FeedState> get stream => _controller.stream;

  @override
  void emit(FeedState s) {
    _state = s;
    _controller.add(s);
  }

  @override
  void add(FeedEvent event) {}

  @override
  Future<void> close() async => _controller.close();

  @override
  bool get isClosed => _controller.isClosed;
}

class FakeAuthBloc extends Fake implements AuthBloc {
  FakeAuthBloc(this._state);

  final AuthState _state;
  final _controller = StreamController<AuthState>.broadcast();

  @override
  AuthState get state => _state;

  @override
  Stream<AuthState> get stream => _controller.stream;

  @override
  void add(AuthEvent event) {}

  @override
  Future<void> close() async => _controller.close();

  @override
  bool get isClosed => _controller.isClosed;
}

class FakeSearchArticlesBloc extends Fake implements SearchArticlesBloc {
  final _controller = StreamController<SearchArticlesState>.broadcast();

  @override
  SearchArticlesState get state => const SearchArticlesDone([]);

  @override
  Stream<SearchArticlesState> get stream => _controller.stream;

  @override
  void add(SearchArticlesEvent event) {}

  @override
  Future<void> close() async => _controller.close();

  @override
  bool get isClosed => _controller.isClosed;
}

class FakeLocalArticleBloc extends Fake implements LocalArticleBloc {
  final _controller = StreamController<LocalArticlesState>.broadcast();

  @override
  LocalArticlesState get state => const LocalArticlesDone([]);

  @override
  Stream<LocalArticlesState> get stream => _controller.stream;

  @override
  void add(LocalArticlesEvent event) {}

  @override
  Future<void> close() async => _controller.close();

  @override
  bool get isClosed => _controller.isClosed;
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------
Widget _wrap({
  required FeedBloc feedBloc,
  required AuthBloc authBloc,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<FeedBloc>.value(value: feedBloc),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: const DailyNews(),
    ),
  );
}

void main() {
  final sl = GetIt.instance;

  late FakeAuthBloc authBloc;

  setUp(() {
    authBloc = FakeAuthBloc(AuthAuthenticated(testAuthUser()));

    // Register blocs that child tabs fetch from GetIt
    sl.registerFactory<SearchArticlesBloc>(() => FakeSearchArticlesBloc());
    sl.registerFactory<LocalArticleBloc>(() => FakeLocalArticleBloc());
  });

  tearDown(() async {
    sl.reset();
  });

  group('DailyNews — Feed Tab', () {
    testWidgets('shows skeleton loading state', (tester) async {
      final feedBloc = FakeFeedBloc(const FeedLoading());

      await tester.pumpWidget(_wrap(feedBloc: feedBloc, authBloc: authBloc));
      await tester.pump();

      expect(find.byType(SkeletonArticleTile), findsWidgets);
    });

    testWidgets('shows articles when FeedDone with data', (tester) async {
      final articles = testArticleList(count: 3);
      final feedBloc = FakeFeedBloc(FeedDone(articles));

      await tester.pumpWidget(_wrap(feedBloc: feedBloc, authBloc: authBloc));
      await tester.pump();

      expect(find.text('Article 0'), findsOneWidget);
      expect(find.text('Article 1'), findsOneWidget);
      expect(find.text('Article 2'), findsOneWidget);
    });

    testWidgets('shows empty state when FeedDone with no articles',
        (tester) async {
      final feedBloc = FakeFeedBloc(const FeedDone([]));

      await tester.pumpWidget(_wrap(feedBloc: feedBloc, authBloc: authBloc));
      await tester.pump();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('shows error state on FeedFailure', (tester) async {
      const error = NetworkException(message: 'No internet', code: 'offline');
      final feedBloc = FakeFeedBloc(const FeedFailure(error));

      await tester.pumpWidget(_wrap(feedBloc: feedBloc, authBloc: authBloc));
      await tester.pump();

      expect(find.text('No internet'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });

    testWidgets('has FAB for creating articles', (tester) async {
      final feedBloc = FakeFeedBloc(const FeedLoading());

      await tester.pumpWidget(_wrap(feedBloc: feedBloc, authBloc: authBloc));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('DailyNews — Bottom Navigation', () {
    testWidgets('has 4 navigation tabs', (tester) async {
      final feedBloc = FakeFeedBloc(const FeedLoading());

      await tester.pumpWidget(_wrap(feedBloc: feedBloc, authBloc: authBloc));
      await tester.pump();

      // Active icon (home tab is active by default)
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });
}
