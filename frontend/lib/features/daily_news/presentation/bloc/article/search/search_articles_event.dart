import '../../../../domain/entities/article.dart';

abstract class SearchArticlesEvent {
  const SearchArticlesEvent();
}

class SearchQueryChanged extends SearchArticlesEvent {
  final String query;

  const SearchQueryChanged(this.query);
}

class SearchFeedLoaded extends SearchArticlesEvent {
  final List<ArticleEntity> articles;

  const SearchFeedLoaded(this.articles);
}
