import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class CommunityArticleRemoteDataSource {
  Stream<List<ArticleEntity>> watchArticles();
  Future<String> publishArticle(ArticleEntity article);
}
