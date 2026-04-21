import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/params/upload_article_params.dart';

abstract class UserArticleRepository {
  Future<UserArticleEntity> uploadArticle(UploadArticleParams params);

  Future<UserArticleEntity> updateArticle(UpdateArticleParams params);

  Future<List<UserArticleEntity>> getMyArticles();

  Future<List<UserArticleEntity>> getAllUserArticles();

  Future<void> deleteArticle(String articleId);

  Future<void> refreshAuthorSnapshotsForCurrentUser();
}
