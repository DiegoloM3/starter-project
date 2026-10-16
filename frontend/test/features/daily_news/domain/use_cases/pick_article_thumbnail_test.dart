import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_thumbnail_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/use_cases/pick_article_thumbnail.dart';

class MockArticleThumbnailRepository extends Mock implements ArticleThumbnailRepository {}

void main() {
  group('PickArticleThumbnailUseCase', () {
    test('returns the thumbnail picked from the gallery', () async {
      final repository = MockArticleThumbnailRepository();
      when(() => repository.pickThumbnailFromGallery())
          .thenAnswer((_) async => const DataSuccess('/images/thumbnail.jpg'));

      final result = await PickArticleThumbnailUseCase(repository)();

      expect(result.data, '/images/thumbnail.jpg');
      verify(() => repository.pickThumbnailFromGallery()).called(1);
    });
  });
}
