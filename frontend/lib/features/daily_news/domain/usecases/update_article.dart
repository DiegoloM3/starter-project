import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/firestore_article_repository.dart';

class UpdateArticleParams {
  final ArticleEntity article;
  final List<String> newImagePaths;
  final List<String> existingImageUrls;

  const UpdateArticleParams({
    required this.article,
    required this.newImagePaths,
    required this.existingImageUrls,
  });
}

class UpdateArticleUseCase
    implements UseCase<DataState<ArticleEntity>, UpdateArticleParams> {
  final FirestoreArticleRepository _repository;

  UpdateArticleUseCase(this._repository);

  @override
  Future<DataState<ArticleEntity>> call({UpdateArticleParams? params}) {
    return _repository.updateArticle(
      params!.article,
      params.newImagePaths,
      params.existingImageUrls,
    );
  }
}
