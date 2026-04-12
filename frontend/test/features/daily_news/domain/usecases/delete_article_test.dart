import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/delete_article.dart';

import '../../fakes/fake_firestore_article_repository.dart';

void main() {
  late FakeFirestoreArticleRepository repository;
  late DeleteArticleUseCase useCase;

  setUp(() {
    repository = FakeFirestoreArticleRepository();
    useCase = DeleteArticleUseCase(repository);
  });

  test('returns DataSuccess when delete succeeds', () async {
    final result = await useCase(params: 'doc-123');

    expect(result, isA<DataSuccess<bool>>());
    expect(result.data, true);
    expect(repository.lastDeletedId, 'doc-123');
  });

  test('returns DataFailed when delete fails', () async {
    repository.deleteResult = const DataFailed(ServerFailure());

    final result = await useCase(params: 'doc-123');

    expect(result, isA<DataFailed<bool>>());
  });

  test('passes documentId to repository', () async {
    await useCase(params: 'specific-doc-id');

    expect(repository.lastDeletedId, 'specific-doc-id');
  });
}
