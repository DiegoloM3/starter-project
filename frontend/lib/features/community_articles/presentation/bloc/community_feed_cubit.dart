import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import 'community_feed_state.dart';

class CommunityFeedCubit extends Cubit<CommunityFeedState> {
  final CommunityArticleRepository _repository;
  StreamSubscription<List<ArticleEntity>>? _subscription;

  CommunityFeedCubit(this._repository) : super(const CommunityFeedLoading());

  void start() {
    _subscription?.cancel();
    _subscription = _repository.watchArticles().listen(
          (articles) => emit(CommunityFeedLoaded(articles)),
          onError: (Object error) =>
              emit(CommunityFeedError(error.toString())),
        );
  }

  Future<String> publish(ArticleEntity article) {
    return _repository.publishArticle(article);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
