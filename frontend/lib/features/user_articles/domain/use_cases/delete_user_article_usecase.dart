import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_user_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

class DeleteUserArticleUseCase
    implements UseCase<DataState<void>, DeleteUserArticleParams> {
  final UserArticleRepository _repository;
  DeleteUserArticleUseCase({required UserArticleRepository repository})
      : _repository = repository;

  @override
  Future<DataState<void>> call({DeleteUserArticleParams? params}) {
    return _repository.deleteArticle(params!);
  }
}
