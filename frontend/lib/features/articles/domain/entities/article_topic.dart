/// Fixed list of topics, so trends are not split by spelling variations.
/// The ids must match the topics allowed by the Firestore rules.
enum ArticleTopic {
  technology('technology'),
  sports('sports'),
  gaming('gaming'),
  politics('politics'),
  economy('economy'),
  science('science'),
  health('health'),
  entertainment('entertainment'),
  culture('culture'),
  world('world');

  final String id;

  const ArticleTopic(this.id);

  static ArticleTopic? fromId(String id) {
    for (final topic in values) {
      if (topic.id == id) return topic;
    }
    return null;
  }
}
