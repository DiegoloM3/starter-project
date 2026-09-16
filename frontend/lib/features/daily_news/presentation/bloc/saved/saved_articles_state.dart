part of 'saved_articles_cubit.dart';

enum SavedStatus { initial, loading, loaded, failure }

class SavedArticlesState extends Equatable {
  final SavedStatus status;

  /// Newest bookmark first.
  final List<ArticleEntity> articles;

  /// The article removed last, offered back through Undo.
  final ArticleEntity? lastRemoved;
  final Failure? failure;

  const SavedArticlesState({
    this.status = SavedStatus.initial,
    this.articles = const [],
    this.lastRemoved,
    this.failure,
  });

  Set<String> get savedIds => {for (final article in articles) article.id};

  SavedArticlesState copyWith({
    SavedStatus? status,
    List<ArticleEntity>? articles,
    ArticleEntity? lastRemoved,
    Failure? failure,
  }) {
    return SavedArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      lastRemoved: lastRemoved,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, articles, lastRemoved, failure];
}
