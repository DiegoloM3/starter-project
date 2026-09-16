import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/clear_draft.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('delegates to the repository', () async {
    final drafts = MockDraftRepository();
    when(() => drafts.clearDraft()).thenAnswer((_) async => const DataSuccess(null));

    final result = await ClearDraftUseCase(drafts)(const NoParams());

    expect(result.isSuccess, isTrue);
    verify(() => drafts.clearDraft()).called(1);
  });
}
