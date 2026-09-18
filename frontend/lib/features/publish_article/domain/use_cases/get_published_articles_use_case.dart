import '../../../../core/usecase/usecase.dart';
import '../entities/publishable_article.dart';
import '../repository/read_published_articles_repository.dart';

class GetPublishedArticlesUseCase
    implements UseCase<List<PublishableArticle>, void> {
  final ReadPublishedArticlesRepository _repository;

  GetPublishedArticlesUseCase(this._repository);

  @override
  Future<List<PublishableArticle>> call({void params}) {
    return _repository.getPublishedArticles();
  }
}
