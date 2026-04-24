import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleRepository {
  // Remote
  Future<Either<AppFailure, List<ArticleEntity>>> getNewsArticles();

  // Local
  Future<Either<AppFailure, List<ArticleEntity>>> getSavedArticles();

  Future<Either<AppFailure, Unit>> saveArticle(ArticleEntity article);

  Future<Either<AppFailure, Unit>> removeArticle(ArticleEntity article);
}
