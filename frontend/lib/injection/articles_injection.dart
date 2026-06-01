import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../features/articles/data/data_sources/article_remote_data_source.dart';
import '../features/articles/data/repository/article_repository_impl.dart';
import '../features/articles/domain/repository/article_repository.dart';
import '../features/articles/domain/use_cases/get_article_detail_use_case.dart';
import '../features/articles/domain/use_cases/get_related_articles_use_case.dart';
import '../features/articles/domain/use_cases/get_feed_articles_paged_use_case.dart';
import '../features/articles/domain/use_cases/get_feed_articles_use_case.dart';
import '../features/articles/domain/use_cases/get_saved_article_ids_use_case.dart';
import '../features/articles/domain/use_cases/get_user_articles_use_case.dart';
import '../features/articles/domain/use_cases/publish_article_use_case.dart';
import '../features/articles/domain/use_cases/save_article_use_case.dart';
import '../features/articles/domain/use_cases/unsave_article_use_case.dart';
import '../features/articles/domain/use_cases/update_article_use_case.dart';
import '../features/articles/domain/use_cases/upload_article_image_use_case.dart';
import '../features/articles/presentation/bloc/article_detail/article_detail_cubit.dart';
import '../features/articles/presentation/bloc/create_article/create_article_cubit.dart';
import '../features/articles/presentation/bloc/feed/feed_cubit.dart';
import '../features/categories/domain/use_cases/get_all_categories_use_case.dart';
import '../shared/user/domain/use_cases/get_user_by_id_use_case.dart';
import '../shared/user/domain/use_cases/record_feed_swipe_use_case.dart';
import '../features/tortu_feed/domain/use_cases/feed_tortu_use_case.dart';

final sl = GetIt.instance;

void initArticlesDependencies() {
  // DataSource — también necesita Storage para subir imágenes de portada
  sl.registerLazySingleton<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSourceImpl(
      sl<FirebaseFirestore>(),
      sl<FirebaseStorage>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFeedArticlesUseCase(sl()));
  sl.registerLazySingleton(() => GetArticleDetailUseCase(sl()));
  sl.registerLazySingleton(() => PublishArticleUseCase(sl()));
  sl.registerLazySingleton(() => SaveArticleUseCase(sl()));
  sl.registerLazySingleton(() => GetUserArticlesUseCase(sl()));
  sl.registerLazySingleton(() => GetFeedArticlesPagedUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedArticleIdsUseCase(sl()));
  sl.registerLazySingleton(() => UnsaveArticleUseCase(sl()));
  sl.registerLazySingleton(() => GetRelatedArticlesUseCase(sl()));
  sl.registerLazySingleton(() => UploadArticleImageUseCase(sl()));
  sl.registerLazySingleton(() => UpdateArticleUseCase(sl()));

  // Cubits — factory, uno nuevo por pantalla
  sl.registerFactory(() => FeedCubit(
        sl<GetFeedArticlesPagedUseCase>(),
        sl<GetSavedArticleIdsUseCase>(),
        sl<SaveArticleUseCase>(),
        sl<UnsaveArticleUseCase>(),
        sl<GetAllCategoriesUseCase>(),
      ));
  sl.registerFactory(() => ArticleDetailCubit(
        sl<GetArticleDetailUseCase>(),
        sl<GetRelatedArticlesUseCase>(),
        sl<SaveArticleUseCase>(),
        sl<UnsaveArticleUseCase>(),
        sl<GetUserByIdUseCase>(),
        sl<GetSavedArticleIdsUseCase>(),
        sl<FeedTortuUseCase>(),
        sl<RecordFeedSwipeUseCase>(),
      ));
  sl.registerFactory(() => CreateArticleCubit(
        sl<PublishArticleUseCase>(),
        sl<UpdateArticleUseCase>(),
        sl<UploadArticleImageUseCase>(),
        sl<GetAllCategoriesUseCase>(),
      ));
}
