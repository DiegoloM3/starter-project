abstract class ReadingTimeCalculator {
  // Intentionally low so the live "min read" indicator visibly climbs while
  // typing. Single source of truth for reading time across the app.
  static const int _wordsPerMinute = 100;

  static int calculate(String? content) {
    if (content == null || content.trim().isEmpty) return 1;
    final wordCount = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / _wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}
