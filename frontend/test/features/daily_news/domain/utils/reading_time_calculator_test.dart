import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/utils/reading_time_calculator.dart';

void main() {
  group('ReadingTimeCalculator.calculate', () {
    test('returns 1 for null content', () {
      expect(ReadingTimeCalculator.calculate(null), 1);
    });

    test('returns 1 for empty string', () {
      expect(ReadingTimeCalculator.calculate(''), 1);
    });

    test('returns 1 for whitespace only', () {
      expect(ReadingTimeCalculator.calculate('   \n\t  '), 1);
    });

    test('returns 1 for short content under 265 words', () {
      final shortText = List.generate(100, (i) => 'word').join(' ');
      expect(ReadingTimeCalculator.calculate(shortText), 1);
    });

    test('returns 2 for content between 266 and 530 words', () {
      final mediumText = List.generate(300, (i) => 'word').join(' ');
      expect(ReadingTimeCalculator.calculate(mediumText), 2);
    });

    test('calculates correctly for long content', () {
      final longText = List.generate(1000, (i) => 'word').join(' ');
      // 1000 / 265 = 3.77 -> ceil = 4
      expect(ReadingTimeCalculator.calculate(longText), 4);
    });

    test('handles single word', () {
      expect(ReadingTimeCalculator.calculate('hello'), 1);
    });

    test('handles multiple spaces between words', () {
      final text = List.generate(300, (i) => 'word').join('   ');
      expect(ReadingTimeCalculator.calculate(text), 2);
    });
  });
}
