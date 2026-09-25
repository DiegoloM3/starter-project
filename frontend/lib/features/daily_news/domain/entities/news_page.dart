import 'package:equatable/equatable.dart';

import 'article.dart';

/// One page of the feed, plus whether asking for the next one makes sense.
/// Decided where the raw response is still visible (the repository), not by
/// counting [articles]: some raw items get filtered out before they get here.
class NewsPage extends Equatable {
  final List<ArticleEntity> articles;
  final bool hasMore;

  /// Set when these stories are the copy kept on the phone, because the
  /// news couldn't be loaded: when that copy was saved.
  final DateTime? savedAt;

  /// True when it was specifically NewsAPI's free-plan daily cap (not a
  /// real connectivity problem) that made the live fetch fail. Only
  /// meaningful alongside [savedAt] -- the reader is offline either way,
  /// but this is a different reason than "no connection", and saying so
  /// avoids blaming their wifi for something the app's own quota caused.
  final bool isRateLimited;

  const NewsPage({
    required this.articles,
    required this.hasMore,
    this.savedAt,
    this.isRateLimited = false,
  });

  bool get isOfflineCopy => savedAt != null;

  @override
  List<Object?> get props => [articles, hasMore, savedAt, isRateLimited];
}
