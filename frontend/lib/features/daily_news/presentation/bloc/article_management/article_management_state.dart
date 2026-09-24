import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

abstract class ArticleManagementState extends Equatable {
  const ArticleManagementState();

  @override
  List<Object?> get props => [];
}

class ArticleManagementInitial extends ArticleManagementState {
  const ArticleManagementInitial();
}

class ArticleManagementLoading extends ArticleManagementState {
  const ArticleManagementLoading();
}

class ArticleManagementSuccess extends ArticleManagementState {
  final List<ArticleEntity> articles;

  const ArticleManagementSuccess({required this.articles});

  @override
  List<Object?> get props => [articles];
}

class ArticleManagementFailure extends ArticleManagementState {
  final String error;

  const ArticleManagementFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ArticleDeleted extends ArticleManagementState {
  final String articleId;

  const ArticleDeleted({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}

class ArticlePublishStatusUpdated extends ArticleManagementState {
  final String articleId;
  final bool isPublished;

  const ArticlePublishStatusUpdated({
    required this.articleId,
    required this.isPublished,
  });

  @override
  List<Object?> get props => [articleId, isPublished];
}
