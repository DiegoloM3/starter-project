import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/paginated_result.dart';

import '../entities/community_article_entity.dart';
import '../params/community_article_params.dart';

abstract class CommunityArticleRepository {
  /// Fetches a paginated list of all community articles, ordered by newest first.
  ///
  /// Uses cursor-based pagination via [CommunityArticleParams.lastDocumentId].
  Future<DataState<PaginatedResult<CommunityArticleEntity>>>
  getCommunityArticles({required CommunityArticleParams params});

  /// Watches the newest community articles in realtime.
  Stream<DataState<List<CommunityArticleEntity>>> watchCommunityArticles({
    required CommunityArticleParams params,
  });

  /// Fetches a single community article by its Firestore document [id].
  Future<DataState<CommunityArticleEntity>> getCommunityArticleById({
    required String id,
  });

  /// Fetches all articles created by a specific [userId].
  Future<DataState<List<CommunityArticleEntity>>> getUserArticles({
    required String userId,
  });

  /// Creates a new community article. Handles image upload if [CreateArticleParams.imageFile] is set.
  Future<DataState<CommunityArticleEntity>> createCommunityArticle({
    required CreateArticleParams params,
  });

  /// Updates an existing community article. Only provided fields are changed.
  Future<DataState<CommunityArticleEntity>> updateCommunityArticle({
    required UpdateArticleParams params,
  });

  /// Deletes a community article and its associated Storage image (if any).
  Future<DataState<void>> deleteCommunityArticle({required String id});
}
