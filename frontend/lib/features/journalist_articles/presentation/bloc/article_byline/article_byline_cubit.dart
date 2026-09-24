import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../../domain/params/update_articles_byline_params.dart';
import '../../../domain/use_cases/update_articles_byline.dart';
import 'article_byline_state.dart';

/// Keeps the byline on a journalist's published work in step with the name on
/// their account.
///
/// It is its own cubit rather than a method on the session: the session
/// belongs to `authentication`, which knows nothing about articles and must
/// not start to. The account screen asks this one to follow up once the name
/// itself has been changed.
class ArticleBylineCubit extends Cubit<ArticleBylineState> {
  final UpdateArticlesBylineUseCase _updateArticlesByline;

  ArticleBylineCubit(this._updateArticlesByline)
      : super(const ArticleBylineState());

  Future<void> renameTo({
    required String userId,
    required String authorName,
  }) async {
    emit(const ArticleBylineState(status: ArticleBylineStatus.working));

    final result = await _updateArticlesByline(
      UpdateArticlesBylineParams(userId: userId, authorName: authorName),
    );

    if (result is DataSuccess<int>) {
      emit(ArticleBylineState(
        status: ArticleBylineStatus.done,
        renamedCount: result.data!,
      ));
      return;
    }

    emit(ArticleBylineState(
      status: ArticleBylineStatus.failure,
      error: result.error,
    ));
  }
}
