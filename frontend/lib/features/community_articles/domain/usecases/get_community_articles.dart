import '../../../../core/resources/data_state.dart';
import '../entities/community_article.dart';
import '../repository/community_article_repository.dart';

class GetCommunityArticlesUseCase {
  final CommunityArticleRepository _repository;

  const GetCommunityArticlesUseCase(this._repository);

  Future<DataState<List<CommunityArticleEntity>>> call() {
    return _repository.getPublishedArticles();
  }
}
