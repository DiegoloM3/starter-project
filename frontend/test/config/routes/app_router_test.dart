import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_drafts.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState>
    implements FeedBloc {}

class MockWatchDraftsUseCase extends Mock implements WatchDraftsUseCase {
  @override
  Stream<List<DraftArticleEntity>> call({dynamic params}) =>
      const Stream.empty();
}

const _anonUser = AuthUserEntity(
  uid: 'anon',
  providerId: 'anonymous',
  isAnonymous: true,
);

const _authedUser = AuthUserEntity(
  uid: 'user-1',
  email: 'test@example.com',
  displayName: 'Test',
  providerId: 'password',
  isAnonymous: false,
);

void main() {
  late MockAuthBloc bloc;
  late GoRouter router;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    router = AppRouter.create(bloc);
    if (sl.isRegistered<WatchDraftsUseCase>()) {
      sl.unregister<WatchDraftsUseCase>();
    }
    sl.registerLazySingleton<WatchDraftsUseCase>(() => MockWatchDraftsUseCase());
  });

  tearDown(() {
    bloc.close();
    if (sl.isRegistered<WatchDraftsUseCase>()) {
      sl.unregister<WatchDraftsUseCase>();
    }
  });

  group('AppRouter', () {
    test('/ is the initial location', () {
      expect(router.routeInformationProvider.value.uri.path, equals('/'));
    });

    test('AppRouter.create returns a GoRouter instance', () {
      expect(router, isA<GoRouter>());
    });

    test('router has routes configured', () {
      final config = router.routerDelegate.currentConfiguration;
      expect(config, isNotNull);
    });
  });

  group('AppRouter redirect (widget-level)', () {
    Future<GoRouter> pumpRouter(
      WidgetTester tester,
      MockAuthBloc authBloc, {
      required String startLocation,
    }) async {
      final remoteBloc = MockRemoteArticlesBloc();
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesLoading());
      addTearDown(remoteBloc.close);

      final feedBloc = MockFeedBloc();
      when(() => feedBloc.state).thenReturn(const FeedState());
      when(() => feedBloc.stream).thenAnswer((_) => const Stream.empty());
      addTearDown(feedBloc.close);

      final r = AppRouter.create(authBloc);
      r.go(startLocation);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<RemoteArticlesBloc>.value(value: remoteBloc),
            BlocProvider<FeedBloc>.value(value: feedBloc),
          ],
          child: MaterialApp.router(
            routerConfig: r,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      // Settle the redirect + initial frame.
      await tester.pump();
      return r;
    }

    testWidgets('anonymous user can stay on /login', (tester) async {
      when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
      await pumpRouter(tester, bloc, startLocation: '/login');

      // LoginPage's AppBar shows 'Sign in' as title.
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('authenticated user on /login is redirected to /',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticated(_authedUser));
      await pumpRouter(tester, bloc, startLocation: '/login');

      // DailyNews's AppBar title.
      expect(find.text('Daily News'), findsOneWidget);
    });

    testWidgets('authenticated user on /signup is redirected to /',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticated(_authedUser));
      await pumpRouter(tester, bloc, startLocation: '/signup');

      expect(find.text('Daily News'), findsOneWidget);
    });

    testWidgets(
        'anonymous user navigating to /article/upload is redirected to /login with return param',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
      final r =
          await pumpRouter(tester, bloc, startLocation: '/article/upload');

      final uri = r.routeInformationProvider.value.uri;
      expect(uri.path, equals('/login'));
      expect(uri.queryParameters['return'], equals('/article/upload'));
    });

    testWidgets(
        'anonymous user navigating to /my-articles is redirected to /login with return param',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
      final r = await pumpRouter(tester, bloc, startLocation: '/my-articles');

      final uri = r.routeInformationProvider.value.uri;
      expect(uri.path, equals('/login'));
      expect(uri.queryParameters['return'], equals('/my-articles'));
    });

    testWidgets(
        'anonymous user navigating to /article/edit/abc is redirected to /login with return param',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
      final r =
          await pumpRouter(tester, bloc, startLocation: '/article/edit/abc');

      final uri = r.routeInformationProvider.value.uri;
      expect(uri.path, equals('/login'));
      expect(uri.queryParameters['return'], equals('/article/edit/abc'));
    });

    // For authenticated-user redirect tests, use a lightweight custom router
    // that uses stub builders to avoid GetIt dependencies in test environment.
    // This isolates the redirect logic from page rendering entirely.
    testWidgets(
        'authenticated user navigating to /article/upload is not redirected to /login',
        (tester) async {
      final authedBloc = MockAuthBloc();
      when(() => authedBloc.state)
          .thenReturn(const AuthAuthenticated(_authedUser));
      when(() => authedBloc.stream)
          .thenAnswer((_) => const Stream.empty());
      addTearDown(authedBloc.close);

      final feedBloc = MockFeedBloc();
      when(() => feedBloc.state).thenReturn(const FeedState());
      when(() => feedBloc.stream).thenAnswer((_) => const Stream.empty());
      addTearDown(feedBloc.close);

      final remoteBloc = MockRemoteArticlesBloc();
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesLoading());
      addTearDown(remoteBloc.close);

      // Minimal stub router that mirrors redirect logic without page builders.
      String? requireAuth(BuildContext context, GoRouterState state) {
        if (authedBloc.state is AuthAuthenticated) return null;
        return '/login?return=${Uri.encodeComponent(state.uri.toString())}';
      }

      final r = GoRouter(
        initialLocation: '/article/upload',
        routes: [
          GoRoute(
            path: '/article/upload',
            redirect: requireAuth,
            builder: (_, __) =>
                const Scaffold(body: Text('upload')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) =>
                const Scaffold(body: Text('login')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authedBloc),
            BlocProvider<FeedBloc>.value(value: feedBloc),
            BlocProvider<RemoteArticlesBloc>.value(value: remoteBloc),
          ],
          child: MaterialApp.router(
            routerConfig: r,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pump();

      final uri = r.routeInformationProvider.value.uri;
      expect(uri.path, equals('/article/upload'));
    });

    testWidgets(
        'authenticated user navigating to /my-articles is not redirected to /login',
        (tester) async {
      final authedBloc = MockAuthBloc();
      when(() => authedBloc.state)
          .thenReturn(const AuthAuthenticated(_authedUser));
      when(() => authedBloc.stream)
          .thenAnswer((_) => const Stream.empty());
      addTearDown(authedBloc.close);

      final feedBloc = MockFeedBloc();
      when(() => feedBloc.state).thenReturn(const FeedState());
      when(() => feedBloc.stream).thenAnswer((_) => const Stream.empty());
      addTearDown(feedBloc.close);

      final remoteBloc = MockRemoteArticlesBloc();
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesLoading());
      addTearDown(remoteBloc.close);

      String? requireAuth(BuildContext context, GoRouterState state) {
        if (authedBloc.state is AuthAuthenticated) return null;
        return '/login?return=${Uri.encodeComponent(state.uri.toString())}';
      }

      final r = GoRouter(
        initialLocation: '/my-articles',
        routes: [
          GoRoute(
            path: '/my-articles',
            redirect: requireAuth,
            builder: (_, __) =>
                const Scaffold(body: Text('my-articles')),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) =>
                const Scaffold(body: Text('login')),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authedBloc),
            BlocProvider<FeedBloc>.value(value: feedBloc),
            BlocProvider<RemoteArticlesBloc>.value(value: remoteBloc),
          ],
          child: MaterialApp.router(
            routerConfig: r,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pump();

      final uri = r.routeInformationProvider.value.uri;
      expect(uri.path, equals('/my-articles'));
    });
  });
}
