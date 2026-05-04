import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_article_by_id.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/screens/article_edit/article_edit_page.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MockUploadArticleBloc
    extends MockBloc<UploadArticleEvent, UploadArticleState>
    implements UploadArticleBloc {}

class MockWatchArticleByIdUseCase extends Mock
    implements WatchArticleByIdUseCase {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

JournalistArticleEntity _makeArticle() => JournalistArticleEntity(
      id: 'art-edit-1',
      title: 'Editable Article',
      description: 'A description that is long enough to pass validation checks',
      content: 'Content that is definitely more than fifty characters long here.',
      urlToImage: 'https://example.com/thumb.jpg',
      publishedAt: DateTime(2025),
      userId: 'uid-1',
      userDisplayName: 'Alice',
      source: 'journalist',
      category: ArticleCategory.tech,
      tags: const ['flutter'],
      language: 'en',
      readingTimeMinutes: 1,
      status: ArticleStatus.published,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
      viewCount: 0,
      favoriteCount: 0,
    );

Widget _buildPage(MockUploadArticleBloc bloc, MockWatchArticleByIdUseCase watchUseCase) {
  final router = GoRouter(
    initialLocation: '/article/edit/art-edit-1',
    routes: [
      GoRoute(
        path: '/article/edit/:id',
        builder: (_, __) => BlocProvider<UploadArticleBloc>.value(
          value: bloc,
          child: const ArticleEditPage(articleId: 'art-edit-1'),
        ),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Center(child: Text('Home'))),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  late MockUploadArticleBloc bloc;
  late MockWatchArticleByIdUseCase watchUseCase;
  late MockFirebaseAuth firebaseAuth;
  late MockUser user;

  setUpAll(() {
    registerFallbackValue(LoadArticleForEditEvent(_makeArticle()));
  });

  setUp(() {
    bloc = MockUploadArticleBloc();
    watchUseCase = MockWatchArticleByIdUseCase();
    firebaseAuth = MockFirebaseAuth();
    user = MockUser();

    when(() => bloc.state).thenReturn(const UploadArticleState());
    when(() => user.uid).thenReturn('uid-1');
    when(() => firebaseAuth.currentUser).thenReturn(user);

    if (sl.isRegistered<WatchArticleByIdUseCase>()) {
      sl.unregister<WatchArticleByIdUseCase>();
    }
    sl.registerLazySingleton<WatchArticleByIdUseCase>(() => watchUseCase);
    if (sl.isRegistered<FirebaseAuth>()) {
      sl.unregister<FirebaseAuth>();
    }
    sl.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);
  });

  tearDown(() {
    bloc.close();
    if (sl.isRegistered<WatchArticleByIdUseCase>()) {
      sl.unregister<WatchArticleByIdUseCase>();
    }
    if (sl.isRegistered<FirebaseAuth>()) {
      sl.unregister<FirebaseAuth>();
    }
  });

  group('ArticleEditPage', () {
    testWidgets('shows loading spinner while stream has not emitted', (tester) async {
      final controller = StreamController<JournalistArticleEntity?>();
      when(() => watchUseCase.call(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      await tester.pumpWidget(_buildPage(bloc, watchUseCase));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await controller.close();
    });

    testWidgets('shows Edit Article title and Save changes FAB once article loads',
        (tester) async {
      final article = _makeArticle();
      when(() => watchUseCase.call(params: any(named: 'params')))
          .thenAnswer((_) => Stream.value(article));

      await tester.pumpWidget(_buildPage(bloc, watchUseCase));
      await tester.pump();
      await tester.pump();

      expect(find.text('Edit Article'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('shows not-found message when article is null', (tester) async {
      when(() => watchUseCase.call(params: any(named: 'params')))
          .thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(_buildPage(bloc, watchUseCase));
      await tester.pump();
      await tester.pump();

      expect(find.text('Article not found.'), findsOneWidget);
    });

    testWidgets('shows not-authorized message when current user is not the owner',
        (tester) async {
      when(() => user.uid).thenReturn('different-uid');
      final article = _makeArticle();
      when(() => watchUseCase.call(params: any(named: 'params')))
          .thenAnswer((_) => Stream.value(article));

      await tester.pumpWidget(_buildPage(bloc, watchUseCase));
      await tester.pump();
      await tester.pump();

      expect(
        find.text("You don't have permission to edit this article."),
        findsOneWidget,
      );
      expect(find.text('Save changes'), findsNothing);
    });
  });
}

