import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/article_thumbnail_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/pick_article_thumbnail.dart';

class MockArticleThumbnailRepository extends Mock implements ArticleThumbnailRepository {}

void main() {
  late MockArticleThumbnailRepository repository;
  late PickArticleThumbnailUseCase pickArticleThumbnail;

  setUp(() {
    repository = MockArticleThumbnailRepository();
    pickArticleThumbnail = PickArticleThumbnailUseCase(repository);
  });

  test('returns the thumbnail chosen in the gallery', () async {
    final thumbnail = ArticleThumbnailEntity(bytes: Uint8List(1024), fileExtension: 'png');
    when(() => repository.pickThumbnailFromGallery()).thenAnswer((_) async => DataSuccess(thumbnail));

    final dataState = await pickArticleThumbnail();

    expect(dataState.data, thumbnail);
  });

  test('returns no thumbnail when the gallery is closed without choosing one', () async {
    when(() => repository.pickThumbnailFromGallery()).thenAnswer((_) async => const DataSuccess(null));

    final dataState = await pickArticleThumbnail();

    expect(dataState, isA<DataSuccess>());
    expect(dataState.data, isNull);
  });
}
