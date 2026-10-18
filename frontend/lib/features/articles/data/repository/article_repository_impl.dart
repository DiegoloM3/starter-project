import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article.dart';
import '../../domain/params/article_image.dart';
import '../../domain/params/publish_article_params.dart';
import '../../domain/params/update_article_params.dart';
import '../../domain/repository/article_repository.dart';
import '../data_sources/remote/article_image_remote_data_source.dart';
import '../data_sources/remote/article_remote_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource _articleDataSource;
  final ArticleImageRemoteDataSource _imageDataSource;

  ArticleRepositoryImpl(this._articleDataSource, this._imageDataSource);

  @override
  Future<DataState<List<ArticleEntity>>> getArticles() {
    return runAsDataState(() async {
      final articles = await _articleDataSource.getArticles();
      return articles.map((article) => article.toEntity()).toList();
    });
  }

  @override
  Future<DataState<ArticleEntity>> getArticle(String articleId) {
    return runAsDataState(() async => (await _articleDataSource.getArticle(articleId)).toEntity());
  }

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthors(List<String> authorIds) {
    return runAsDataState(() async {
      final articles = await _articleDataSource.getArticlesByAuthors(authorIds);
      return articles.map((article) => article.toEntity()).toList();
    });
  }

  /// The thumbnail is uploaded first, because the article must be saved with its URL.
  @override
  Future<DataState<ArticleEntity>> publishArticle(PublishArticleParams params) {
    return runAsDataState(() async {
      final thumbnailURL = await _imageDataSource.uploadImage(params.thumbnail.bytes);
      final article = await _articleDataSource.createArticle(params.draft, thumbnailURL);
      return article.toEntity();
    });
  }

  @override
  Future<DataState<ArticleEntity>> updateArticle(UpdateArticleParams params) {
    return runAsDataState(() async {
      final newThumbnail = params.newThumbnail;
      final newThumbnailURL = newThumbnail == null ? null : await _imageDataSource.uploadImage(newThumbnail.bytes);
      final article = await _articleDataSource.updateArticle(
        params.articleId,
        params.draft,
        newThumbnailURL: newThumbnailURL,
      );
      return article.toEntity();
    });
  }

  @override
  Future<DataState<void>> deleteArticle(String articleId) {
    return runAsDataState(() => _articleDataSource.deleteArticle(articleId));
  }

  @override
  Future<DataState<String>> uploadArticleImage(ArticleImage image) {
    return runAsDataState(() => _imageDataSource.uploadImage(image.bytes));
  }
}
