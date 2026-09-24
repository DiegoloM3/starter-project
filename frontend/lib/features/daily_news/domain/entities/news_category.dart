/// The sections the news feed can be filtered to.
///
/// These are the values the News API accepts for `/top-headlines`; there is
/// no per-article category to read back, so a category is a property of the
/// request rather than of a story.
enum NewsCategory {
  general,
  business,
  technology,
  science,
  health,
  sports,
  entertainment;

  /// Value the API expects.
  String get query => name;
}
