import '../../../../core/resources/data_state.dart';
import '../entities/community_article.dart';
import '../repository/community_article_lookup_repository.dart';

class GetCommunityArticleUseCase {
  final CommunityArticleLookupRepository _repository;

  const GetCommunityArticleUseCase(this._repository);

  Future<DataState<CommunityArticleEntity?>> call(String articleId) =>
      _repository.getPublishedArticleById(articleId);
}
