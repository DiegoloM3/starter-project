import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/saved_journalist_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_saved_journalist_articles.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/remove_saved_journalist_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/saved_journalist_articles/saved_journalist_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/screens/saved_journalist_articles/saved_journalist_articles_screen.dart';

JournalistArticleEntity buildArticle(String id, String title) {
  return JournalistArticleEntity(
    id: id,
    title: title,
    description: 'A short summary.',
    content: 'Some content',
    author: 'Jane Doe',
    authorId: 'janeDoeUid',
    thumbnailURL: '',
    publishedAt: DateTime.utc(2026, 9, 30),
    commentCount: 2,
  );
}

/// Keeps the saved articles in memory, as the journalist's list in Firestore would.
class FakeSavedJournalistArticleRepository implements SavedJournalistArticleRepository {
  final List<JournalistArticleEntity> savedArticles;

  FakeSavedJournalistArticleRepository(this.savedArticles);

  @override
  Future<DataState<List<JournalistArticleEntity>>> getSavedArticles() async => DataSuccess([...savedArticles]);

  @override
  Future<DataState<void>> removeSavedArticle(String articleId) async {
    savedArticles.removeWhere((article) => article.id == articleId);
    return const DataSuccess(null);
  }

  @override
  Future<DataState<bool>> isArticleSaved(String articleId) => throw UnimplementedError();

  @override
  Future<DataState<void>> saveArticle(String articleId) => throw UnimplementedError();
}

/// User journey "see and remove the saved journalists' articles", with the real cubit and use cases.
void main() {
  late FakeSavedJournalistArticleRepository repository;

  Future<void> openSavedArticles(WidgetTester tester, List<JournalistArticleEntity> savedArticles) async {
    repository = FakeSavedJournalistArticleRepository([...savedArticles]);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(),
      home: Scaffold(
        body: BlocProvider(
          create: (_) => SavedJournalistArticlesCubit(
            GetSavedJournalistArticlesUseCase(repository),
            RemoveSavedJournalistArticleUseCase(repository),
          )..loadSavedArticles(),
          child: const SavedJournalistArticlesScreen(),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the saved articles, each one with a filled bookmark', (tester) async {
    await openSavedArticles(tester, [
      buildArticle('article1', 'Local startup brings clean water'),
      buildArticle('article2', 'Community gardens double in size'),
    ]);

    expect(find.text('Local startup brings clean water'), findsOneWidget);
    expect(find.text('Community gardens double in size'), findsOneWidget);
    expect(find.byTooltip('Remove from saved'), findsNWidgets(2));
  });

  testWidgets('removes an article from the list and tells the journalist', (tester) async {
    await openSavedArticles(tester, [
      buildArticle('article1', 'Local startup brings clean water'),
      buildArticle('article2', 'Community gardens double in size'),
    ]);

    await tester.tap(find.byTooltip('Remove from saved').first);
    await tester.pumpAndSettle();

    expect(find.text('Local startup brings clean water'), findsNothing);
    expect(find.text('Community gardens double in size'), findsOneWidget);
    expect(find.text('Removed from saved'), findsOneWidget);
    expect(repository.savedArticles.map((article) => article.id), ['article2']);
    // The toast closes by itself after a few seconds.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('explains how to save an article when there is none', (tester) async {
    await openSavedArticles(tester, []);

    expect(find.textContaining('No saved articles yet'), findsOneWidget);
  });
}
