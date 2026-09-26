import '../../../../core/resources/data_state.dart';
import '../entities/article_image.dart';
import '../repository/community_article_repository.dart';

class PickArticleImageUseCase {
  final CommunityArticleRepository _repository;

  const PickArticleImageUseCase(this._repository);

  Future<DataState<ArticleImageEntity?>> call() => _repository.pickImage();
}
