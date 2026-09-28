import 'package:json_annotation/json_annotation.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/news_api_response.entity.dart';
import 'article.dart';

part 'news_api_response.g.dart';

/// Wraps the actual NewsAPI response shape:
/// {
///   "status": "ok",
///   "totalResults": 38,
///   "articles": [ { ... } ]
/// }
@JsonSerializable()
class NewsApiResponse extends NewsApiResponseEntity {
  @override
  final List<ArticleModel>? articles;

  const NewsApiResponse({
    super.status,
    super.totalResults,
    this.articles,
  }) : super(articles: articles);

  /// Builds a response from a NewsAPI JSON map.
  factory NewsApiResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsApiResponseFromJson(json);

  /// Builds a response from external raw data.
  factory NewsApiResponse.fromRawData(Map<String, dynamic> raw) =>
      NewsApiResponse.fromJson(raw);

  /// Serializes this response to JSON.
  Map<String, dynamic> toJson() => _$NewsApiResponseToJson(this);

  /// Converts this response to its domain [NewsApiResponseEntity].
  NewsApiResponseEntity toEntity() {
    return NewsApiResponseEntity(
      status: status,
      totalResults: totalResults,
      articles: articles?.map((m) => m.toEntity()).toList(),
    );
  }
}
