import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_status.dart';

void main() {
  test('values match the ones accepted by the firestore rules', () {
    expect(ArticleStatus.draft.value, 'draft');
    expect(ArticleStatus.published.value, 'published');
  });
}
