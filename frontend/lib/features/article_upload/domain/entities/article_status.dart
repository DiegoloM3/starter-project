enum ArticleStatus {
  draft,
  publishing,
  published;

  String toApiValue() => name;

  static ArticleStatus fromApiValue(String value) {
    return ArticleStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown ArticleStatus: $value'),
    );
  }
}
