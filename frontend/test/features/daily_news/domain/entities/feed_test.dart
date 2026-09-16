import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/feed.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  final older = buildArticle(id: 'r-old', publishedAt: DateTime.utc(2026, 9, 1));
  final newer = buildArticle(id: 'r-new', publishedAt: DateTime.utc(2026, 9, 10));
  final newest = buildUserArticle(id: 'u-1', publishedAt: DateTime.utc(2026, 9, 15));

  group('FeedEntity.merge', () {
    test('interleaves both sources newest first', () {
      final result = FeedEntity.merge(
        remote: DataSuccess([older, newer]),
        user: DataSuccess([newest]),
      );

      final feed = result.dataOrNull!;
      expect(feed.articles, [newest, newer, older]);
      expect(feed.isPartial, isFalse);
      expect(feed.isEmpty, isFalse);
    });

    test('keeps user articles and records the remote failure when the provider fails', () {
      final result = FeedEntity.merge(
        remote: const DataFailed(Failure.network()),
        user: DataSuccess([newest]),
      );

      final feed = result.dataOrNull!;
      expect(feed.articles, [newest]);
      expect(feed.remoteFailure, const Failure.network());
      expect(feed.userFailure, isNull);
      expect(feed.isPartial, isTrue);
    });

    test('keeps provider articles and records the user failure when our backend fails', () {
      final result = FeedEntity.merge(
        remote: DataSuccess([newer]),
        user: const DataFailed(Failure.permissionDenied()),
      );

      final feed = result.dataOrNull!;
      expect(feed.articles, [newer]);
      expect(feed.userFailure, const Failure.permissionDenied());
      expect(feed.isPartial, isTrue);
    });

    test('fails with the remote failure when both sources fail', () {
      final result = FeedEntity.merge(
        remote: const DataFailed(Failure.server()),
        user: const DataFailed(Failure.network()),
      );

      expect(result, const DataFailed<FeedEntity>(Failure.server()));
    });

    test('yields an empty, non-partial feed when both sources are empty', () {
      final result = FeedEntity.merge(
        remote: const DataSuccess([]),
        user: const DataSuccess([]),
      );

      expect(result.dataOrNull, FeedEntity.empty);
      expect(result.dataOrNull!.isEmpty, isTrue);
    });
  });

  group('FeedEntity.sortNewestFirst', () {
    test('drops later duplicates by id, keeping the first occurrence', () {
      final duplicate = older.copyWith(title: 'Duplicate');

      final sorted = FeedEntity.sortNewestFirst([older, duplicate, newer]);

      expect(sorted, [newer, older]);
      expect(sorted.last.title, older.title);
    });

    test('does not mutate the input', () {
      final input = <ArticleEntity>[older, newer];
      FeedEntity.sortNewestFirst(input);
      expect(input, [older, newer]);
    });
  });
}
