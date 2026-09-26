import '../../../../core/resources/data_state.dart';
import '../../domain/entities/article_image.dart';
import '../../domain/entities/community_article.dart';
import '../../domain/params/publish_article_params.dart';
import '../../domain/repository/community_article_repository.dart';
import '../../domain/repository/community_article_lookup_repository.dart';
import '../data_sources/article_image_picker_data_source.dart';
import '../data_sources/community_firestore_data_source.dart';

class CommunityArticleRepositoryImpl
    implements CommunityArticleRepository, CommunityArticleLookupRepository {
  final CommunityFirestoreDataSource _firestore;
  final ArticleImagePickerDataSource _imagePicker;

  const CommunityArticleRepositoryImpl(this._firestore, this._imagePicker);

  @override
  Future<DataState<List<CommunityArticleEntity>>> getPublishedArticles() async {
    try {
      return DataSuccess(await _firestore.getPublishedArticles());
    } catch (error) {
      return DataFailed(
          AppFailure('Unable to load community articles.', cause: error));
    }
  }

  @override
  Future<DataState<CommunityArticleEntity?>> getPublishedArticleById(
    String articleId,
  ) async {
    try {
      return DataSuccess(await _firestore.getPublishedArticleById(articleId));
    } catch (error) {
      return DataFailed(
        AppFailure('Unable to load the shared article.', cause: error),
      );
    }
  }

  @override
  Future<DataState<CommunityArticleEntity>> publishArticle(
    PublishArticleParams params,
  ) async {
    try {
      return DataSuccess(await _firestore.publishArticle(params));
    } catch (error) {
      return DataFailed(AppFailure(_messageFor(error), cause: error));
    }
  }

  @override
  Future<DataState<ArticleImageEntity?>> pickImage() async {
    try {
      return DataSuccess(await _imagePicker.pickImage());
    } catch (error) {
      return DataFailed(
          AppFailure('Unable to select that image.', cause: error));
    }
  }

  String _messageFor(Object error) {
    final message = error.toString();
    if (message.contains('Sign in')) return 'Sign in before publishing.';
    return 'Article could not be published. Please try again.';
  }
}
