import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/data_sources/local/author_signature_local_data_source.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/data/repository/author_signature_repository_impl.dart';

class MockAuthorSignatureLocalDataSource extends Mock implements AuthorSignatureLocalDataSource {}

void main() {
  late MockAuthorSignatureLocalDataSource dataSource;
  late AuthorSignatureRepositoryImpl repository;

  setUp(() {
    dataSource = MockAuthorSignatureLocalDataSource();
    repository = AuthorSignatureRepositoryImpl(dataSource);
  });

  test('returns the stored signature', () async {
    when(() => dataSource.readAuthorName()).thenReturn('Daily News Staff');

    expect((await repository.getSavedAuthorName()).data, 'Daily News Staff');
  });

  test('saves the signature', () async {
    when(() => dataSource.writeAuthorName(any())).thenAnswer((_) async {});

    final result = await repository.saveAuthorName('Daily News Staff');

    expect(result, isA<DataSuccess<void>>());
    verify(() => dataSource.writeAuthorName('Daily News Staff')).called(1);
  });

  test('fails when the device cannot store the signature', () async {
    final error = Exception('disk full');
    when(() => dataSource.writeAuthorName(any())).thenThrow(error);

    expect((await repository.saveAuthorName('Daily News Staff')).error, same(error));
  });
}
