/// Categories understood by the news provider and used for feed filters,
/// search chips and the Daily Brief interest picker.
enum NewsCategory {
  general('general', 'Top stories'),
  business('business', 'Business'),
  technology('technology', 'Technology'),
  science('science', 'Science'),
  health('health', 'Health'),
  sports('sports', 'Sports'),
  entertainment('entertainment', 'Entertainment');

  /// Value expected by the provider's `category` query parameter.
  final String apiValue;

  /// Human-readable label.
  final String label;

  const NewsCategory(this.apiValue, this.label);

  static NewsCategory fromApiValue(String? value) {
    return NewsCategory.values.firstWhere(
      (category) => category.apiValue == value,
      orElse: () => NewsCategory.general,
    );
  }
}
