import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Use case for publishing a draft article.
class PublishArticleUseCase
    implements UseCase<DataState<UserArticleEntity>, String> {
  final UserArticleRepository _userArticleRepository;

  PublishArticleUseCase(this._userArticleRepository);

  @override
  Future<DataState<UserArticleEntity>> call({String? params}) async {
    if (params == null || params.isEmpty) {
      return DataFailed(Exception('Article ID cannot be null or empty'));
    }
    return await _userArticleRepository.publishArticle(params);
  }
}
