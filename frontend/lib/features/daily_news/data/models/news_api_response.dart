import 'article.dart';

class NewsApiResponseModel {
  final String status;
  final int totalResults;
  final List<ArticleModel> articles;

  const NewsApiResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsApiResponseModel.fromJson(Map<String, dynamic> json) {
    final rawArticles = json['articles'];
    return NewsApiResponseModel(
      status: json['status'] as String? ?? 'error',
      totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
      articles: rawArticles is List
          ? rawArticles
              .whereType<Map<String, dynamic>>()
              .map(ArticleModel.fromJson)
              .toList()
          : const [],
    );
  }
}
