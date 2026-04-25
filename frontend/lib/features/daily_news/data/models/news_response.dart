import 'article.dart';

class NewsResponse {
  final List<ArticleModel> articles;
  NewsResponse({required this.articles});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      articles: (json['articles'] as List)
          .map((i) => ArticleModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
