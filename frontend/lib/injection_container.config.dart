// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:news_app_clean_architecture/core/di/app_module.dart' as _i904;
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_firebase_service.dart'
    as _i123;
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/user_profile_firebase_service.dart'
    as _i1017;
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart'
    as _i884;
import 'package:news_app_clean_architecture/features/auth/data/repository/user_profile_repository_impl.dart'
    as _i679;
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart'
    as _i544;
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart'
    as _i706;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart'
    as _i557;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i119;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/login_usecase.dart'
    as _i616;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/logout_usecase.dart'
    as _i537;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/register_usecase.dart'
    as _i836;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_user_profile.dart'
    as _i269;
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart'
    as _i730;
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/profile/profile_bloc.dart'
    as _i298;
import 'package:news_app_clean_architecture/features/comments/data/data_sources/remote/comment_firebase_service.dart'
    as _i967;
import 'package:news_app_clean_architecture/features/comments/data/repository/comment_repository_impl.dart'
    as _i11;
import 'package:news_app_clean_architecture/features/comments/domain/repository/comment_repository.dart'
    as _i641;
import 'package:news_app_clean_architecture/features/comments/domain/usecases/delete_comment.dart'
    as _i43;
import 'package:news_app_clean_architecture/features/comments/domain/usecases/get_article_comments.dart'
    as _i473;
import 'package:news_app_clean_architecture/features/comments/domain/usecases/post_comment.dart'
    as _i469;
import 'package:news_app_clean_architecture/features/comments/presentation/bloc/comments/comments_bloc.dart'
    as _i717;
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart'
    as _i924;
import 'package:news_app_clean_architecture/features/news/data/data_sources/remote/news_api_service.dart'
    as _i893;
import 'package:news_app_clean_architecture/features/news/data/data_sources/remote/user_articles_firebase_service.dart'
    as _i1;
import 'package:news_app_clean_architecture/features/news/data/repository/article_repository_impl.dart'
    as _i865;
import 'package:news_app_clean_architecture/features/news/data/repository/user_article_repository_impl.dart'
    as _i401;
import 'package:news_app_clean_architecture/features/news/domain/repository/article_repository.dart'
    as _i862;
import 'package:news_app_clean_architecture/features/news/domain/repository/user_article_repository.dart'
    as _i37;
import 'package:news_app_clean_architecture/features/news/domain/usecases/create_user_article.dart'
    as _i508;
import 'package:news_app_clean_architecture/features/news/domain/usecases/delete_user_article.dart'
    as _i173;
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_all_user_articles.dart'
    as _i629;
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_article.dart'
    as _i838;
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_saved_article.dart'
    as _i572;
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_user_articles.dart'
    as _i946;
import 'package:news_app_clean_architecture/features/news/domain/usecases/remove_article.dart'
    as _i1042;
import 'package:news_app_clean_architecture/features/news/domain/usecases/save_article.dart'
    as _i150;
