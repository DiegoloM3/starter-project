import '../../../../core/resources/data_state.dart';
import '../entities/community_article.dart';

/// Reads one published article for a shared deep link.
abstract class CommunityArticleLookupRepository {
  Future<DataState<CommunityArticleEntity?>> getPublishedArticleById(
    String articleId,
  );
}
