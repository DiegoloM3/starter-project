import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/config/routes/paths.dart';
import 'package:news_app_clean_architecture/core/errors/network_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_en.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/login/presentation/bloc/login_bloc.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:go_router/go_router.dart';

import 'package:network_image_mock/network_image_mock.dart';

class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

class MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class MockLocalArticleBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

class MockUserEntity extends Mock implements UserEntity {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockRemoteArticlesBloc mockBloc;
  late MockLoginBloc mockLoginBloc;
  late MockLocalArticleBloc mockLocalBloc;
  late GetIt getIt;

  setUpAll(() {
    registerFallbackValue(const GetArticles());
    registerFallbackValue(SignOutRequested());
    registerFallbackValue(const LocalArticlesLoading());
  });

  setUp(() {
    mockBloc = MockRemoteArticlesBloc();
    mockLoginBloc = MockLoginBloc();
    mockLocalBloc = MockLocalArticleBloc();
    getIt = GetIt.instance;
    if (getIt.isRegistered<RemoteArticlesBloc>()) {
      getIt.unregister<RemoteArticlesBloc>();
    }
    getIt.registerSingleton<RemoteArticlesBloc>(mockBloc);
    if (getIt.isRegistered<LocalArticleBloc>()) {
      getIt.unregister<LocalArticleBloc>();
    }
    getIt.registerSingleton<LocalArticleBloc>(mockLocalBloc);
    when(() => mockLocalBloc.state).thenReturn(const LocalArticlesLoading());
  });

  tearDown(() {
    if (getIt.isRegistered<RemoteArticlesBloc>()) {
      getIt.unregister<RemoteArticlesBloc>();
    }
    if (getIt.isRegistered<LocalArticleBloc>()) {
      getIt.unregister<LocalArticleBloc>();
    }
  });

