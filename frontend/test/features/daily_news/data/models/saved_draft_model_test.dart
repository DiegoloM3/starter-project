import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_draft_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/saved_draft.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('round-trips every field through JSON, photo included', () {
    final draft = SavedDraft(
      title: 'T',
      description: 'D',
      content: 'C',
      category: NewsCategory.science,
      image: buildImage(),
    );

    final restored = SavedDraftModel.fromJson(SavedDraftModel.fromEntity(draft).toJson()).toEntity();

    expect(restored, draft);
  });

  test('missing or malformed fields fall back to empty instead of failing', () {
    final model = SavedDraftModel.fromJson({
      'title': 7,
      'category': 'not-a-category',
      'image': {'path': ''},
    });

    expect(model.toEntity(), const SavedDraft());
    expect(SavedDraftModel.fromJson({}).toJson().containsKey('image'), isFalse);
  });
}
