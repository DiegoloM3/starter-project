import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_identity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/auth_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/auth_screen.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/article_image.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_articles.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';

class _EmptyArticleRepository implements ArticleRepository {
  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async =>
      const DataSuccess([]);

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => const [];

  @override
  Future<void> saveArticle(ArticleEntity article) async {}

  @override
  Future<void> removeArticle(ArticleEntity article) async {}
}

class _FailedArticleRepository implements ArticleRepository {
  final AppFailure failure;

  const _FailedArticleRepository(this.failure);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async =>
      DataFailed(failure);

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => const [];

  @override
  Future<void> saveArticle(ArticleEntity article) async {}

  @override
  Future<void> removeArticle(ArticleEntity article) async {}
}

class _EmptyCommunityRepository implements CommunityArticleRepository {
  @override
  Future<DataState<List<CommunityArticleEntity>>>
      getPublishedArticles() async => const DataSuccess([]);

  @override
  Future<DataState<CommunityArticleEntity>> publishArticle(
    PublishArticleParams params,
  ) async =>
      const DataFailed(AppFailure('Publishing is not used in this test.'));

  @override
  Future<DataState<ArticleImageEntity?>> pickImage() async =>
      const DataSuccess<ArticleImageEntity?>(null);
}

const _user = UserIdentity(
  uid: 'user-1',
  email: 'reporter@example.com',
  displayName: 'Reporter',
);

class _AuthRepository implements AuthRepository {
  UserIdentity? current;
  bool failSignIn = false;
  bool failSignOut = false;

  @override
  UserIdentity? get currentUser => current;

  @override
  Future<DataState<UserIdentity>> signIn(SignInParams params) async {
    if (failSignIn) {
      return const DataFailed(AppFailure('Unable to sign in.'));
    }
    current = _user;
    return const DataSuccess(_user);
  }

  @override
  Future<DataState<UserIdentity>> signUp(SignUpParams params) async {
    current = _user;
    return const DataSuccess(_user);
  }

  @override
  Future<DataState<void>> signOut() async {
    if (failSignOut) {
      return const DataFailed(AppFailure('Unable to sign out.'));
    }
    current = null;
    return const DataSuccess(null);
  }
}

AuthCubit createAuthCubit(AuthRepository repository) => AuthCubit(
      repository,
      SignInUseCase(repository),
      SignUpUseCase(repository),
      SignOutUseCase(repository),
    );

Widget buildHome({
  required RemoteArticlesBloc remoteBloc,
  required AuthCubit authCubit,
  CommunityFeedCubit? communityCubit,
  Route<dynamic> Function(RouteSettings)? onGenerateRoute,
}) {
  final effectiveCommunityCubit = communityCubit ??
      CommunityFeedCubit(
          GetCommunityArticlesUseCase(_EmptyCommunityRepository()));
  if (communityCubit == null) {
    effectiveCommunityCubit.load();
    addTearDown(effectiveCommunityCubit.close);
  }
  remoteBloc.add(const GetArticles());
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: remoteBloc),
      BlocProvider.value(value: authCubit),
      BlocProvider.value(value: effectiveCommunityCubit),
    ],
    child: MaterialApp(
      onGenerateRoute: onGenerateRoute,
      home: const DailyNews(),
    ),
  );
}

