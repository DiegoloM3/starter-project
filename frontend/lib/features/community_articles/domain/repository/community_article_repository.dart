import '../../../../core/resources/data_state.dart';
import '../entities/article_image.dart';
import '../entities/community_article.dart';
import '../params/publish_article_params.dart';

abstract class CommunityArticleRepository {
  Future<DataState<List<CommunityArticleEntity>>> getPublishedArticles();

  Future<DataState<CommunityArticleEntity>> publishArticle(
    PublishArticleParams params,
  );

  Future<DataState<ArticleImageEntity?>> pickImage();
}
