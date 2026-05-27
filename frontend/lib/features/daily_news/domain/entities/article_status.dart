abstract class ArticleStatus {
  static const String draft = 'draft';
  static const String published = 'published';
  static const String archived = 'archived';

  static const List<String> values = [draft, published, archived];

  static bool isValidTransition(String from, String to) {
    if (from == to) return true;
    if (from == draft && to == published) return true;
    if (from == published && to == archived) return true;
    return false;
  }
}
