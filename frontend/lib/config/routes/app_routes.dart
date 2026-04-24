import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

/// Typed helpers for every route the app exposes.
///
/// Keeps the path strings in one place so renames stay safe and so call
/// sites read as `context.go(AppRoutes.saved())` instead of stringly-typed
/// literals scattered across pages.
abstract final class AppRoutes {
  // Names — useful for `context.goNamed` / analytics.
  static const String homeName = 'home';
  static const String articleDetailName = 'articleDetail';
  static const String savedName = 'saved';

  // Paths.
  static String home() => '/';
  static String saved() => '/saved';
  static String articleDetail(String id) => '/article/$id';

  /// Convenience wrapper used while NewsAPI articles lack a stable id —
  /// derives a URL-safe segment from the article's url/title. Once F4
  /// refactors [ArticleEntity] to have a required id, callers should use
  /// [articleDetail] directly.
  static String articleDetailFor(ArticleEntity article) {
    final raw = article.url ?? article.title ?? 'unknown';
    return articleDetail(Uri.encodeComponent(raw));
  }
}
