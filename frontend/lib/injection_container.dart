import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart';
import 'package:news_app_clean_architecture/features/comments/data/data_sources/remote/comment_firebase_service.dart';
import 'package:news_app_clean_architecture/features/comments/data/repository/comment_repository_impl.dart';
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_article_comments.dart';
import 'package:news_app_clean_architecture/features/comments/domain/usecases/post_comment.dart';
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments/comments_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_user_profile.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/create_user_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/delete_user_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_all_user_articles.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_user_articles.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/update_user_article.dart';
import 'package:news_app_clean_architecture/injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit()
/// Configures codegen DI, then registers domain use cases as fallback guards.
Future<void> configureDependencies() async {
  await sl.init();
  _registerDomainUseCases();
}

/// Domain stays annotation-free per 2.1.1, so codegen learns the use-cases
/// from the providers in `core/di/app_module.dart`. These manual
/// registrations stay as idempotent guards: whichever registration runs
/// first wins, the other is skipped.
void _registerDomainUseCases() {
  if (!sl.isRegistered<GetArticleUseCase>()) {
    sl.registerLazySingleton(
      () => GetArticleUseCase(sl<ArticleRepository>()),
    );
  }
  if (!sl.isRegistered<GetSavedArticleUseCase>()) {
    sl.registerLazySingleton(
      () => GetSavedArticleUseCase(sl<ArticleRepository>()),
    );
  }
  if (!sl.isRegistered<SaveArticleUseCase>()) {
    sl.registerLazySingleton(
      () => SaveArticleUseCase(sl<ArticleRepository>()),
    );
  }
  if (!sl.isRegistered<RemoveArticleUseCase>()) {
    sl.registerLazySingleton(
      () => RemoveArticleUseCase(sl<ArticleRepository>()),
    );
  }
  if (!sl.isRegistered<GetAllUserArticles>()) {
    sl.registerLazySingleton(
      () => GetAllUserArticles(sl<UserArticleRepository>()),
    );
  }
  if (!sl.isRegistered<GetUserArticles>()) {
    sl.registerLazySingleton(
      () => GetUserArticles(sl<UserArticleRepository>()),
    );
  }
  if (!sl.isRegistered<CreateUserArticle>()) {
    sl.registerLazySingleton(
      () => CreateUserArticle(sl<UserArticleRepository>()),
    );
  }
  if (!sl.isRegistered<UpdateUserArticle>()) {
    sl.registerLazySingleton(
      () => UpdateUserArticle(sl<UserArticleRepository>()),
    );
  }
  if (!sl.isRegistered<DeleteUserArticle>()) {
    sl.registerLazySingleton(
      () => DeleteUserArticle(sl<UserArticleRepository>()),
    );
  }
  if (!sl.isRegistered<LoginUseCase>()) {
    sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<RegisterUseCase>()) {
    sl.registerLazySingleton(
      () => RegisterUseCase(
        sl<AuthRepository>(),
        sl<UserProfileRepository>(),
      ),
    );
  }
  if (!sl.isRegistered<LogoutUseCase>()) {
    sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<GetCurrentUserUseCase>()) {
    sl.registerLazySingleton(
      () => GetCurrentUserUseCase(sl<AuthRepository>()),
    );
  }
  if (!sl.isRegistered<GetAuthorProfile>()) {
    sl.registerLazySingleton(
      () => GetAuthorProfile(sl<UserProfileRepository>()),
    );
  }
  if (!sl.isRegistered<UpdateUserProfile>()) {
    sl.registerLazySingleton(
      () => UpdateUserProfile(
        sl<AuthRepository>(),
        sl<UserProfileRepository>(),
      ),
    );
  }
  if (!sl.isRegistered<CommentFirebaseService>()) {
    sl.registerLazySingleton(() => CommentFirebaseService());
  }
  if (!sl.isRegistered<CommentRepository>()) {
    sl.registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(sl<CommentFirebaseService>()),
    );
  }
  if (!sl.isRegistered<GetArticleComments>()) {
    sl.registerLazySingleton(
      () => GetArticleComments(sl<CommentRepository>()),
    );
  }
  if (!sl.isRegistered<PostComment>()) {
    sl.registerLazySingleton(() => PostComment(sl<CommentRepository>()));
  }
  if (!sl.isRegistered<DeleteComment>()) {
    sl.registerLazySingleton(() => DeleteComment(sl<CommentRepository>()));
  }
  if (!sl.isRegistered<CommentsBloc>()) {
    sl.registerFactory(
      () => CommentsBloc(
        sl<GetArticleComments>(),
        sl<PostComment>(),
        sl<DeleteComment>(),
        sl<GetCurrentUserUseCase>(),
      ),
    );
  }
}
