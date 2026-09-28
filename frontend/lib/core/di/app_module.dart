import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_user_profile.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/create_user_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_all_user_articles.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/delete_user_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_article_comments.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/post_comment.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/update_user_article.dart';

@module
/// Injectable module wiring third-party clients and domain use cases.
abstract class AppModule {
  @singleton
  /// Provides the shared HTTP client.
  Dio get dio => Dio();

  @singleton
  /// Provides the news API client over [dio].
  NewsApiService newsApiService(Dio dio) => NewsApiService(dio);

  /// AppDatabase is synchronous in Drift — no async builder needed.
  @singleton
  /// Provides the local Drift database.
  AppDatabase get appDatabase => AppDatabase();

  /// Domain stays annotation-free per 2.1.1, so its use-cases are exposed
  /// to codegen here. Scopes mirror the manual guards in
  /// `injection_container.dart`, which remain as idempotent fallback.
  @lazySingleton
  LoginUseCase loginUseCase(AuthRepository repo) => LoginUseCase(repo);

  @lazySingleton
  RegisterUseCase registerUseCase(
    AuthRepository authRepo,
    UserProfileRepository profileRepo,
  ) =>
      RegisterUseCase(authRepo, profileRepo);

  @lazySingleton
  LogoutUseCase logoutUseCase(AuthRepository repo) => LogoutUseCase(repo);

  @lazySingleton
  GetCurrentUserUseCase getCurrentUserUseCase(AuthRepository repo) =>
      GetCurrentUserUseCase(repo);

  @lazySingleton
  UpdateUserProfile updateUserProfile(
    AuthRepository authRepo,
    UserProfileRepository profileRepo,
  ) =>
      UpdateUserProfile(authRepo, profileRepo);

  @lazySingleton
  GetAuthorProfile getAuthorProfile(UserProfileRepository repo) =>
      GetAuthorProfile(repo);

  @lazySingleton
  GetArticleUseCase getArticleUseCase(ArticleRepository repo) =>
      GetArticleUseCase(repo);

  @lazySingleton
  GetSavedArticleUseCase getSavedArticleUseCase(ArticleRepository repo) =>
      GetSavedArticleUseCase(repo);

  @lazySingleton
  SaveArticleUseCase saveArticleUseCase(ArticleRepository repo) =>
      SaveArticleUseCase(repo);

  @lazySingleton
  RemoveArticleUseCase removeArticleUseCase(ArticleRepository repo) =>
      RemoveArticleUseCase(repo);

  @lazySingleton
  GetAllUserArticles getAllUserArticles(UserArticleRepository repo) =>
      GetAllUserArticles(repo);

  @lazySingleton
  GetUserArticles getUserArticles(UserArticleRepository repo) =>
      GetUserArticles(repo);

  @lazySingleton
  CreateUserArticle createUserArticle(UserArticleRepository repo) =>
      CreateUserArticle(repo);

  @lazySingleton
  UpdateUserArticle updateUserArticle(UserArticleRepository repo) =>
      UpdateUserArticle(repo);

  @lazySingleton
  DeleteUserArticle deleteUserArticle(UserArticleRepository repo) =>
      DeleteUserArticle(repo);

  @lazySingleton
  GetArticleComments getArticleComments(CommentRepository repo) =>
      GetArticleComments(repo);

  @lazySingleton
  PostComment postComment(CommentRepository repo) => PostComment(repo);

  @lazySingleton
  DeleteComment deleteComment(CommentRepository repo) => DeleteComment(repo);
}
