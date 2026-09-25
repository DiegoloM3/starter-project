import 'package:news_app_clean_architecture/core/presentation/formatting/relative_time.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_query.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

/// How long ago a story ran; a plain date once it's more than a week old.
/// Empty when NewsAPI's date is missing or unreadable.
String timeAgo(String? publishedAt, AppLocalizations l10n, {DateTime? now}) {
  final published = DateTime.tryParse(publishedAt ?? '');
  if (published == null) return '';
  return relativeTimeOrDate(
    published,
    l10n,
    showDateAfter: const Duration(days: 8),
    now: now,
  );
}

String categoryLabel(NewsCategory category, AppLocalizations l10n) {
  return switch (category) {
    NewsCategory.top => l10n.categoryTop,
    NewsCategory.business => l10n.categoryBusiness,
    NewsCategory.technology => l10n.categoryTechnology,
    NewsCategory.science => l10n.categoryScience,
    NewsCategory.health => l10n.categoryHealth,
    NewsCategory.sports => l10n.categorySports,
    NewsCategory.entertainment => l10n.categoryEntertainment,
  };
}
