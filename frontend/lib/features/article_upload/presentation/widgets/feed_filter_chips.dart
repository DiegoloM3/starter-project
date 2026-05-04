import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

extension _FeedFilterLocalizedLabel on FeedFilter {
  String label(AppLocalizations t) {
    switch (this) {
      case FeedFilter.all:
        return t.filterAll;
      case FeedFilter.forYou:
        return t.filterForYou;
      // Internal name `fitnessNews` is kept (Symmetry's fitness vertical),
      // but the user-facing label is "Health" because the underlying
      // NewsAPI query is broader than fitness alone.
      case FeedFilter.fitnessNews:
        return t.filterHealth;
      case FeedFilter.news:
        return t.filterNews;
      case FeedFilter.community:
        return t.filterCommunity;
    }
  }
}

class FeedFilterChips extends StatelessWidget {
  final List<FeedFilter> filters;
  final FeedFilter selected;
  final ValueChanged<FeedFilter> onSelected;

  const FeedFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label(t)),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
