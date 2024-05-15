import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class RemoteArticlesEvent extends Equatable {
  final ArticleEntity? article;

  const RemoteArticlesEvent({this.article});
  @override
  List<Object> get props => [article!];
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class AddArticle extends RemoteArticlesEvent {
  const AddArticle(ArticleEntity article) : super(article: article);
}
