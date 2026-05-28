import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class DraftsListState extends Equatable {
  final List<ArticleEntity>? articles;
  final AppException? error;

  const DraftsListState({this.articles, this.error});

  @override
  List<Object?> get props => [articles, error];
}

class DraftsListLoading extends DraftsListState {
  const DraftsListLoading();
}

class DraftsListDone extends DraftsListState {
  const DraftsListDone(List<ArticleEntity> articles)
      : super(articles: articles);
}

class DraftsListFailure extends DraftsListState {
  const DraftsListFailure(AppException error) : super(error: error);
}
