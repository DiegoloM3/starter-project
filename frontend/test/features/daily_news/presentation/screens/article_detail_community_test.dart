import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

final _community = JournalistArticleEntity(
  id: 'art-1',
  title: 'Community Article Title',
  description: 'A community article description.',
  content: 'Community article body content.',
  urlToImage: '',
  publishedAt: DateTime(2026, 1, 1),
  userId: 'user-1',
  userDisplayName: 'Author',
  source: 'journalist',
  category: ArticleCategory.news,
  tags: const [],
  language: 'en',
  readingTimeMinutes: 1,
  status: ArticleStatus.published,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  viewCount: 0,
  favoriteCount: 0,
);

Widget _buildPage({JournalistArticleEntity? community}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ArticleDetailsView(
      article: null,
      communityArticle: community,
    ),
  );
}

void main() {
  group('ArticleDetailsView — community article', () {
    testWidgets('renders title when communityArticle is provided', (tester) async {
      await tester.pumpWidget(_buildPage(community: _community));
      await tester.pump();

      expect(find.text('Community Article Title'), findsOneWidget);
    });
  });
}
