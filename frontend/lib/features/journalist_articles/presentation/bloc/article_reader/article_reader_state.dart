import 'package:equatable/equatable.dart';

import '../../../domain/entities/journalist_article.dart';

/// What the reader is looking at.
class ArticleReaderState extends Equatable {
  final JournalistArticleEntity article;

  /// Whether this reading has already been counted, so returning to the
  /// screen or rebuilding it cannot inflate the article's view count.
  final bool viewRecorded;

  const ArticleReaderState({
    required this.article,
    this.viewRecorded = false,
  });

  ArticleReaderState copyWith({
    JournalistArticleEntity? article,
    bool? viewRecorded,
  }) {
    return ArticleReaderState(
      article: article ?? this.article,
      viewRecorded: viewRecorded ?? this.viewRecorded,
    );
  }

  @override
  List<Object?> get props => [article, viewRecorded];
}
