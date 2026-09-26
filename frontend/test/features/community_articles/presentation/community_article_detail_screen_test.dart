import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/entities/community_article.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/screens/community_article_detail_screen.dart';

const detailArticle = CommunityArticleEntity(
  id: 'article',
  author: 'Reporter',
  title: 'A published article',
  description: 'A published article description.',
  url: '',
  urlToImage: 'https://example.test/portrait.jpg',
  publishedAt: '',
  content: 'The full published article content.',
  thumbnailPath: 'media/articles/reporter/article/portrait.jpg',
  payloadHash: 'hash',
  ownerUid: 'owner',
);

void main() {
  testWidgets('renders the publication date in the standard format',
      (tester) async {
    const article = CommunityArticleEntity(
      id: 'article',
      author: 'Reporter',
      title: 'A published article',
      description: 'A published article description.',
      url: '',
      urlToImage: '',
      publishedAt: '2026-09-23T08:00:00Z',
      content: 'The full published article content.',
      thumbnailPath: '',
      payloadHash: 'hash',
      ownerUid: 'owner',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityArticleDetailScreen(article: article),
      ),
    );

    expect(find.text('Reporter · 2026-09-23'), findsOneWidget);
    expect(find.textContaining('2026-09-23T08:00:00Z'), findsNothing);
  });

  testWidgets('falls back to createdAt when publication date is unavailable',
      (tester) async {
    final article = CommunityArticleEntity(
      id: 'article',
      author: 'Reporter',
      title: 'A published article',
      description: 'A published article description.',
      url: '',
      urlToImage: '',
      publishedAt: '',
      content: 'The full published article content.',
      thumbnailPath: '',
      payloadHash: 'hash',
      ownerUid: 'owner',
      createdAt: DateTime(2026, 9, 23),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CommunityArticleDetailScreen(article: article),
      ),
    );

    expect(find.text('Reporter · 2026-09-23'), findsOneWidget);
  });

  testWidgets('shows the full detail image without cropping', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityArticleDetailScreen(article: detailArticle),
      ),
    );

    expect(
      find.bySemanticsLabel(
        'Article image. The full image is shown without cropping.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage)).fit,
      BoxFit.contain,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not render an image frame when the article has no image',
      (tester) async {
    const articleWithoutImage = CommunityArticleEntity(
      id: 'article',
      author: 'Reporter',
      title: 'A published article',
      description: 'A published article description.',
      url: '',
      urlToImage: '',
      publishedAt: '',
      content: 'The full published article content.',
      thumbnailPath: '',
      payloadHash: 'hash',
      ownerUid: 'owner',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityArticleDetailScreen(article: articleWithoutImage),
      ),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
