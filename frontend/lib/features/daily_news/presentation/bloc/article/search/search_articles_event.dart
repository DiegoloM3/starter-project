import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../../domain/entities/article.dart';

abstract class SearchArticlesEvent {
  const SearchArticlesEvent();
}

class SearchQueryChanged extends SearchArticlesEvent {
  final String query;

  const SearchQueryChanged(this.query);
}

class SearchArticlesUpdated extends SearchArticlesEvent {
  final DataState<List<ArticleEntity>> dataState;

  const SearchArticlesUpdated(this.dataState);
}
