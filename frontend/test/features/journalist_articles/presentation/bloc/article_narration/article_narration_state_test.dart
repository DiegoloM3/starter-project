import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_narration_progress.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/presentation/bloc/article_narration/article_narration_state.dart';

const narration = ArticleNarrationEntity(
  parts: [NarrationPart(NarrationPartKind.paragraph, ['One.', 'Two.'])],
  languageTag: 'en-US',
);

void main() {
  ArticleNarrationReading readingSentence(int index) {
    return ArticleNarrationReading(
      progress: ArticleNarrationProgressEntity(narration: narration, sentenceIndex: index),
    );
  }

  test('reading states differ by the sentence being read', () {
    expect(readingSentence(0), isNot(readingSentence(1)));
    expect(readingSentence(0), readingSentence(0));
  });

  test('reading has no progress yet while the voice is being prepared', () {
    expect(const ArticleNarrationReading().progress, isNull);
  });
}
