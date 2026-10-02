import '../../domain/entities/article.dart';

/// Placeholder news drawn as a skeleton while the real ones are loading: they only give the cards their shape.
List<ArticleEntity> buildPlaceholderArticles(int count) {
  return List.filled(
    count,
    const ArticleEntity(
      title: 'A headline that takes about two lines of the card',
      description: 'A short summary of the news that also takes two lines of text.',
      urlToImage: '',
      publishedAt: '2026-01-01T00:00:00Z',
    ),
  );
}
