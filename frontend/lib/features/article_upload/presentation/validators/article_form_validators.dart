class ArticleFormValidators {
  ArticleFormValidators._();

  static const int _titleMin = 5;
  static const int titleMax = 120;
  static const int _contentMin = 50;

  static String? validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < _titleMin) return 'Minimum $_titleMin characters required';
    if (text.length > titleMax) return 'Maximum $titleMax characters allowed';
    return null;
  }

  static String? validateContent(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < _contentMin) {
      return 'Content must be at least $_contentMin characters';
    }
    return null;
  }

  static bool isFormReady({
    required String title,
    required String content,
    required bool hasThumbnail,
  }) {
    return validateTitle(title) == null &&
        validateContent(content) == null &&
        hasThumbnail;
  }
}
