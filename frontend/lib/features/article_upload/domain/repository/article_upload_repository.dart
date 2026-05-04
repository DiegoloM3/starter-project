import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/publish_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/save_draft_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/toggle_favorite_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/update_article_params.dart';

abstract class ArticleUploadRepository {
  Future<DataState<JournalistArticleEntity>> publish(
      PublishArticleParams params);

  Future<DataState<JournalistArticleEntity>> update(
      UpdateArticleParams params);

  Future<DataState<void>> delete(DeleteArticleParams params);

  Stream<List<JournalistArticleEntity>> watchByAuthor(String userId);

  Stream<List<JournalistArticleEntity>> watchCommunityFeed({int limit});

  Stream<JournalistArticleEntity?> watchById(String articleId);

  Future<DataState<void>> toggleFavorite(ToggleFavoriteParams params);

  Stream<List<String>> watchFavoriteArticleIds(String userId);

  Future<DataState<int>> saveDraft(SaveDraftParams params);

  Stream<List<DraftArticleEntity>> watchDrafts();

  Future<DataState<DraftArticleEntity?>> getDraftById(int draftId);

  Future<DataState<void>> deleteDraft(DraftIdParams params);
}
