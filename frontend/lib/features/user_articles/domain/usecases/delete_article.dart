import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

class DeleteArticleUseCase extends UseCase<Unit, DeleteArticleParams> {
  DeleteArticleUseCase(this._repository);

  final UserArticleRepository _repository;

  @override
  Future<Either<AppFailure, Unit>> call(DeleteArticleParams params) {
    if (params.id.isEmpty) {
      return Future.value(
        const Left(AppFailure.validation(field: 'id', reason: 'required')),
      );
    }
    return _repository.deleteArticle(params);
  }
}
