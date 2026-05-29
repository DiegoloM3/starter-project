import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

class NewsApiResponse {
  const NewsApiResponse({required this.articles});

  final List<ArticleModel> articles;

  factory NewsApiResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['articles'] as List<dynamic>? ?? const [];
    return NewsApiResponse(
      articles: raw
          .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
