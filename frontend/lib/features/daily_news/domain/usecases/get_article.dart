import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class GetArticleUseCase
    implements UseCase<Either<AppFailure, List<ArticleEntity>>, void> {
  GetArticleUseCase(this._articleRepository);

  final ArticleRepository _articleRepository;

  @override
  Future<Either<AppFailure, List<ArticleEntity>>> call({void params}) {
    return _articleRepository.getNewsArticles();
  }
}
