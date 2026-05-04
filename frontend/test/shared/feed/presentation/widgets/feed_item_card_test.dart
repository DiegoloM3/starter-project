import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/shared/feed/domain/entities/feed_item.dart';
import 'package:news_app_clean_architecture/shared/feed/presentation/widgets/feed_item_card.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

ArticleEntity _newsArticle({
  String title = 'News Title',
  String? urlToImage = 'https://example.com/img.jpg',
  String? author = 'John Doe',
}) =>
    ArticleEntity(
      id: 1,
      title: title,
      author: author,
      urlToImage: urlToImage,
      publishedAt: '2024-01-01T12:00:00Z',
    );

JournalistArticleEntity _journalistArticle({
  String title = 'Community Title',
  String urlToImage = 'https://example.com/cimg.jpg',
  String userDisplayName = 'Jane Writer',
}) =>
    JournalistArticleEntity(
      id: 'j1',
      title: title,
      description: 'desc',
      content: 'content',
      urlToImage: urlToImage,
      publishedAt: DateTime(2024, 1, 2),
      userId: 'uid1',
      userDisplayName: userDisplayName,
      source: 'journalist',
      category: ArticleCategory.news,
      tags: const [],
      language: 'en',
      readingTimeMinutes: 2,
      status: ArticleStatus.published,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      viewCount: 0,
      favoriteCount: 0,
    );

void main() {
  group('FeedItemCard', () {
    testWidgets('renders title for NewsApiFeedItem', (tester) async {
      final item = NewsApiFeedItem(_newsArticle(title: 'Breaking News'));
      await tester.pumpWidget(_wrap(FeedItemCard(item: item)));
      expect(find.text('Breaking News'), findsOneWidget);
    });

    testWidgets('renders title for JournalistFeedItem', (tester) async {
      final item = JournalistFeedItem(_journalistArticle(title: 'My Article'));
      await tester.pumpWidget(_wrap(FeedItemCard(item: item)));
      expect(find.text('My Article'), findsOneWidget);
    });

    testWidgets('shows News badge for NewsApiFeedItem', (tester) async {
      final item = NewsApiFeedItem(_newsArticle());
      await tester.pumpWidget(_wrap(FeedItemCard(item: item)));
      expect(find.text('News'), findsOneWidget);
    });

    testWidgets('shows Community badge for JournalistFeedItem', (tester) async {
      final item = JournalistFeedItem(_journalistArticle());
      await tester.pumpWidget(_wrap(FeedItemCard(item: item)));
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final item = NewsApiFeedItem(_newsArticle());
      await tester.pumpWidget(
        _wrap(FeedItemCard(item: item, onTap: () => tapped = true)),
      );
      await tester.tap(find.byType(FeedItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows placeholder when thumbnailUrl is empty', (tester) async {
      final item = NewsApiFeedItem(_newsArticle(urlToImage: null));
      await tester.pumpWidget(_wrap(FeedItemCard(item: item)));
      expect(find.byType(Image), findsNothing);
    });
  });
}
