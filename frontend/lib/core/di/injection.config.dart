// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:news_app_clean_architecture/core/di/modules/infrastructure_module.dart'
    as _i959;
import 'package:news_app_clean_architecture/features/auth/data/datasources/firebase_auth.dart'
    as _i688;
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart'
    as _i884;
import 'package:news_app_clean_architecture/features/auth/di/auth_module.dart'
    as _i360;
import 'package:news_app_clean_architecture/features/auth/domain/domain.dart'
    as _i944;
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart'
    as _i887;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_auth_stream.dart'
    as _i353;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart'
    as _i178;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_email.dart'
    as _i199;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google.dart'
    as _i690;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart'
    as _i847;
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up_with_email.dart'
    as _i94;
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart'
    as _i860;
import 'package:news_app_clean_architecture/features/bookmarks/data/datasources/local/app_database.dart'
    as _i18;
import 'package:news_app_clean_architecture/features/bookmarks/data/datasources/local/local_bookmarks_datasource.dart'
    as _i459;
import 'package:news_app_clean_architecture/features/bookmarks/data/repository/bookmark_repository_impl.dart'
    as _i297;
import 'package:news_app_clean_architecture/features/bookmarks/di/bookmarks_module.dart'
    as _i1000;
import 'package:news_app_clean_architecture/features/bookmarks/domain/repository/bookmark_repository.dart'
    as _i431;
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/add_bookmark.dart'
    as _i209;
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/get_bookmarks.dart'
    as _i657;
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/is_bookmarked.dart'
    as _i636;
import 'package:news_app_clean_architecture/features/bookmarks/domain/usecases/remove_bookmark.dart'
    as _i293;
import 'package:news_app_clean_architecture/features/bookmarks/presentation/bloc/bookmark_bloc.dart'
    as _i376;
import 'package:news_app_clean_architecture/features/community_articles/data/datasources/local/article_image_picker_data_source.dart'
    as _i1015;
import 'package:news_app_clean_architecture/features/community_articles/data/datasources/remote/firebase_storage_datasource.dart'
    as _i492;
import 'package:news_app_clean_architecture/features/community_articles/data/datasources/remote/firestore_articles_datasource.dart'
    as _i540;
import 'package:news_app_clean_architecture/features/community_articles/data/repository/article_image_picker_repository_impl.dart'
    as _i5;
import 'package:news_app_clean_architecture/features/community_articles/data/repository/community_article_repository_impl.dart'
    as _i37;
import 'package:news_app_clean_architecture/features/community_articles/di/community_articles_module.dart'
    as _i271;
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/article_image_picker_repository.dart'
    as _i578;
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart'
    as _i413;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/create_community_article.dart'
    as _i587;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/delete_community_article.dart'
    as _i1061;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_article_by_id.dart'
    as _i1055;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_community_articles.dart'
    as _i334;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/get_user_articles.dart'
    as _i736;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/pick_cover_image.dart'
    as _i244;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/update_community_article.dart'
    as _i181;
import 'package:news_app_clean_architecture/features/community_articles/domain/usecases/watch_community_articles.dart'
    as _i426;
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_client.dart'
    as _i993;
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart'
    as _i552;
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart'
    as _i1071;
