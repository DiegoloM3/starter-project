import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';

final class MyArticlesState extends Equatable {
  final List<JournalistArticleEntity> articles;
  final List<DraftArticleEntity> drafts;
  final bool isLoading;
  final AppException? error;
  final Set<String> pendingDeletes;

  const MyArticlesState({
    this.articles = const [],
    this.drafts = const [],
    this.isLoading = false,
    this.error,
    this.pendingDeletes = const {},
  });

  MyArticlesState copyWith({
    List<JournalistArticleEntity>? articles,
    List<DraftArticleEntity>? drafts,
    bool? isLoading,
    Object? error = _sentinel,
    Set<String>? pendingDeletes,
  }) {
    return MyArticlesState(
      articles: articles ?? this.articles,
      drafts: drafts ?? this.drafts,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as AppException?,
      pendingDeletes: pendingDeletes ?? this.pendingDeletes,
    );
  }

  @override
  List<Object?> get props => [articles, drafts, isLoading, error, pendingDeletes];
}

const _sentinel = Object();
