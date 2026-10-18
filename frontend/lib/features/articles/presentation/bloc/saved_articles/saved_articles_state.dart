import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum SavedArticlesStatus { initial, loading, success, failure, toggleFailure }

class SavedArticlesState extends Equatable {
  final SavedArticlesStatus status;

  /// Most recently saved first.
  final List<ArticleEntity> articles;

  const SavedArticlesState({this.status = SavedArticlesStatus.initial, this.articles = const []});

  bool isSaved(String articleId) => articles.any((article) => article.id == articleId);

  @override
  List<Object?> get props => [status, articles];
}
