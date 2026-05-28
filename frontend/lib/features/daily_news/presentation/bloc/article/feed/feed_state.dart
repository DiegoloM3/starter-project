import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

import '../../../../domain/entities/article.dart';

abstract class FeedState extends Equatable {
  final List<ArticleEntity>? articles;
  final AppException? error;

  const FeedState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedDone extends FeedState {
  const FeedDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

class FeedFailure extends FeedState {
  const FeedFailure(AppException error)
      : super(error: error);
}
