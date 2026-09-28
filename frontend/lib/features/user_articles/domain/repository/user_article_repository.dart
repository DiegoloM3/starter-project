import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/delete_user_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_user_article_params.dart';

abstract class UserArticleRepository {
  Future<DataState<void>> uploadArticle(UploadUserArticleParams params);
  Future<DataState<List<UserArticleEntity>>> getMyArticles();
  Future<DataState<void>> deleteArticle(DeleteUserArticleParams params);
}
