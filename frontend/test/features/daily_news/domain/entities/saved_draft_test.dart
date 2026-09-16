import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('blank texts and no photo count as empty; a category alone is not content', () {
    expect(const SavedDraft().isEmpty, isTrue);
    expect(const SavedDraft(title: '   ', content: '\n', category: NewsCategory.health).isEmpty, isTrue);
  });

  test('any text or a photo makes the draft worth keeping', () {
    expect(const SavedDraft(content: 'x').isNotEmpty, isTrue);
    expect(SavedDraft(image: buildImage()).isNotEmpty, isTrue);
  });

  test('copyWith can drop the photo', () {
    final draft = SavedDraft(title: 'T', image: buildImage());

    expect(draft.copyWith(clearImage: true), const SavedDraft(title: 'T'));
    expect(draft.copyWith(title: 'U').image, buildImage());
  });
}
