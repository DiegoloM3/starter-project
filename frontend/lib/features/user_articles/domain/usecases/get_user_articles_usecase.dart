import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/repository/user_article_repository.dart';

class GetUserArticlesParams {
  final int limit;
  final DateTime? startAfter;

  const GetUserArticlesParams({this.limit = 10, this.startAfter});
}

class GetUserArticlesUseCase
    implements
        UseCase<DataState<List<UserArticleEntity>>, GetUserArticlesParams> {
  final UserArticleRepository _repository;

  GetUserArticlesUseCase(this._repository);

  @override
  Future<DataState<List<UserArticleEntity>>> call(
      {GetUserArticlesParams? params}) {
    return _repository.getArticles(
      limit: params?.limit ?? 10,
      startAfter: params?.startAfter,
    );
  }
}
