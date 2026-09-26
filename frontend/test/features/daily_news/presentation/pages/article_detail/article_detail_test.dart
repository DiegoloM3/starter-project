import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail_content.dart';

const article = ArticleEntity(
  author: 'Reporter',
  title: 'A saved article',
  description: 'A description for the article.',
  url: 'https://example.com/articles/saved',
  urlToImage: '',
  publishedAt: '2026-09-23',
  content: 'Article content.',
);

class BookmarkRepository implements ArticleRepository {
  final saved = <ArticleEntity>[];
  bool failSave = false;
  bool failRemove = false;
  bool normalizeOnSave = false;
  bool failReloadAfterInitial = false;
  int readCalls = 0;

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async =>
      const DataSuccess([]);

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    readCalls++;
    if (failReloadAfterInitial && readCalls > 1) {
      throw StateError('refresh failed');
    }
    return List.of(saved);
  }

  @override
  Future<void> saveArticle(ArticleEntity value) async {
    if (failSave) throw StateError('save failed');
    final persisted = normalizeOnSave
        ? ArticleModel.fromRawData({
            ...ArticleModel.fromEntity(value).toRawData(),
            if (value.description == null) 'description': '',
          }).toEntity()
        : value;
    saved
      ..removeWhere((item) => item == persisted)
      ..add(persisted);
  }

  @override
  Future<void> removeArticle(ArticleEntity value) async {
    if (failRemove) throw StateError('remove failed');
    saved.removeWhere((item) => item == value);
  }
}

LocalArticleBloc createBloc(BookmarkRepository repository) => LocalArticleBloc(
      GetSavedArticleUseCase(repository),
      SaveArticleUseCase(repository),
      RemoveArticleUseCase(repository),
    );

