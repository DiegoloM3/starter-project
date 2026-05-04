enum ArticleCategory {
  fitness,
  news,
  lifestyle,
  tech,
  other;

  String toApiValue() => name;

  static ArticleCategory fromApiValue(String value) {
    return ArticleCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown ArticleCategory: $value'),
    );
  }
}
