import 'package:json_annotation/json_annotation.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

part 'news_top_headlines_response.g.dart';

@JsonSerializable(createToJson: false)
class NewsTopHeadlinesResponse {
  const NewsTopHeadlinesResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsTopHeadlinesResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsTopHeadlinesResponseFromJson(json);

  @JsonKey(defaultValue: '')
  final String status;

  @JsonKey(defaultValue: 0)
  final int totalResults;

  @JsonKey(defaultValue: <ArticleModel>[])
  final List<ArticleModel> articles;
}
