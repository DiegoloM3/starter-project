import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home/daily_news.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

class MockWatchDraftsUseCase extends Mock implements WatchDraftsUseCase {
  @override
  Stream<List<DraftArticleEntity>> call({dynamic params}) =>
      const Stream.empty();
}

class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

const _anonUser = AuthUserEntity(
  uid: 'anon-1',
  providerId: 'anonymous',
  isAnonymous: true,
);

const _authUser = AuthUserEntity(
  uid: 'user-1',
  email: 'test@example.com',
  displayName: 'Test User',
  providerId: 'password',
  isAnonymous: false,
);

Widget _buildPage({
  required MockFeedBloc feedBloc,
  required MockRemoteArticlesBloc remoteBloc,
  required MockAuthBloc authBloc,
  String initialLocation = '/',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const DailyNews(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('LoginPage')),
        ),
      ),
      GoRoute(
        path: '/article/upload',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('ArticleUploadPage')),
        ),
      ),
      GoRoute(
        path: '/saved',
        builder: (_, __) => const Scaffold(body: Center(child: Text('Saved'))),
      ),
      GoRoute(
        path: '/article/:id',
        builder: (_, __) => const Scaffold(),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<RemoteArticlesBloc>.value(value: remoteBloc),
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<FeedBloc>.value(value: feedBloc),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  late MockFeedBloc feedBloc;
  late MockRemoteArticlesBloc remoteBloc;
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const LoadFeedEvent());
    registerFallbackValue(const FilterChangedEvent(FeedFilter.all));
    registerFallbackValue(SignOutEvent());
  });

  setUp(() {
    feedBloc = MockFeedBloc();
    remoteBloc = MockRemoteArticlesBloc();
    authBloc = MockAuthBloc();
    when(() => feedBloc.state).thenReturn(const FeedState());
    when(() => remoteBloc.state).thenReturn(const RemoteArticlesLoading());
    when(() => authBloc.state).thenReturn(const AuthAnonymous(_anonUser));
    if (sl.isRegistered<WatchDraftsUseCase>()) {
      sl.unregister<WatchDraftsUseCase>();
    }
    sl.registerLazySingleton<WatchDraftsUseCase>(() => MockWatchDraftsUseCase());
  });

  tearDown(() {
    feedBloc.close();
    remoteBloc.close();
    authBloc.close();
    if (sl.isRegistered<WatchDraftsUseCase>()) {
      sl.unregister<WatchDraftsUseCase>();
    }
  });

  group('DailyNews — FAB anonymous redirect', () {
    testWidgets('anonymous user tapping FAB navigates to /login', (tester) async {
      when(() => authBloc.state).thenReturn(const AuthAnonymous(_anonUser));
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesDone([]));
      when(() => feedBloc.state).thenReturn(const FeedState(isLoading: false));

      await tester.pumpWidget(_buildPage(
        feedBloc: feedBloc,
        remoteBloc: remoteBloc,
        authBloc: authBloc,
      ));
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsOneWidget);
    });

    testWidgets('authenticated user tapping FAB navigates to /article/upload',
        (tester) async {
      when(() => authBloc.state).thenReturn(const AuthAuthenticated(_authUser));
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesDone([]));
      when(() => feedBloc.state).thenReturn(const FeedState(isLoading: false));

      await tester.pumpWidget(_buildPage(
        feedBloc: feedBloc,
        remoteBloc: remoteBloc,
        authBloc: authBloc,
      ));
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('ArticleUploadPage'), findsOneWidget);
    });
  });

  group('DailyNews — FilterChips', () {
    testWidgets('tapping News chip dispatches FilterChangedEvent(news)',
        (tester) async {
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesDone([]));
      when(() => feedBloc.state).thenReturn(const FeedState(isLoading: false));

      await tester.pumpWidget(_buildPage(
        feedBloc: feedBloc,
        remoteBloc: remoteBloc,
        authBloc: authBloc,
      ));
      await tester.pump();

      await tester.tap(find.text('News'));
      await tester.pump();

      verify(() => feedBloc.add(const FilterChangedEvent(FeedFilter.news)))
          .called(1);
    });
  });
}
