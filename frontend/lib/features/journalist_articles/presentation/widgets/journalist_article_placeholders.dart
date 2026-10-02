import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/journalist_article.dart';

/// Placeholder articles drawn as a skeleton while the real ones are loading: they only give the cards their shape.
List<JournalistArticleEntity> buildPlaceholderJournalistArticles(int count) {
  return List.generate(
    count,
    (index) => JournalistArticleEntity(
      id: 'loading$index',
      title: 'A headline that takes about two lines of the card',
      description: 'A short summary of the article.',
      content: '',
      author: 'Journalist name',
      authorId: '',
      thumbnailURL: '',
      publishedAt: DateTime.utc(2026),
    ),
  );
}
