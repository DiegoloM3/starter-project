import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/errors/local_database_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_status.dart';

import '../../../../domain/entities/article.dart';

sealed class LocalArticlesState extends Equatable {
  final List<ArticleEntity>? articles;
  final LocalDatabaseException? error;
  final LocalArticleStatus status;
  final bool? isSaved;

  const LocalArticlesState({
    this.articles,
    this.error,
    this.status = LocalArticleStatus.none,
    this.isSaved,
  });

  @override
  List<Object?> get props => [
        articles,
        error,
        status,
        isSaved,
      ];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone({
    required List<ArticleEntity> articles,
    LocalArticleStatus status = LocalArticleStatus.none,
    bool? isSaved,
  }) : super(
          articles: articles,
          status: status,
          isSaved: isSaved,
        );

  LocalArticlesDone copyWith({
    List<ArticleEntity>? articles,
    LocalArticleStatus? status,
    bool? isSaved,
  }) =>
      LocalArticlesDone(
        articles: articles ?? this.articles!,
        status: status ?? this.status,
        isSaved: isSaved ?? this.isSaved,
      );

  LocalArticlesDone clearSave() => LocalArticlesDone(
        articles: articles ?? [],
        status: status,
        isSaved: null,
      );
}

class LocalArticlesError extends LocalArticlesState {
  const LocalArticlesError(LocalDatabaseException error) : super(error: error);

  @override
  List<Object?> get props => [error];
}

class LocalArticleEmpty extends LocalArticlesState {
  const LocalArticleEmpty({
    LocalArticleStatus status = LocalArticleStatus.none,
  }) : super(status: status);

  LocalArticleEmpty copyWith({
    LocalArticleStatus? status,
  }) =>
      LocalArticleEmpty(
        status: status ?? this.status,
      );
}
