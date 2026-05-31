import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/community_article_entity.dart';
import '../params/community_article_params.dart';
import '../repository/community_article_repository.dart';

class GetUserArticlesUseCase
    implements
        UseCase<
          DataState<List<CommunityArticleEntity>>,
          GetUserArticlesParams
        > {
  final CommunityArticleRepository _repository;

  GetUserArticlesUseCase(this._repository);

  @override
  Future<DataState<List<CommunityArticleEntity>>> call({
    GetUserArticlesParams? params,
  }) => _repository.getUserArticles(userId: params!.userId);
}
