import '../../../../domain/entities/article.dart';

abstract class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class PublishArticle extends RemoteArticlesEvent {
  final ArticleEntity article;

  const PublishArticle(this.article);
}