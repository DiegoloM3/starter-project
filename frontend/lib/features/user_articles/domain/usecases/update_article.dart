import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Use case for updating an existing article.
class UpdateArticleUseCase
    implements UseCase<DataState<UserArticleEntity>, UserArticleEntity> {
  final UserArticleRepository _userArticleRepository;

  UpdateArticleUseCase(this._userArticleRepository);

  @override
  Future<DataState<UserArticleEntity>> call({UserArticleEntity? params}) async {
    if (params == null) {
      return DataFailed(Exception('Article cannot be null'));
    }
    return await _userArticleRepository.updateArticle(params);
  }
}
