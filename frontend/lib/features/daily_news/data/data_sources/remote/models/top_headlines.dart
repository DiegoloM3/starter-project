import 'package:news_app_clean_architecture/core/resources/paginated_data.dart';
import 'package:news_app_clean_architecture/core/resources/paginated_result.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Model for the top headlines API response wrapper.
///
/// This class implements [PaginatedData<T>] to provide pagination metadata
/// (offset, limit, total, count) while also handling deserialization of the
/// raw API response into [ArticleModel] instances.
///
/// The [toEntity] method converts this model into a domain-layer
/// [PaginatedResult<ArticleEntity>] for use by repositories.
class TopHeadlinesModel with PaginatedData<ArticleModel> {
  /// The page number used to fetch this batch (1-based).
  final int page;

  /// The number of articles per page.
  final int pageSize;

  /// Total results available from the API.
  @override
  final int total;

  /// The list of article models for this page.
  @override
  final List<ArticleModel> results;

  const TopHeadlinesModel({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.results,
  });

  factory TopHeadlinesModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> articlesJson = json['articles'] ?? [];
    final articles = articlesJson
        .map(
          (article) => ArticleModel.fromJson(article as Map<String, dynamic>),
        )
        .toList();

    return TopHeadlinesModel(
      page: 1,
      pageSize: 20,
      total: json['totalResults'] as int? ?? 0,
      results: articles,
    );
  }

  /// Converts this model to a domain-layer [PaginatedResult<ArticleEntity>].
  ///
  /// [page] and [pageSize] are passed explicitly because they are request
  /// parameters, not present in the JSON response body.
  PaginatedResult<ArticleEntity> toEntity({
    required int page,
    required int pageSize,
  }) {
    return PaginatedResult<ArticleEntity>(
      page: page,
      pageSize: pageSize,
      totalResults: total,
      articles: results.map((model) => model.toEntity()).toList(),
    );
  }

  /// The offset within the total dataset (0-based).
  ///
  /// Calculated as `(page - 1) * pageSize` to convert from 1-based page
  /// numbering to 0-based offset.
  @override
  int get offset => (page - 1) * pageSize;

  /// The page size / limit for this result set.
  @override
  int get limit => pageSize;

  /// The number of items in this page.
  @override
  int get count => results.length;
}
