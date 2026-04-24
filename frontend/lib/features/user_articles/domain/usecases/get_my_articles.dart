import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

class GetMyArticlesUseCase
    extends UseCase<List<UserArticleEntity>, String> {
  GetMyArticlesUseCase(this._repository);

  final UserArticleRepository _repository;

  @override
  Future<Either<AppFailure, List<UserArticleEntity>>> call(String authorId) {
    if (authorId.isEmpty) {
      return Future.value(
        const Left(
          AppFailure.validation(field: 'authorId', reason: 'required'),
        ),
      );
    }
    return _repository.getMyArticles(authorId);
  }
}