void main() {
  testWidgets('keeps the latest feed compact with visible source tabs',
      (tester) async {
    final bloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authRepository = _AuthRepository();
    final authCubit = createAuthCubit(authRepository);
    addTearDown(bloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(remoteBloc: bloc, authCubit: authCubit));

    expect(find.text('Daily News'), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Latest news'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Choose news source'), findsNothing);
    expect(find.byTooltip('Saved articles'), findsOneWidget);
    expect(find.byTooltip('Publish article'), findsOneWidget);
  });

  testWidgets('selects the source from the configured provider key',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authCubit = createAuthCubit(_AuthRepository());
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
    ));
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, newsAPIKey.trim().isEmpty ? 1 : 0);
  });

  testWidgets('switches source tabs without a hidden selection dialog',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final communityCubit = CommunityFeedCubit(
      GetCommunityArticlesUseCase(_EmptyCommunityRepository()),
    );
    final authCubit = createAuthCubit(_AuthRepository());
    addTearDown(remoteBloc.close);
    addTearDown(communityCubit.close);
    addTearDown(authCubit.close);
    communityCubit.load();

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      communityCubit: communityCubit,
    ));
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 1);
    expect(find.text('No community articles yet. Be the first to publish.'),
        findsOneWidget);

    await tester.tap(find.text('Latest news'));
    await tester.pumpAndSettle();
    expect(tabBar.controller!.index, 0);
    expect(find.text('No daily news available.'), findsOneWidget);

    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();
    expect(tabBar.controller!.index, 1);
    expect(find.text('No community articles yet. Be the first to publish.'),
        findsOneWidget);
  });

  testWidgets('explains provider outage and offers Community as a fallback',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(
        const _FailedArticleRepository(
          AppFailure('Unable to load daily news.'),
        ),
      ),
    );
    final communityCubit = CommunityFeedCubit(
      GetCommunityArticlesUseCase(_EmptyCommunityRepository()),
    );
    final authCubit = createAuthCubit(_AuthRepository());
    addTearDown(remoteBloc.close);
    addTearDown(communityCubit.close);
    addTearDown(authCubit.close);
    communityCubit.load();

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      communityCubit: communityCubit,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Latest news'));
    await tester.pumpAndSettle();

    expect(
        find.text('Latest news is temporarily unavailable.'), findsOneWidget);
    expect(
      find.text(
          'Latest news is currently unavailable from the external provider.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Retry'), findsNothing);

    await tester.tap(find.text('View Community articles'));
    await tester.pumpAndSettle();
    expect(find.text('No community articles yet. Be the first to publish.'),
        findsOneWidget);
  });

  testWidgets('keeps the home chrome phone-width on desktop', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final bloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authRepository = _AuthRepository();
    final authCubit = createAuthCubit(authRepository);
    addTearDown(bloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(remoteBloc: bloc, authCubit: authCubit));

    expect(tester.getSize(find.byType(Scaffold)), const Size(482, 900));
  });

  testWidgets('offers standalone sign-in and returns home on cancel',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authCubit = createAuthCubit(_AuthRepository());
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      onGenerateRoute: (settings) {
        if (settings.name == '/Auth') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel auth'),
              ),
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
      },
    ));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel auth'), findsOneWidget);
    await tester.tap(find.text('Cancel auth'));
    await tester.pumpAndSettle();
    expect(find.text('Daily News'), findsOneWidget);
    expect(find.text('Publisher route'), findsNothing);
  });

  testWidgets('standalone sign-in returns home without opening Publish',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authCubit = createAuthCubit(_AuthRepository());
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      onGenerateRoute: (settings) {
        if (settings.name == '/Auth') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () {
                  authCubit.emit(const AuthSignedIn(_user));
                  Navigator.pop(context, true);
                },
                child: const Text('Complete auth'),
              ),
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
      },
    ));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete auth'));
    await tester.pumpAndSettle();
    expect(find.text('Daily News'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Publisher route'), findsNothing);
  });

  testWidgets('publish gate continues to the editor after authentication',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authCubit = createAuthCubit(_AuthRepository());
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      onGenerateRoute: (settings) {
        if (settings.name == '/Auth') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () {
                  authCubit.emit(const AuthSignedIn(_user));
                  Navigator.pop(context, true);
                },
                child: const Text('Complete auth'),
              ),
            ),
          );
        }
        if (settings.name == '/PublishArticle') {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Publisher route')),
          );
        }
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
      },
    ));

    await tester.tap(find.byTooltip('Publish article'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete auth'));
    await tester.pumpAndSettle();
    expect(find.text('Publisher route'), findsOneWidget);
  });

  testWidgets('selects Community after a successful publish', (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final communityCubit = CommunityFeedCubit(
      GetCommunityArticlesUseCase(_EmptyCommunityRepository()),
    );
    final authRepository = _AuthRepository()..current = _user;
    final authCubit = createAuthCubit(authRepository);
    addTearDown(remoteBloc.close);
    addTearDown(communityCubit.close);
    addTearDown(authCubit.close);
    communityCubit.load();

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      communityCubit: communityCubit,
      onGenerateRoute: (settings) {
        if (settings.name == '/PublishArticle') {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Finish publish'),
              ),
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
      },
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Publish article'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish publish'));
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller!.index, 1);
    expect(find.text('No community articles yet. Be the first to publish.'),
        findsOneWidget);
  });

  testWidgets('signed-in account menu exposes identity and sign-out',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authRepository = _AuthRepository()..current = _user;
    final authCubit = createAuthCubit(authRepository);
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
    ));

    expect(find.text('Account'), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Reporter'), findsOneWidget);
    expect(find.text('reporter@example.com'), findsOneWidget);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('keeps the auth action visible at narrow mobile width',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authCubit = createAuthCubit(_AuthRepository());
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester
        .pumpWidget(buildHome(remoteBloc: remoteBloc, authCubit: authCubit));
    expect(find.text('Sign in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retains account and publish access when sign-out fails',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authRepository = _AuthRepository()
      ..current = _user
      ..failSignOut = true;
    final authCubit = createAuthCubit(authRepository);
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      onGenerateRoute: (settings) {
        if (settings.name == '/PublishArticle') {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Publisher route')),
          );
        }
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
      },
    ));

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    await tester.tap(find.byTooltip('Publish article'));
    await tester.pumpAndSettle();
    expect(find.text('Publisher route'), findsOneWidget);
  });

  testWidgets('shows one login failure snackbar while auth is open',
      (tester) async {
    final remoteBloc = RemoteArticlesBloc(
      GetArticleUseCase(_EmptyArticleRepository()),
    );
    final authRepository = _AuthRepository()..failSignIn = true;
    final authCubit = createAuthCubit(authRepository);
    addTearDown(remoteBloc.close);
    addTearDown(authCubit.close);

    await tester.pumpWidget(buildHome(
      remoteBloc: remoteBloc,
      authCubit: authCubit,
      onGenerateRoute: (settings) {
        if (settings.name == '/Auth') {
          return MaterialPageRoute(builder: (_) => const AuthScreen());
        }
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
      },
    ));

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byType(TextFormField).at(0), 'reporter@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to sign in.'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
