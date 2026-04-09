import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/save_article_fab.dart';

// Pins spec 011 scenario 6: tapping the FAB persists the article via the
// use case and shows a success snackbar.
//
// Instead of mocking the bloc (which requires implementing every abstract
// method), we construct a real LocalArticleBloc over real use cases over
// a hand-rolled _FakeArticleRepository. That mirrors how the production
// wiring works and lets us assert on the repository side — which is the
// real guarantee: "the article was persisted".

class _FakeArticleRepository implements ArticleRepository {
  final List<ArticleEntity> savedCalls = [];
  final List<ArticleEntity> removedCalls = [];

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    savedCalls.add(article);
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    removedCalls.add(article);
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async => const [];

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    throw UnimplementedError(
        'getNewsArticles is not exercised by the save-fab test');
  }
}

const _article = ArticleEntity(
  id: 7,
  title: 'Headline',
  description: 'Description',
  url: 'https://example.com',
  urlToImage: 'https://example.com/image.png',
  publishedAt: '2026-04-08T12:00:00Z',
  content: 'Body.',
);

LocalArticleBloc _buildBloc(_FakeArticleRepository repo) {
  return LocalArticleBloc(
    GetSavedArticleUseCase(repo),
    SaveArticleUseCase(repo),
    RemoveArticleUseCase(repo),
  );
}

Widget _wrap(LocalArticleBloc bloc) => MaterialApp(
      home: BlocProvider<LocalArticleBloc>.value(
        value: bloc,
        child: const Scaffold(
          floatingActionButton: SaveArticleFab(article: _article),
        ),
      ),
    );

void main() {
  group('SaveArticleFab', () {
    testWidgets(
      'tapping the FAB persists the article through the save use case',
      (tester) async {
        final repo = _FakeArticleRepository();
        final bloc = _buildBloc(repo);
        addTearDown(bloc.close);

        await tester.pumpWidget(_wrap(bloc));
        await tester.tap(find.byType(FloatingActionButton));
        // Let the bloc handler run and reach the repository.
        await tester.pumpAndSettle();

        expect(repo.savedCalls, hasLength(1));
        expect(repo.savedCalls.single, equals(_article));
        expect(repo.removedCalls, isEmpty);
      },
    );

    testWidgets(
      'tapping the FAB shows a success snackbar',
      (tester) async {
        final repo = _FakeArticleRepository();
        final bloc = _buildBloc(repo);
        addTearDown(bloc.close);

        await tester.pumpWidget(_wrap(bloc));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump(); // start snackbar animation
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Article saved successfully.'), findsOneWidget);
      },
    );

    testWidgets(
      'no persistence happens before the user taps',
      (tester) async {
        final repo = _FakeArticleRepository();
        final bloc = _buildBloc(repo);
        addTearDown(bloc.close);

        await tester.pumpWidget(_wrap(bloc));
        await tester.pump();

        expect(repo.savedCalls, isEmpty);
      },
    );
  });
}
