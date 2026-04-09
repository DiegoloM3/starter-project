import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:news_app_clean_architecture/core/errors/network_exception.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_status.dart';

@immutable
sealed class RemoteArticlesState extends Equatable {
  final RemoteArticleStatus status;
  final List<ArticleEntity>? articles;
  final NetworkException? error;

  const RemoteArticlesState({
    this.status = RemoteArticleStatus.none,
    this.articles,
    this.error,
  });

  @override
  List<Object?> get props => [
        status,
        articles,
        error,
      ];
}

final class RemoteArticlesLoading extends RemoteArticlesState {
  const RemoteArticlesLoading();
}

final class RemoteArticlesDone extends RemoteArticlesState {
  final int page;
  final int totalPages;
  final int? total;
  const RemoteArticlesDone({
    required List<ArticleEntity> articles,
    this.page = 0,
    this.totalPages = 0,
    this.total,
    RemoteArticleStatus status = RemoteArticleStatus.none,
  }) : super(articles: articles, status: status);

  @override
  List<Object?> get props => [
        articles,
        status,
        page,
        totalPages,
        total,
      ];

  RemoteArticlesDone copyWith({
    List<ArticleEntity>? articles,
    int? page,
    int? totalPages,
    int? total,
    RemoteArticleStatus? status,
  }) =>
      RemoteArticlesDone(
        articles: articles ?? this.articles!,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
        total: total ?? this.total,
        status: status ?? this.status,
      );

  bool get isLast => (page + 1) >= totalPages;
}

final class RemoteArticlesError extends RemoteArticlesState {
  const RemoteArticlesError(NetworkException error) : super(error: error);

  @override
  List<Object?> get props => [error];
}

final class RemoteArticleEmpty extends RemoteArticlesState {
  const RemoteArticleEmpty({
    RemoteArticleStatus status = RemoteArticleStatus.none,
  }) : super(status: status);
}
