import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/community_article_entity.dart';
import '../params/community_article_params.dart';
import '../repository/community_article_repository.dart';

class CreateCommunityArticleUseCase
    implements UseCase<DataState<CommunityArticleEntity>, CreateArticleParams> {
  final CommunityArticleRepository _repository;

  CreateCommunityArticleUseCase(this._repository);

  @override
  Future<DataState<CommunityArticleEntity>> call({
    CreateArticleParams? params,
  }) => _repository.createCommunityArticle(params: params!);
}
