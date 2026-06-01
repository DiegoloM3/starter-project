import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../features/tortu_feed/data/data_sources/tortu_feed_remote_data_source.dart';
import '../features/tortu_feed/data/repository/tortu_feed_repository_impl.dart';
import '../features/tortu_feed/domain/repository/tortu_feed_repository.dart';
import '../features/tortu_feed/domain/use_cases/check_today_tip_use_case.dart';
import '../features/tortu_feed/domain/use_cases/feed_tortu_use_case.dart';
import '../features/tortu_feed/domain/use_cases/get_category_progress_use_case.dart';
import '../features/tortu_feed/domain/use_cases/get_overall_progress_use_case.dart';
import '../features/tortu_feed/domain/use_cases/get_streak_days_use_case.dart';
import '../features/tortu_feed/domain/use_cases/update_category_progress_use_case.dart';

final sl = GetIt.instance;

void initTortuFeedDependencies() {
  sl.registerLazySingleton<TortuFeedRemoteDataSource>(
    () => TortuFeedRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );

  sl.registerLazySingleton<TortuFeedRepository>(
    () => TortuFeedRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => FeedTortuUseCase(sl()));
  sl.registerLazySingleton(() => CheckTodayTipUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoryProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetStreakDaysUseCase(sl()));
  sl.registerLazySingleton(() => GetOverallProgressUseCase(sl()));
}
