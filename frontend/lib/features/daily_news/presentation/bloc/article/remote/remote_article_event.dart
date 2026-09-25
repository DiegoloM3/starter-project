import 'dart:async';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';

/// How a refresh went, so the screen can say something when nothing
/// visibly changed.
enum RefreshOutcome { newStories, nothingNew, offline, rateLimited, failed }

abstract class RemoteArticlesEvent {
  const RemoteArticlesEvent();
}

/// Shows a section of the feed, from memory if it's already been loaded.
/// [refresh] (pull-to-refresh) asks NewsAPI again regardless.
class GetArticles extends RemoteArticlesEvent {
  final NewsCategory category;
  final bool refresh;

  /// Completed once handled, even when nothing changed on screen, so a
  /// pull-to-refresh spinner always knows when to stop -- and with what
  /// happened, so it can tell the reader.
  final Completer<RefreshOutcome>? completer;

  const GetArticles({
    this.category = NewsCategory.top,
    this.refresh = false,
    this.completer,
  });
}

/// Appends the next page of the section on screen.
class LoadMoreArticles extends RemoteArticlesEvent {
  const LoadMoreArticles();
}
