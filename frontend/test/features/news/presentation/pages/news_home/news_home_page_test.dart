import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_all_user_articles.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/community/community_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/news_home/community_feed_tab.dart';
import 'package:news_app_clean_architecture/features/news/presentation/pages/news_home/news_home_page.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import 'news_home_page_test.mocks.dart';

@GenerateMocks([AuthBloc, RemoteArticlesBloc, GetAllUserArticles])
void main() {
  late MockAuthBloc mockAuthBloc;
  late MockRemoteArticlesBloc mockRemoteArticlesBloc;
  late MockGetAllUserArticles mockGetAllUserArticles;

  const tArticles = [
    ArticleEntity(
      id: '1',
      authorDisplayName: 'Jane Doe',
      title: 'Community Post',
      urlToImage: 'https://example.com/community.jpg',
      publishedAt: '2026-09-27T00:00:00Z',
      content: 'Community content',
      authorId: 'user-456',
    ),
  ];

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(mockAuthBloc.state).thenReturn(const Unauthenticated());
    when(mockAuthBloc.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());

    mockRemoteArticlesBloc = MockRemoteArticlesBloc();
    when(mockRemoteArticlesBloc.state)
        .thenReturn(const RemoteArticlesLoading());
    when(mockRemoteArticlesBloc.stream)
        .thenAnswer((_) => const Stream<RemoteArticlesState>.empty());

    mockGetAllUserArticles = MockGetAllUserArticles();
    sl.registerFactory<CommunityArticlesBloc>(
      () => CommunityArticlesBloc(mockGetAllUserArticles),
    );
    // Avatar resolution is not under test here: the stub answers "no
    // photo" so every card falls back to the silhouette without Firestore.
    sl.registerFactory<AuthorAvatarCubit>(
      () => AuthorAvatarCubit(_StubGetAuthorProfile()),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildHomePage() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<RemoteArticlesBloc>.value(
              value: mockRemoteArticlesBloc),
        ],
        child: const NewsHomePage(),
      ),
    );
  }

  testWidgets('shows both tabs on the news home page', (tester) async {
    when(mockGetAllUserArticles.call()).thenAnswer(
        (_) async => const DataSuccess(<ArticleEntity>[]));

    await tester.pumpWidget(buildHomePage());
    await tester.pump();

    expect(find.text('Daily News'), findsOneWidget);
    expect(find.text('News from Users'), findsOneWidget);
  });

  testWidgets('community tab lists articles from every user',
      (tester) async {
    when(mockGetAllUserArticles.call())
        .thenAnswer((_) async => const DataSuccess(tArticles));

    // Render the tab content directly: TabBarView page switching is
    // framework behavior, while this test covers the feed rendering.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CommunityFeedTab())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Community Post'), findsOneWidget);
  });

  testWidgets('community tab shows an empty state when nobody wrote yet',
      (tester) async {
    when(mockGetAllUserArticles.call()).thenAnswer(
        (_) async => const DataSuccess(<ArticleEntity>[]));

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CommunityFeedTab())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('NO COMMUNITY ARTICLES YET'), findsOneWidget);
  });
}

class _StubGetAuthorProfile extends Fake implements GetAuthorProfile {
  @override
  Future<DataState<UserProfileEntity?>> call(
      {GetAuthorProfileParams? params}) async {
    return const DataSuccess(null);
  }
}
