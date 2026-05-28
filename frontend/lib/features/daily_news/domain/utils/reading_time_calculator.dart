abstract class ReadingTimeCalculator {
  static const int _wordsPerMinute = 265;

  static int calculate(String? content) {
    if (content == null || content.trim().isEmpty) return 1;
    final wordCount = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / _wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}
