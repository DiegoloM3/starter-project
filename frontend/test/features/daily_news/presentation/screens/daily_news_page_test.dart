import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_drafts.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home/daily_news.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

// Mock BLoCs — bloc_test + mocktail pattern.
class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}

class MockWatchDraftsUseCase extends Mock implements WatchDraftsUseCase {
  @override
  Stream<List<DraftArticleEntity>> call({dynamic params}) =>
      const Stream.empty();
}

// Stub destination for /saved.
class _SavedArticlesStub extends StatelessWidget {
  const _SavedArticlesStub();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('SavedArticlesStub')));
}

// Stub destination for /login.
class _LoginStub extends StatelessWidget {
  const _LoginStub();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('LoginStub')));
}

// Minimal article with all non-nullable fields populated.
const _mockArticle = ArticleEntity(
  id: 1,
  author: 'Test Author',
  title: 'Test Article Title',
  description: 'Test article description text.',
  url: 'https://example.com/article',
  urlToImage: 'https://example.com/image.jpg',
  publishedAt: '2026-05-02',
  content: 'Full content of the test article.',
);

const _mockUser = AuthUserEntity(
  uid: 'user-1',
  email: 'test@example.com',
  displayName: 'Test User',
  photoURL: null,
  providerId: 'password',
  isAnonymous: false,
);

const _mockAnonUser = AuthUserEntity(
  uid: 'anon-1',
  email: null,
  displayName: null,
  photoURL: null,
  providerId: 'anonymous',
  isAnonymous: true,
);

Widget _buildTestWidget(
  RemoteArticlesBloc remoteBloc,
  AuthBloc authBloc, {
  FeedBloc? feedBloc,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const DailyNews()),
      GoRoute(path: '/saved', builder: (_, __) => const _SavedArticlesStub()),
      GoRoute(path: '/login', builder: (_, __) => const _LoginStub()),
      GoRoute(path: '/article/:id', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/article/upload', builder: (_, __) => const Scaffold()),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<RemoteArticlesBloc>.value(value: remoteBloc),
      BlocProvider<AuthBloc>.value(value: authBloc),
      if (feedBloc != null) BlocProvider<FeedBloc>.value(value: feedBloc),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  late MockRemoteArticlesBloc remoteBloc;
  late MockAuthBloc authBloc;
  late MockFeedBloc feedBloc;

  setUp(() {
    remoteBloc = MockRemoteArticlesBloc();
    authBloc = MockAuthBloc();
    feedBloc = MockFeedBloc();
    when(() => authBloc.state).thenReturn(const AuthAnonymous(_mockAnonUser));
    when(() => feedBloc.state).thenReturn(const FeedState());
    if (sl.isRegistered<WatchDraftsUseCase>()) {
      sl.unregister<WatchDraftsUseCase>();
    }
    sl.registerLazySingleton<WatchDraftsUseCase>(() => MockWatchDraftsUseCase());
  });

  tearDown(() {
    remoteBloc.close();
    authBloc.close();
    feedBloc.close();
    if (sl.isRegistered<WatchDraftsUseCase>()) {
      sl.unregister<WatchDraftsUseCase>();
    }
  });

  // R15 — regression coverage for DailyNews feed behaviour.
  group('DailyNews page — R15 regression', () {
    testWidgets(
        'shows CupertinoActivityIndicator when BLoC emits RemoteArticlesLoading',
        (tester) async {
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesLoading());

      await tester.pumpWidget(_buildTestWidget(remoteBloc, authBloc, feedBloc: feedBloc));
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets(
        'shows article tile when FeedBloc emits an item after RemoteArticlesDone',
        (tester) async {
      when(() => remoteBloc.state)
          .thenReturn(const RemoteArticlesDone([_mockArticle]));
      when(() => feedBloc.state).thenReturn(FeedState(
        newsArticles: [_mockArticle],
      ));

      await tester.pumpWidget(_buildTestWidget(remoteBloc, authBloc, feedBloc: feedBloc));
      await tester.pump();

      expect(find.text('Test Article Title'), findsOneWidget);
    });

    testWidgets('shows refresh icon when BLoC emits RemoteArticlesError',
        (tester) async {
      when(() => remoteBloc.state).thenReturn(
          const RemoteArticlesError(NetworkException(message: 'no network')));

      await tester.pumpWidget(_buildTestWidget(remoteBloc, authBloc, feedBloc: feedBloc));
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('tapping bookmark icon in AppBar navigates to /saved',
        (tester) async {
      when(() => remoteBloc.state)
          .thenReturn(const RemoteArticlesDone([_mockArticle]));

      await tester.pumpWidget(_buildTestWidget(remoteBloc, authBloc, feedBloc: feedBloc));
      await tester.pump();

      final bookmarkIcon = find.byIcon(Icons.bookmark);
      expect(bookmarkIcon, findsOneWidget);

      await tester.tap(bookmarkIcon);
      await tester.pumpAndSettle();

      expect(find.text('SavedArticlesStub'), findsOneWidget);
    });
  });

  // Account entry point — Boy Scout coverage for the new auth-aware AppBar action.
  group('DailyNews page — account entry point', () {
    testWidgets(
        'shows person_outline icon and navigates to /login when AuthAnonymous',
        (tester) async {
      when(() => remoteBloc.state)
          .thenReturn(const RemoteArticlesDone([_mockArticle]));
      when(() => authBloc.state).thenReturn(const AuthAnonymous(_mockAnonUser));

      await tester.pumpWidget(_buildTestWidget(remoteBloc, authBloc, feedBloc: feedBloc));
      await tester.pump();

      final personIcon = find.byIcon(Icons.person_outline);
      expect(personIcon, findsOneWidget);

      await tester.tap(personIcon);
      await tester.pumpAndSettle();

      expect(find.text('LoginStub'), findsOneWidget);
    });

    testWidgets(
        'shows account_circle icon when AuthAuthenticated and surfaces sign out menu',
        (tester) async {
      // Loading state avoids rendering article tiles with cached_network_image
      // (which keeps pumpAndSettle from converging in the test environment).
      when(() => remoteBloc.state).thenReturn(const RemoteArticlesLoading());
      when(() => authBloc.state)
          .thenReturn(const AuthAuthenticated(_mockUser));

      await tester.pumpWidget(_buildTestWidget(remoteBloc, authBloc, feedBloc: feedBloc));
      await tester.pump();

      final accountIcon = find.byIcon(Icons.account_circle);
      expect(accountIcon, findsOneWidget);

      await tester.tap(accountIcon);
      // Two pumps for the popup animation; pumpAndSettle would hang if any
      // sibling widget was still loading remotely.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });
  });
}
