import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/community_article.dart';
import '../../domain/usecases/get_community_articles.dart';

sealed class CommunityFeedState {
  const CommunityFeedState();
}

class CommunityFeedInitial extends CommunityFeedState {
  const CommunityFeedInitial();
}

class CommunityFeedLoading extends CommunityFeedState {
  const CommunityFeedLoading();
}

class CommunityFeedLoaded extends CommunityFeedState {
  final List<CommunityArticleEntity> articles;
  const CommunityFeedLoaded(this.articles);
}

class CommunityFeedFailure extends CommunityFeedState {
  final String message;
  const CommunityFeedFailure(this.message);
}

class CommunityFeedCubit extends Cubit<CommunityFeedState> {
  final GetCommunityArticlesUseCase _getArticles;
  bool _loadInProgress = false;

  CommunityFeedCubit(this._getArticles) : super(const CommunityFeedInitial());

  Future<void> load() async {
    if (isClosed || _loadInProgress) return;
    _loadInProgress = true;
    try {
      emit(const CommunityFeedLoading());
      final result = await _getArticles();
      if (isClosed) return;
      if (result is DataSuccess<List<CommunityArticleEntity>>) {
        emit(CommunityFeedLoaded(result.data ?? const []));
      } else {
        emit(CommunityFeedFailure(
          result.error?.message ?? 'Unable to load community articles.',
        ));
      }
    } finally {
      _loadInProgress = false;
    }
  }
}
