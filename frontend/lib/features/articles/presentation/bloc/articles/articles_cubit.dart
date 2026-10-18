import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../profiles/domain/usecases/get_followed_user_ids.dart';
import '../../../domain/usecases/get_articles_by_authors.dart';
import '../../../domain/usecases/get_for_you_articles.dart';
import 'articles_state.dart';

/// Articles of the news tab: "for you" and "following".
class ArticlesCubit extends Cubit<ArticlesState> {
  final GetFollowedUserIdsUseCase _getFollowedUserIdsUseCase;
  final GetForYouArticlesUseCase _getForYouArticlesUseCase;
  final GetArticlesByAuthorsUseCase _getArticlesByAuthorsUseCase;

  ArticlesCubit(this._getFollowedUserIdsUseCase, this._getForYouArticlesUseCase, this._getArticlesByAuthorsUseCase)
    : super(const ArticlesState());

  /// Both sections depend on who the user follows, so that is asked first and then the two
  /// sections are loaded at the same time. The current articles stay visible meanwhile and if it fails.
  Future<void> load() async {
    emit(state.withStatus(ArticlesStatus.loading));
    final followedUserIds = await _getFollowedUserIdsUseCase(const NoParams());
    if (followedUserIds is DataFailed) {
      emit(state.withStatus(ArticlesStatus.failure));
      return;
    }

    final forYouRequest = _getForYouArticlesUseCase(followedUserIds.data!);
    final followingRequest = _getArticlesByAuthorsUseCase(followedUserIds.data!);
    final forYou = await forYouRequest;
    final following = await followingRequest;
    if (forYou is DataFailed || following is DataFailed) {
      emit(state.withStatus(ArticlesStatus.failure));
      return;
    }
    emit(
      ArticlesState(status: ArticlesStatus.success, forYouArticles: forYou.data!, followingArticles: following.data!),
    );
  }
}