import 'package:news_app_clean_architecture/features/news/domain/usecases/update_user_article.dart'
    as _i442;
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart'
    as _i7;
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/community/community_articles_bloc.dart'
    as _i785;
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/create/create_article_bloc.dart'
    as _i505;
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/edit/edit_article_bloc.dart'
    as _i229;
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/local/local_article_bloc.dart'
    as _i8;
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_bloc.dart'
    as _i933;
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/user/user_articles_bloc.dart'
    as _i413;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.factory<_i123.AuthFirebaseService>(() => _i123.AuthFirebaseService());
    gh.factory<_i1017.UserProfileFirebaseService>(
        () => _i1017.UserProfileFirebaseService());
    gh.factory<_i967.CommentFirebaseService>(
        () => _i967.CommentFirebaseService());
    gh.factory<_i1.UserArticlesFirebaseService>(
        () => _i1.UserArticlesFirebaseService());
    gh.singleton<_i361.Dio>(() => appModule.dio);
    gh.singleton<_i924.AppDatabase>(() => appModule.appDatabase);
    gh.lazySingleton<_i544.AuthRepository>(
        () => _i884.AuthRepositoryImpl(gh<_i123.AuthFirebaseService>()));
    gh.singleton<_i893.NewsApiService>(
        () => appModule.newsApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i706.UserProfileRepository>(() =>
        _i679.UserProfileRepositoryImpl(
            gh<_i1017.UserProfileFirebaseService>()));
    gh.lazySingleton<_i836.RegisterUseCase>(() => appModule.registerUseCase(
          gh<_i544.AuthRepository>(),
          gh<_i706.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i269.UpdateUserProfile>(() => appModule.updateUserProfile(
          gh<_i544.AuthRepository>(),
          gh<_i706.UserProfileRepository>(),
        ));
    gh.lazySingleton<_i37.UserArticleRepository>(() =>
        _i401.UserArticleRepositoryImpl(gh<_i1.UserArticlesFirebaseService>()));
    gh.lazySingleton<_i641.CommentRepository>(
        () => _i11.CommentRepositoryImpl(gh<_i967.CommentFirebaseService>()));
    gh.lazySingleton<_i473.GetArticleComments>(
        () => appModule.getArticleComments(gh<_i641.CommentRepository>()));
    gh.lazySingleton<_i469.PostComment>(
        () => appModule.postComment(gh<_i641.CommentRepository>()));
    gh.lazySingleton<_i43.DeleteComment>(
        () => appModule.deleteComment(gh<_i641.CommentRepository>()));
    gh.lazySingleton<_i557.GetAuthorProfile>(
        () => appModule.getAuthorProfile(gh<_i706.UserProfileRepository>()));
    gh.lazySingleton<_i862.ArticleRepository>(() => _i865.ArticleRepositoryImpl(
          gh<_i893.NewsApiService>(),
          gh<_i924.AppDatabase>(),
        ));
    gh.lazySingleton<_i616.LoginUseCase>(
        () => appModule.loginUseCase(gh<_i544.AuthRepository>()));
    gh.lazySingleton<_i537.LogoutUseCase>(
        () => appModule.logoutUseCase(gh<_i544.AuthRepository>()));
    gh.lazySingleton<_i119.GetCurrentUserUseCase>(
        () => appModule.getCurrentUserUseCase(gh<_i544.AuthRepository>()));
    gh.lazySingleton<_i629.GetAllUserArticles>(
        () => appModule.getAllUserArticles(gh<_i37.UserArticleRepository>()));
    gh.lazySingleton<_i946.GetUserArticles>(
        () => appModule.getUserArticles(gh<_i37.UserArticleRepository>()));
    gh.lazySingleton<_i508.CreateUserArticle>(
        () => appModule.createUserArticle(gh<_i37.UserArticleRepository>()));
    gh.lazySingleton<_i442.UpdateUserArticle>(
        () => appModule.updateUserArticle(gh<_i37.UserArticleRepository>()));
    gh.lazySingleton<_i173.DeleteUserArticle>(
        () => appModule.deleteUserArticle(gh<_i37.UserArticleRepository>()));
    gh.factory<_i413.UserArticlesBloc>(() => _i413.UserArticlesBloc(
          gh<_i946.GetUserArticles>(),
          gh<_i119.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i785.CommunityArticlesBloc>(
        () => _i785.CommunityArticlesBloc(gh<_i629.GetAllUserArticles>()));
    gh.factory<_i229.EditArticleBloc>(() => _i229.EditArticleBloc(
          gh<_i442.UpdateUserArticle>(),
          gh<_i173.DeleteUserArticle>(),
          gh<_i119.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i730.AuthBloc>(() => _i730.AuthBloc(
          loginUseCase: gh<_i616.LoginUseCase>(),
          registerUseCase: gh<_i836.RegisterUseCase>(),
          logoutUseCase: gh<_i537.LogoutUseCase>(),
          getCurrentUserUseCase: gh<_i119.GetCurrentUserUseCase>(),
        ));
    gh.lazySingleton<_i838.GetArticleUseCase>(
        () => appModule.getArticleUseCase(gh<_i862.ArticleRepository>()));
    gh.lazySingleton<_i572.GetSavedArticleUseCase>(
        () => appModule.getSavedArticleUseCase(gh<_i862.ArticleRepository>()));
    gh.lazySingleton<_i150.SaveArticleUseCase>(
        () => appModule.saveArticleUseCase(gh<_i862.ArticleRepository>()));
    gh.lazySingleton<_i1042.RemoveArticleUseCase>(
        () => appModule.removeArticleUseCase(gh<_i862.ArticleRepository>()));
    gh.factory<_i505.CreateArticleBloc>(() => _i505.CreateArticleBloc(
          gh<_i508.CreateUserArticle>(),
          gh<_i119.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i8.LocalArticleBloc>(() => _i8.LocalArticleBloc(
          gh<_i572.GetSavedArticleUseCase>(),
          gh<_i150.SaveArticleUseCase>(),
          gh<_i1042.RemoveArticleUseCase>(),
        ));
    gh.factory<_i7.AuthorAvatarCubit>(
        () => _i7.AuthorAvatarCubit(gh<_i557.GetAuthorProfile>()));
    gh.factory<_i717.CommentsBloc>(() => _i717.CommentsBloc(
          gh<_i473.GetArticleComments>(),
          gh<_i469.PostComment>(),
          gh<_i43.DeleteComment>(),
          gh<_i119.GetCurrentUserUseCase>(),
        ));
    gh.factory<_i933.RemoteArticlesBloc>(
        () => _i933.RemoteArticlesBloc(gh<_i838.GetArticleUseCase>()));
    gh.factory<_i298.ProfileBloc>(() => _i298.ProfileBloc(
          gh<_i119.GetCurrentUserUseCase>(),
          gh<_i269.UpdateUserProfile>(),
        ));
    return this;
  }
}

class _$AppModule extends _i904.AppModule {}
