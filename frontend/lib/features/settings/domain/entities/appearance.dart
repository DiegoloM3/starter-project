/// Color theme chosen by the user.
enum Appearance {
  light('light'),
  dark('dark');

  final String id;

  const Appearance(this.id);

  /// Light is the default, also when nothing was saved yet.
  static Appearance fromId(String? id) {
    for (final appearance in values) {
      if (appearance.id == id) return appearance;
    }
    return light;
  }
}