  makeTestableWidget(Widget body, {GoRouter? router}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>.value(value: mockBloc),
        BlocProvider<LoginBloc>.value(value: mockLoginBloc),
        BlocProvider<LocalArticleBloc>.value(value: mockLocalBloc),
      ],
      child: router != null
          ? MaterialApp.router(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            )
          : MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: body,
            ),
    );
  }

  group('Daily News Widget Tests', () {
    testWidgets(
        'Should display loading indicator when state is RemoteArticlesLoading',
        (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const RemoteArticlesLoading());

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('Should display ArticlesList when state is RemoteArticlesDone',
        (WidgetTester tester) async {
      when(() => mockBloc.state)
          .thenReturn(const RemoteArticlesDone(articles: []));

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets(
        'Should display no articles found when state is RemoteArticleEmpty',
        (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const RemoteArticleEmpty());

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      expect(find.text(AppLocalizationsEn().no_articles_found), findsOneWidget);
    });

    testWidgets('Should display refresh icon when state is RemoteArticlesError',
        (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(
        const RemoteArticlesError(
          NetworkNotFoundException(),
        ),
      );

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Should trigger GetArticles event on pull-to-refresh gesture',
        (WidgetTester tester) async {
      when(() => mockBloc.state)
          .thenReturn(const RemoteArticlesDone(articles: []));

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      clearInteractions(mockBloc);

      await tester.fling(
          find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(const GetArticles())).called(1);
    });

    testWidgets('Should trigger SignOutRequested when logout icon is pressed',
        (WidgetTester tester) async {
      when(() => mockBloc.state)
          .thenReturn(const RemoteArticlesDone(articles: []));

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      final logoutIcon = find.byIcon(Icons.logout);
      expect(logoutIcon, findsOneWidget);
      await tester.tap(logoutIcon);

      verify(() => mockLoginBloc.add(SignOutRequested())).called(1);
    });

    testWidgets('Should trigger NextPage event when scrolled near the bottom',
        (WidgetTester tester) async {
      mockNetworkImagesFor(() async {
        final articles = List.generate(
          20,
          (index) => ArticleEntity(
            id: index.toString(),
            title: 'Title $index',
            author: 'Author $index',
            publishedAt: '2023-10-27T10:00:00Z',
            url: 'https://example.com/image_$index.jpg',
          ),
        );

        when(() => mockBloc.state)
            .thenReturn(RemoteArticlesDone(articles: articles));

        await tester.pumpWidget(makeTestableWidget(const DailyNews()));

        clearInteractions(mockBloc);

        await tester.scrollUntilVisible(
          find.text('Title 19'),
          500,
        );
        await tester.pump(const Duration(milliseconds: 500));

        verify(() => mockBloc.add(const NextPage())).called(greaterThan(0));
      });
    });

    testWidgets('Go to SavedArticles when bookmark icon is pressed',
        (WidgetTester tester) async {
      when(() => mockBloc.state)
          .thenReturn(const RemoteArticlesDone(articles: []));
      when(() => mockLocalBloc.state)
          .thenReturn(const LocalArticlesDone(articles: []));

      final router = GoRouter(
        initialLocation: Paths.dailyNews.path,
        routes: [
          GoRoute(
            path: Paths.dailyNews.path,
            name: Paths.dailyNews.name,
            builder: (context, state) => const DailyNews(),
            routes: [
              GoRoute(
                path: Paths.savedArticles.path,
                name: Paths.savedArticles.name,
                builder: (context, state) =>
                    const Scaffold(body: Text('Saved Articles Page')),
              ),
            ],
          ),
        ],
      );

      await tester
          .pumpWidget(makeTestableWidget(const DailyNews(), router: router));

      final bookmarkIcon = find.byIcon(Icons.bookmark);
      expect(bookmarkIcon, findsOneWidget);
      await tester.tap(bookmarkIcon);

      await tester.pumpAndSettle();

      expect(find.text('Saved Articles Page'), findsOneWidget);
    });

    testWidgets('Should show floating action button',
        (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const RemoteArticlesLoading());

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets(
        'Should NOT open modal bottom sheet when floating button is tapped and user is NOT logged in',
        (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(const RemoteArticlesLoading());
      when(() => mockLoginBloc.state).thenReturn(const NotLoggedIn());

      await tester.pumpWidget(makeTestableWidget(const DailyNews()));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(
          find.text(AppLocalizationsEn().write_your_title_here), findsNothing);
    });

    testWidgets(
        'Should close modal, show success snackbar and refresh articles when publish succeeds',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final streamController =
          StreamController<RemoteArticlesState>.broadcast();
      when(() => mockBloc.stream).thenAnswer((_) => streamController.stream);
      when(() => mockBloc.state).thenReturn(const RemoteArticlesLoading());
      when(() => mockLoginBloc.state)
          .thenReturn(LoggedIn(user: MockUserEntity()));

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DailyNews(),
          ),
        ],
      );

      await tester
          .pumpWidget(makeTestableWidget(const DailyNews(), router: router));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      clearInteractions(mockBloc);

      streamController.add(const RemoteArticlesDone(
          articles: [], status: RemoteArticleStatus.createdArticleSuccess));
      await tester.pump();

      expect(find.text(AppLocalizationsEn().published_article), findsOneWidget);
      expect(
          find.text(AppLocalizationsEn().write_your_title_here), findsNothing);

      verify(() => mockBloc.add(const GetArticles())).called(1);

      await streamController.close();
    });

    testWidgets('Should show error snackbar when publish fails',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final streamController =
          StreamController<RemoteArticlesState>.broadcast();
      when(() => mockBloc.stream).thenAnswer((_) => streamController.stream);
      when(() => mockBloc.state).thenReturn(const RemoteArticlesLoading());
      when(() => mockLoginBloc.state)
          .thenReturn(LoggedIn(user: MockUserEntity()));

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DailyNews(),
          ),
        ],
      );

      await tester
          .pumpWidget(makeTestableWidget(const DailyNews(), router: router));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      streamController.add(const RemoteArticlesDone(
          articles: [], status: RemoteArticleStatus.genericError));
      await tester.pump();

      expect(find.text(AppLocalizationsEn().generic_error), findsOneWidget);
      expect(
          find.text(AppLocalizationsEn().write_your_title_here), findsNothing);

      await streamController.close();
    });
  });
}
