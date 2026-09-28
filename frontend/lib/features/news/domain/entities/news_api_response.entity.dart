import 'package:equatable/equatable.dart';

import 'article.entity.dart';

/// Business object for a paged news-API response and its articles.
class NewsApiResponseEntity extends Equatable {
  final String? status;
  final int? totalResults;
  final List<ArticleEntity>? articles;

  const NewsApiResponseEntity({
    this.status,
    this.totalResults,
    this.articles,
  });

  @override
  List<Object?> get props => [status, totalResults, articles];
}
