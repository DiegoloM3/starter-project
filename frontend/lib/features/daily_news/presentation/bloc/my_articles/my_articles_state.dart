part of 'my_articles_cubit.dart';

enum MyArticlesStatus { initial, loading, loaded, failure }

class MyArticlesState extends Equatable {
  final MyArticlesStatus status;
  final List<ArticleEntity> articles;
  final Failure? failure;

  const MyArticlesState({
    this.status = MyArticlesStatus.initial,
    this.articles = const [],
    this.failure,
  });

  MyArticlesState copyWith({
    MyArticlesStatus? status,
    List<ArticleEntity>? articles,
    Failure? failure,
  }) {
    return MyArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, articles, failure];
}
