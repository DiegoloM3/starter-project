import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Use case for getting all published articles.
class GetPublishedArticlesUseCase
    implements UseCaseNoParams<DataState<List<UserArticleEntity>>> {
  final UserArticleRepository _userArticleRepository;

  GetPublishedArticlesUseCase(this._userArticleRepository);

  @override
  Future<DataState<List<UserArticleEntity>>> call() async {
    return await _userArticleRepository.getPublishedArticles();
  }
}
