import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/community_article_entity.dart';
import '../params/community_article_params.dart';
import '../repository/community_article_repository.dart';

class WatchCommunityArticlesUseCase
    implements
        StreamUseCase<
          DataState<List<CommunityArticleEntity>>,
          CommunityArticleParams
        > {
  const WatchCommunityArticlesUseCase(this._repository);

  final CommunityArticleRepository _repository;

  @override
  Stream<DataState<List<CommunityArticleEntity>>> call({
    CommunityArticleParams params = const CommunityArticleParams(),
  }) => _repository.watchCommunityArticles(params: params);
}
