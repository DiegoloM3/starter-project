import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import '../repository/user_article_repository.dart';

class GetUserArticlesUseCase
    implements UseCase<DataState<List<UserArticleEntity>>, void> {
  final UserArticleRepository _repository;
  GetUserArticlesUseCase({required UserArticleRepository repository})
      : _repository = repository;

  @override
  Future<DataState<List<UserArticleEntity>>> call({void params}) {
    return _repository.getMyArticles();
  }
}
