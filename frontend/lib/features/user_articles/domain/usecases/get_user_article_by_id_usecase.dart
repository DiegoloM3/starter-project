import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

/// Takes the article id directly as Params -- a single value doesn't need a
/// dedicated wrapper class, same convention daily_news already uses for
/// RemoveArticleUseCase (Params = ArticleEntity, no wrapper either).
class GetUserArticleByIdUseCase
    implements UseCase<DataState<UserArticleEntity>, String> {
  final UserArticleRepository _repository;

  GetUserArticleByIdUseCase(this._repository);

  @override
  Future<DataState<UserArticleEntity>> call({String? params}) {
    if (params == null) {
      return Future.value(DataFailed(Exception('Missing article id')));
    }
    return _repository.getArticleById(params);
  }
}