import 'package:news_app_clean_architecture/features/daily_news/di/daily_news_module.dart'
    as _i1048;
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart'
    as _i458;
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart'
    as _i579;
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/remote_article_bloc.dart'
    as _i757;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final infrastructureModule = _$InfrastructureModule();
    final communityArticlesModule = _$CommunityArticlesModule();
    final bookmarksModule = _$BookmarksModule();
    final authModule = _$AuthModule();
    final dailyNewsModule = _$DailyNewsModule();
    gh.singleton<_i18.AppDatabase>(() => infrastructureModule.appDatabase);
    gh.singleton<_i361.Dio>(() => infrastructureModule.dio);
    gh.singleton<_i59.FirebaseAuth>(() => infrastructureModule.firebaseAuth);
    gh.singleton<_i974.FirebaseFirestore>(
      () => infrastructureModule.firebaseFirestore,
    );
    gh.singleton<_i457.FirebaseStorage>(
      () => infrastructureModule.firebaseStorage,
    );
    gh.lazySingleton<_i183.ImagePicker>(
      () => communityArticlesModule.imagePicker(),
    );
    gh.lazySingleton<_i688.FirebaseAuthDataSource>(
      () => _i688.FirebaseAuthDataSource(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.singleton<_i993.NewsApiClient>(
      () => infrastructureModule.newsApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i459.LocalBookmarksDataSource>(
      () => _i459.LocalBookmarksDataSource(gh<_i18.AppDatabase>()),
    );
    gh.lazySingleton<_i1015.ArticleImagePickerDataSource>(
      () => _i1015.ArticleImagePickerDataSource(gh<_i183.ImagePicker>()),
    );
    gh.lazySingleton<_i944.AuthRepository>(
      () => _i884.AuthRepositoryImpl(gh<_i688.FirebaseAuthDataSource>()),
    );
    gh.lazySingleton<_i431.BookmarkRepository>(
      () => _i297.BookmarkRepositoryImpl(gh<_i459.LocalBookmarksDataSource>()),
    );
    gh.lazySingleton<_i552.NewsApiService>(
      () => _i552.NewsApiService(gh<_i993.NewsApiClient>()),
    );
    gh.lazySingleton<_i492.FirebaseStorageDataSource>(
      () => _i492.FirebaseStorageDataSource(gh<_i457.FirebaseStorage>()),
    );
    gh.lazySingleton<_i578.ArticleImagePickerRepository>(
      () => _i5.ArticleImagePickerRepositoryImpl(
        gh<_i1015.ArticleImagePickerDataSource>(),
      ),
    );
    gh.lazySingleton<_i540.FirestoreArticlesDataSource>(
      () => _i540.FirestoreArticlesDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i458.ArticleRepository>(
      () => _i1071.ArticleRepositoryImpl(gh<_i552.NewsApiService>()),
    );
    gh.lazySingleton<_i657.WatchBookmarksUseCase>(
      () =>
          bookmarksModule.watchBookmarksUseCase(gh<_i431.BookmarkRepository>()),
    );
    gh.lazySingleton<_i209.AddBookmarkUseCase>(
      () => bookmarksModule.addBookmarkUseCase(gh<_i431.BookmarkRepository>()),
    );
    gh.lazySingleton<_i293.RemoveBookmarkUseCase>(
      () =>
          bookmarksModule.removeBookmarkUseCase(gh<_i431.BookmarkRepository>()),
    );
    gh.lazySingleton<_i636.IsBookmarkedUseCase>(
      () => bookmarksModule.isBookmarkedUseCase(gh<_i431.BookmarkRepository>()),
    );
    gh.lazySingleton<_i199.SignInWithEmail>(
      () => authModule.signInWithEmail(gh<_i887.AuthRepository>()),
    );
    gh.lazySingleton<_i94.SignUpWithEmail>(
      () => authModule.signUpWithEmail(gh<_i887.AuthRepository>()),
    );
    gh.lazySingleton<_i690.SignInWithGoogle>(
      () => authModule.signInWithGoogle(gh<_i887.AuthRepository>()),
    );
    gh.lazySingleton<_i847.SignOut>(
      () => authModule.signOut(gh<_i887.AuthRepository>()),
    );
    gh.lazySingleton<_i178.GetCurrentUser>(
      () => authModule.getCurrentUser(gh<_i887.AuthRepository>()),
    );
    gh.lazySingleton<_i353.GetAuthStream>(
      () => authModule.getAuthStream(gh<_i887.AuthRepository>()),
    );
    gh.factory<_i860.AuthBloc>(
      () => _i860.AuthBloc(
        gh<_i944.SignInWithEmail>(),
        gh<_i944.SignUpWithEmail>(),
        gh<_i944.SignInWithGoogle>(),
        gh<_i944.SignOut>(),
        gh<_i944.GetAuthStream>(),
      ),
    );
    gh.lazySingleton<_i579.GetArticleUseCase>(
      () => dailyNewsModule.getArticleUseCase(gh<_i458.ArticleRepository>()),
    );
    gh.lazySingleton<_i413.CommunityArticleRepository>(
      () => _i37.CommunityArticleRepositoryImpl(
        gh<_i540.FirestoreArticlesDataSource>(),
        gh<_i492.FirebaseStorageDataSource>(),
      ),
    );
    gh.lazySingleton<_i244.PickCoverImageUseCase>(
      () => communityArticlesModule.pickCoverImageUseCase(
        gh<_i578.ArticleImagePickerRepository>(),
      ),
    );
    gh.factory<_i376.BookmarkBloc>(
      () => _i376.BookmarkBloc(
        gh<_i657.WatchBookmarksUseCase>(),
        gh<_i209.AddBookmarkUseCase>(),
        gh<_i293.RemoveBookmarkUseCase>(),
      ),
    );
    gh.lazySingleton<_i334.GetCommunityArticlesUseCase>(
      () => communityArticlesModule.getCommunityArticlesUseCase(
        gh<_i413.CommunityArticleRepository>(),
      ),
    );
    gh.lazySingleton<_i426.WatchCommunityArticlesUseCase>(
      () => communityArticlesModule.watchCommunityArticlesUseCase(
        gh<_i413.CommunityArticleRepository>(),
      ),
    );
    gh.lazySingleton<_i1055.GetCommunityArticleByIdUseCase>(
      () => communityArticlesModule.getCommunityArticleByIdUseCase(
        gh<_i413.CommunityArticleRepository>(),
      ),
    );
    gh.lazySingleton<_i736.GetUserArticlesUseCase>(
      () => communityArticlesModule.getUserArticlesUseCase(
        gh<_i413.CommunityArticleRepository>(),
      ),
    );
    gh.lazySingleton<_i587.CreateCommunityArticleUseCase>(
      () => communityArticlesModule.createCommunityArticleUseCase(
        gh<_i413.CommunityArticleRepository>(),
      ),
    );
    gh.lazySingleton<_i181.UpdateCommunityArticleUseCase>(
      () => communityArticlesModule.updateCommunityArticleUseCase(
        gh<_i413.CommunityArticleRepository>(),
      ),
    );
    gh.lazySingleton<_i1061.DeleteCommunityArticleUseCase>(
      () => communityArticlesModule.deleteCommunityArticleUseCase(
        gh<_i413.CommunityArticleRepository>(),
      ),
    );
    gh.factory<_i757.RemoteArticlesBloc>(
      () => _i757.RemoteArticlesBloc(gh<_i579.GetArticleUseCase>()),
    );
    return this;
  }
}

class _$InfrastructureModule extends _i959.InfrastructureModule {}

class _$CommunityArticlesModule extends _i271.CommunityArticlesModule {}

class _$BookmarksModule extends _i1000.BookmarksModule {}

class _$AuthModule extends _i360.AuthModule {}

class _$DailyNewsModule extends _i1048.DailyNewsModule {}
