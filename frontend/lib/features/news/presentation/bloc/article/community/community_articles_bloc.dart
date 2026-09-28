import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_all_user_articles.dart';

part 'community_articles_event.dart';
part 'community_articles_state.dart';

/// UI state machine for the community feed of user articles.
@injectable
class CommunityArticlesBloc
    extends Bloc<CommunityArticlesEvent, CommunityArticlesState> {
  final GetAllUserArticles _getAllUserArticles;

  CommunityArticlesBloc(this._getAllUserArticles)
      : super(const CommunityArticlesLoading()) {
    on<LoadCommunityArticles>(_onLoadCommunityArticles);
  }

  Future<void> _onLoadCommunityArticles(
    LoadCommunityArticles event,
    Emitter<CommunityArticlesState> emit,
  ) async {
    emit(const CommunityArticlesLoading());

    final result = await _getAllUserArticles();

    if (result is DataSuccess) {
      emit(CommunityArticlesDone(result.data ?? const <ArticleEntity>[]));
    } else {
      emit(CommunityArticlesError(
        result.errorMessage ?? result.error?.toString() ?? 'Unknown error.',
      ));
    }
  }
}
