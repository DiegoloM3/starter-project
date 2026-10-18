// Mock data used by the use cases until the data layer connects them to Firebase.

import '../../entities/article.dart';
import '../../entities/article_content.dart';
import '../../entities/article_topic.dart';

/// Simulates the network latency so the UI can show its loading states.
const Duration mockNetworkDelay = Duration(milliseconds: 300);

const String mockJournalistId = 'mock-journalist';
const String mockJournalistName = 'Jane Doe';
const String mockImageURL = 'https://picsum.photos/seed/symmetry/800/450';

final List<ArticleEntity> mockArticles = List.unmodifiable([
  _buildMockArticle(
    id: 'mock-article-1',
    title: 'The indie games that surprised everyone this year',
    description: 'Small studios proved that a great idea matters more than a huge budget.',
    topics: const [ArticleTopic.gaming, ArticleTopic.culture],
    publishedAt: DateTime(2026, 10, 16, 9, 30),
  ),
  _buildMockArticle(
    id: 'mock-article-2',
    title: 'How artificial intelligence is changing newsrooms',
    description: 'Journalists explain how they use new tools without losing their judgement.',
    topics: const [ArticleTopic.technology],
    publishedAt: DateTime(2026, 10, 15, 18),
  ),
  _buildMockArticle(
    id: 'mock-article-3',
    title: 'The final that nobody expected',
    description: 'An underdog team wrote one of the best stories of the season.',
    topics: const [ArticleTopic.sports],
    publishedAt: DateTime(2026, 10, 14, 21, 15),
    authorId: 'mock-journalist-2',
    authorName: 'Omar Ruiz',
  ),
]);

const List<String> mockSavedArticleIds = ['mock-article-2'];

ArticleEntity? findMockArticle(String articleId) {
  for (final article in mockArticles) {
    if (article.id == articleId) return article;
  }
  return null;
}

ArticleEntity _buildMockArticle({
  required String id,
  required String title,
  required String description,
  required List<ArticleTopic> topics,
  required DateTime publishedAt,
  String authorId = mockJournalistId,
  String authorName = mockJournalistName,
}) {
  return ArticleEntity(
    id: id,
    title: title,
    description: description,
    content: ArticleContent.fromPlainText('$description\n\nThis is the full text of the article.'),
    thumbnailURL: 'https://picsum.photos/seed/$id/800/450',
    topics: topics,
    publishedAt: publishedAt,
    authorId: authorId,
    authorName: authorName,
  );
}
