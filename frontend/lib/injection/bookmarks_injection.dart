import 'package:get_it/get_it.dart';
import 'package:tortutip/features/articles/domain/use_cases/unsave_article_use_case.dart';
import 'package:tortutip/features/bookmarks/presentation/bloc/bookmarks_cubit.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_saved_articles_use_case.dart';

final sl = GetIt.instance;

void initBookmarksDependencies() {
  sl.registerFactory<BookmarksCubit>(
    () => BookmarksCubit(
      sl<GetSavedArticlesUseCase>(),
      sl<UnsaveArticleUseCase>(),
    ),
  );
}
