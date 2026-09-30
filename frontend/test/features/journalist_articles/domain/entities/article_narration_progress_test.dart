import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration_progress.dart';

const narration = ArticleNarrationEntity(
  parts: [
    NarrationPart(NarrationPartKind.title, ['Title']),
    NarrationPart(NarrationPartKind.paragraph, ['One.', 'Two.', 'Three.']),
  ],
  languageTag: 'en-US',
);

void main() {
  test('the fraction read grows with each sentence and reaches 1 on the last one', () {
    double fractionReadAt(int sentenceIndex) {
      return ArticleNarrationProgressEntity(narration: narration, sentenceIndex: sentenceIndex).fractionRead;
    }

    expect(fractionReadAt(0), 0.25);
    expect(fractionReadAt(1), 0.5);
    expect(fractionReadAt(3), 1);
  });
}
