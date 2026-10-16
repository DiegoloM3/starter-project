import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_image_placeholder.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/journalist_badge.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MockGetSavedArticleUseCase extends Mock implements GetSavedArticleUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

void main() {
  late MockSaveArticleUseCase saveArticle;

  setUpAll(() {
    registerFallbackValue(const ArticleEntity());
  });

  setUp(() {
    final getSavedArticles = MockGetSavedArticleUseCase();
    saveArticle = MockSaveArticleUseCase();
    when(() => getSavedArticles()).thenAnswer((_) async => []);
    when(() => saveArticle(params: any(named: 'params'))).thenAnswer((_) async {});
    sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(getSavedArticles, saveArticle, MockRemoveArticleUseCase()),
    );
  });

  tearDown(() => sl.reset());

  Future<void> pumpDetail(WidgetTester tester, ArticleEntity article) {
    return tester.pumpWidget(MaterialApp(home: ArticleDetailsView(article: article)));
  }

  group('ArticleDetailsView', () {
    const publishedArticle = ArticleEntity(
      title: 'Breaking News!',
      description: 'This is breaking news!',
      publishedAt: '2026-10-15T09:30:00Z',
      content: 'This is breaking news!',
    );

    testWidgets('shows the article once, without repeating its description', (tester) async {
      await pumpDetail(tester, publishedArticle);

      expect(find.text('Breaking News!'), findsOneWidget);
      expect(find.text('This is breaking news!'), findsOneWidget);
    });

    testWidgets('shows a placeholder instead of failing for an article without image', (tester) async {
      await pumpDetail(tester, publishedArticle);

      expect(tester.takeException(), isNull);
      expect(find.byType(ArticleImagePlaceholder), findsOneWidget);
    });

    testWidgets('shows the formatting of the content without its marks', (tester) async {
      await pumpDetail(tester, const ArticleEntity(
        title: 'Breaking News!',
        publishedAt: '2026-10-15T09:30:00Z',
        content: '## Key facts\nThe council approved the **new park**.',
      ));

      expect(find.byType(MarkdownBody), findsOneWidget);
      expect(find.text('Key facts'), findsOneWidget);
      expect(find.textContaining('**', findRichText: true), findsNothing);
      expect(find.textContaining('##', findRichText: true), findsNothing);
    });

    testWidgets('aligns a short content to the left', (tester) async {
      await pumpDetail(tester, publishedArticle);

      expect(tester.getTopLeft(find.byType(MarkdownBody)).dx, 14);
    });

    testWidgets('shows an article without publication date', (tester) async {
      await pumpDetail(tester, const ArticleEntity(title: 'Breaking News!', content: 'Content'));

      expect(tester.takeException(), isNull);
      expect(find.text('Breaking News!'), findsOneWidget);
    });

    testWidgets('marks an article written by a journalist', (tester) async {
      await pumpDetail(tester, PublishedArticleEntity(
        title: 'Breaking News!',
        content: 'Content',
        thumbnailUrl: '',
        publishedAt: DateTime.now(),
      ));

      expect(find.byType(JournalistBadge), findsOneWidget);
    });

    testWidgets('saves the article', (tester) async {
      await pumpDetail(tester, publishedArticle);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      verify(() => saveArticle(params: publishedArticle)).called(1);
      expect(find.text('Article saved successfully.'), findsOneWidget);
    });
  });
}