Future<void> pumpDetails(
  WidgetTester tester,
  BookmarkRepository repository, {
  ArticleEntity detailArticle = article,
  CopySourceLink? copySourceLink,
  OpenSourceLink? openSourceLink,
  LaunchSourceUrl? launchSourceUrl,
}) async {
  final bloc = createBloc(repository);
  addTearDown(bloc.close);
  await tester.pumpWidget(
    MaterialApp(
      home: ArticleDetailsView(
        article: detailArticle,
        localArticleBloc: bloc,
        copySourceLink: copySourceLink,
        openSourceLink: openSourceLink,
        launchSourceUrl: launchSourceUrl,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('removes the NewsAPI truncation marker and marks an excerpt', () {
    const detailArticle = ArticleEntity(
      description: 'A concise summary of the report.',
      content: 'The report continues with additional context. [+5558 chars]',
    );

    final detail = composeArticleDetailContent(detailArticle);

    expect(
        detail.text, contains('The report continues with additional context.'));
    expect(detail.text, isNot(contains('[+5558 chars]')));
    expect(detail.isExcerpt, isTrue);
  });

  test('does not repeat near-identical description and content', () {
    const summary =
        'The central bank held rates steady while monitoring inflation trends.';
    const detailArticle = ArticleEntity(
      description: summary,
      content: '$summary [+5558 chars]',
    );

    final detail = composeArticleDetailContent(detailArticle);

    expect(detail.text, summary);
    expect(detail.text.split(summary), hasLength(2));
    expect(detail.isExcerpt, isTrue);
  });

  test('does not mark an untruncated duplicate as an excerpt', () {
    const summary =
        'The central bank held rates steady while monitoring inflation trends.';
    const detailArticle = ArticleEntity(
      description: summary,
      content: summary,
    );

    final detail = composeArticleDetailContent(detailArticle);

    expect(detail.text, summary);
    expect(detail.isExcerpt, isFalse);
  });

  test('deduplicates wire-service dateline prefixes', () {
    const description =
        'When Chinese President Xi Jinping arrives at the White House, officials will discuss trade.';
    const detailArticle = ArticleEntity(
      description: description,
      content:
          'WASHINGTON (AP) When Chinese President Xi Jinping arrives at the White House, officials will discuss trade.',
    );

    final detail = composeArticleDetailContent(detailArticle);

    expect(detail.text, description);
    expect(detail.text.split(description), hasLength(2));
    expect(detail.isExcerpt, isFalse);
  });

  test('deduplicates a paraphrased wire-service opening', () {
    const description =
        'When Chinese President Xi Jinping arrives in Washington, he’s expected to meet with President Donald Trump.';
    const content =
        'When Chinese President Xi Jinping arrives in Washington on Wednesday, hes expected to meet with President Donald Trump. [+5558 chars]';
    const cleanContent =
        'When Chinese President Xi Jinping arrives in Washington on Wednesday, hes expected to meet with President Donald Trump.';
    final detail = composeArticleDetailContent(
      const ArticleEntity(description: description, content: content),
    );

    expect(detail.text, cleanContent);
    expect(detail.text, isNot(contains('[+5558 chars]')));
    expect(detail.text, isNot(contains('\n\n')));
    expect(detail.isExcerpt, isTrue);
  });

  test('keeps distinct complete facts with overlapping openings', () {
    const description =
        'The company said it would build new homes for local residents.';
    const content =
        'The company said it would build a new stadium for local residents, while officials discussed unrelated funding details at length.';
    final detail = composeArticleDetailContent(
      const ArticleEntity(description: description, content: content),
    );

    expect(detail.text, '$description\n\n$content');
    expect(detail.isExcerpt, isFalse);
  });

  test('prefers a longer description when content is truncated', () {
    const description =
        'The report says officials met to discuss a detailed plan for regional funding and long-term growth.';
    const content =
        'The report says officials met to discuss a detailed plan for regional funding. [+120 chars]';
    final detail = composeArticleDetailContent(
      const ArticleEntity(description: description, content: content),
    );

    expect(detail.text, description);
    expect(detail.isExcerpt, isTrue);
  });

  test('keeps distinct Unicode descriptions and content', () {
    const detailArticle = ArticleEntity(
      description: '北京方面表示谈判正在继续。',
      content: '東京の当局者は別の声明を発表した。',
    );

    final detail = composeArticleDetailContent(detailArticle);

    expect(detail.text, '北京方面表示谈判正在继续。\n\n東京の当局者は別の声明を発表した。');
    expect(detail.isExcerpt, isFalse);
  });

  test('cleans a truncation marker from description-only articles', () {
    final detail = composeArticleDetailContent(
      const ArticleEntity(description: 'A source summary. [+120 chars]'),
    );

    expect(detail.text, 'A source summary.');
    expect(detail.isExcerpt, isTrue);
  });

  test('marks combined content when the description is truncated', () {
    final detail = composeArticleDetailContent(
      const ArticleEntity(
        description: 'A source summary. [+120 chars]',
        content: 'Additional article context.',
      ),
    );

    expect(detail.text, 'A source summary.\n\nAdditional article context.');
    expect(detail.isExcerpt, isTrue);
  });

  test('keeps distinct ordinary description and full content', () {
    const detailArticle = ArticleEntity(
      description: 'A short summary.',
      content: 'The full report includes separate details and context.',
    );

    final detail = composeArticleDetailContent(detailArticle);

    expect(detail.text,
        'A short summary.\n\nThe full report includes separate details and context.');
    expect(detail.isExcerpt, isFalse);
  });

  test('handles null and empty article content explicitly', () {
    final summaryOnly = composeArticleDetailContent(
      const ArticleEntity(description: 'Summary only.'),
    );
    final empty = composeArticleDetailContent(const ArticleEntity());

    expect(summaryOnly.text, 'Summary only.');
    expect(summaryOnly.isExcerpt, isTrue);
    expect(empty.text, 'No article excerpt is available.');
    expect(empty.isExcerpt, isTrue);
  });

  testWidgets('shows an unmistakable unsaved bookmark state', (tester) async {
    final repository = BookmarkRepository();
    await pumpDetails(tester, repository);

    expect(find.text('Save'), findsNothing);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    expect(find.byTooltip('Save article'), findsOneWidget);
    expect(find.bySemanticsLabel('Save article'), findsOneWidget);
  });

  testWidgets('loads, toggles, persists, and removes bookmark state',
      (tester) async {
    final repository = BookmarkRepository()..saved.add(article);
    await pumpDetails(tester, repository);

    expect(find.text('Saved'), findsNothing);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byTooltip('Saved article. Remove bookmark'), findsOneWidget);

    await tester.tap(find.byTooltip('Saved article. Remove bookmark'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsNothing);
    expect(repository.saved, isEmpty);

    await tester.tap(find.byTooltip('Save article'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
    expect(repository.saved, [article]);

    await pumpDetails(tester, repository);
    expect(find.text('Saved'), findsNothing);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
  });

  testWidgets('keeps saved state after acknowledged save with refresh failure',
      (tester) async {
    final repository = BookmarkRepository()..failReloadAfterInitial = true;
    await pumpDetails(tester, repository);

    await tester.tap(find.byTooltip('Save article'));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsNothing);
    expect(
      find.text('Article saved, but the saved list could not be refreshed.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'keeps unsaved state after acknowledged remove with refresh failure',
      (tester) async {
    final repository = BookmarkRepository()
      ..saved.add(article)
      ..failReloadAfterInitial = true;
    await pumpDetails(tester, repository);

    await tester.tap(find.byTooltip('Saved article. Remove bookmark'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    expect(
      find.text('Article removed, but the saved list could not be refreshed.'),
      findsOneWidget,
    );
  });

  testWidgets('does not claim saved state when persistence fails',
      (tester) async {
    final repository = BookmarkRepository()..failSave = true;
    await pumpDetails(tester, repository);

    await tester.tap(find.byTooltip('Save article'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    expect(find.text('Saved'), findsNothing);
    expect(find.text('Unable to save the article.'), findsOneWidget);
  });

  testWidgets('recognizes a sparse persisted article by stable URL identity',
      (tester) async {
    const sparseArticle = ArticleEntity(
      title: 'Oil Prices Fall on U.S.-Iran Diplomacy Hopes - WSJ',
      url: 'https://example.com/wsj/oil-prices',
      publishedAt: '2026-09-23T08:00:00Z',
    );
    final repository = BookmarkRepository()..normalizeOnSave = true;
    final bloc = createBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailsView(
          article: sparseArticle,
          localArticleBloc: bloc,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save article'));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsNothing);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(repository.saved.single, isNot(sparseArticle));
    expect(
      articleBookmarkKey(repository.saved.single),
      articleBookmarkKey(sparseArticle),
    );
  });

  testWidgets('renders a clean excerpt for a persisted saved article',
      (tester) async {
    const persistedArticle = ArticleEntity(
      title: 'Persisted article',
      description: 'A persisted summary of the article.',
      content: 'A persisted summary of the article. [+5558 chars]',
      url: 'https://example.com/persisted',
      publishedAt: '2026-09-24',
    );
    final repository = BookmarkRepository()..saved.add(persistedArticle);
    await pumpDetails(
      tester,
      repository,
      detailArticle: persistedArticle,
    );

    expect(find.text('A persisted summary of the article.'), findsOneWidget);
    expect(find.textContaining('[+5558 chars]'), findsNothing);
    expect(find.text('Copy source link'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
  });

  testWidgets('reports source-link copy failures', (tester) async {
    const sourceArticle = ArticleEntity(
      description: 'A source summary.',
      content: 'A source summary. [+120 chars]',
      url: 'https://example.com/source',
    );
    final repository = BookmarkRepository();
    await pumpDetails(
      tester,
      repository,
      detailArticle: sourceArticle,
      copySourceLink: (_) async => throw StateError('clipboard unavailable'),
    );

    await tester.tap(find.text('Copy source link'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to copy source link.'), findsOneWidget);
  });

  testWidgets('opens the publisher page from the full article CTA',
      (tester) async {
    const sourceArticle = ArticleEntity(
      description: 'A source summary.',
      content: 'A source summary. [+120 chars]',
      url: 'https://example.com/source',
    );
    Uri? openedUrl;
    await pumpDetails(
      tester,
      BookmarkRepository(),
      detailArticle: sourceArticle,
      openSourceLink: (url) async {
        openedUrl = url;
        return true;
      },
    );

    await tester.tap(find.text('Read full article'));
    await tester.pumpAndSettle();

    expect(openedUrl, Uri.parse('https://example.com/source'));
    expect(find.text('Unable to open the source article.'), findsNothing);
  });

  test('uses same-tab navigation only for web launches', () {
    expect(sourceLinkWindowName(isWeb: true), '_self');
    expect(sourceLinkWindowName(isWeb: false), isNull);
  });

  testWidgets('passes native launch mode and platform target to the launcher',
      (tester) async {
    const sourceArticle = ArticleEntity(
      description: 'A source summary.',
      content: 'A source summary. [+120 chars]',
      url: 'https://example.com/source',
    );
    LaunchMode? receivedMode;
    String? receivedWindowName;
    Uri? receivedUrl;
    await pumpDetails(
      tester,
      BookmarkRepository(),
      detailArticle: sourceArticle,
      launchSourceUrl: (
        url, {
        required mode,
        webOnlyWindowName,
      }) async {
        receivedUrl = url;
        receivedMode = mode;
        receivedWindowName = webOnlyWindowName;
        return true;
      },
    );

    await tester.tap(find.text('Read full article'));
    await tester.pumpAndSettle();

    expect(receivedUrl, Uri.parse('https://example.com/source'));
    expect(receivedMode, LaunchMode.externalApplication);
    expect(receivedWindowName, sourceLinkWindowName(isWeb: kIsWeb));
  });

  testWidgets('reports a platform launcher failure', (tester) async {
    const sourceArticle = ArticleEntity(
      description: 'A source summary.',
      content: 'A source summary. [+120 chars]',
      url: 'https://example.com/source',
    );
    await pumpDetails(
      tester,
      BookmarkRepository(),
      detailArticle: sourceArticle,
      launchSourceUrl: (
        url, {
        required mode,
        webOnlyWindowName,
      }) async =>
          false,
    );

    await tester.tap(find.text('Read full article'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to open the source article.'), findsOneWidget);
  });

  testWidgets('reports when the publisher page cannot be opened',
      (tester) async {
    const sourceArticle = ArticleEntity(
      description: 'A source summary.',
      content: 'A source summary. [+120 chars]',
      url: 'https://example.com/source',
    );
    await pumpDetails(
      tester,
      BookmarkRepository(),
      detailArticle: sourceArticle,
      openSourceLink: (_) async => false,
    );

    await tester.tap(find.text('Read full article'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to open the source article.'), findsOneWidget);
  });

  testWidgets('does not expose a web CTA for missing or unsafe source URLs',
      (tester) async {
    const baseExcerpt = ArticleEntity(
      description: 'A source summary.',
      content: 'A source summary. [+120 chars]',
    );
    await pumpDetails(tester, BookmarkRepository(), detailArticle: baseExcerpt);
    expect(find.text('Read full article'), findsNothing);
    expect(find.text('Copy source link'), findsNothing);

    await pumpDetails(
      tester,
      BookmarkRepository(),
      detailArticle: const ArticleEntity(
        description: 'A source summary.',
        content: 'A source summary. [+120 chars]',
        url: 'javascript:alert(1)',
      ),
    );
    expect(find.text('Read full article'), findsNothing);
    expect(find.text('Copy source link'), findsNothing);
  });

  testWidgets('renders a standard calendar date instead of a raw timestamp',
      (tester) async {
    const timestampArticle = ArticleEntity(
      title: 'Timestamp article',
      publishedAt: '2026-09-23T08:00:00Z',
    );
    await pumpDetails(
      tester,
      BookmarkRepository(),
      detailArticle: timestampArticle,
    );

    expect(find.text('2026-09-23'), findsOneWidget);
    expect(find.text('2026-09-23T08:00:00Z'), findsNothing);
  });
}
