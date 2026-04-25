import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/articles/domain/repositories/article_repository.dart';

class DeleteArticleParams {
  final String id;

  const DeleteArticleParams({required this.id});
}

class DeleteArticleUseCase
    implements UseCase<DataState<void>, DeleteArticleParams> {
  final ArticleRepository _articleRepository;

  DeleteArticleUseCase(this._articleRepository);

  @override
  Future<DataState<void>> call({DeleteArticleParams? params}) {
    return _articleRepository.deleteArticle(params!.id);
  }
}
