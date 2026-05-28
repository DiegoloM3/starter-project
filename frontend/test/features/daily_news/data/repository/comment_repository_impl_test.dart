import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/comment_repository_impl.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/register_fallback_values.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late CommentRepositoryImpl repository;
  late MockFirestoreCommentDataSource mockDataSource;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockDataSource = MockFirestoreCommentDataSource();
    repository = CommentRepositoryImpl(mockDataSource);
  });

  group('addComment', () {
    test('returns DataSuccess with mapped entity on success', () async {
      final model = testCommentModel();
      when(() => mockDataSource.addComment(any()))
          .thenAnswer((_) async => model);

      final result = await repository.addComment(testComment());

      expect(result, isA<DataSuccess>());
      expect(result.data!.id, model.id);
    });

    test('returns DataFailed on FirebaseException', () async {
      when(() => mockDataSource.addComment(any()))
          .thenThrow(FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
      ));

      final result = await repository.addComment(testComment());

      expect(result, isA<DataFailed>());
      expect(result.error, isA<AuthException>());
    });

    test('returns DataFailed on generic exception', () async {
      when(() => mockDataSource.addComment(any()))
          .thenThrow(Exception('unexpected'));

      final result = await repository.addComment(testComment());

      expect(result, isA<DataFailed>());
    });
  });

  group('getComments', () {
    test('stream maps models to DataSuccess entities', () async {
      final models = [testCommentModel()];
      when(() => mockDataSource.getComments(any()))
          .thenAnswer((_) => Stream.value(models));

      final stream = repository.getComments(tArticleId);

      await expectLater(
        stream,
        emits(predicate<DataState>((ds) =>
            ds is DataSuccess && ds.data != null)),
      );
    });

    test('stream error maps to DataFailed', () async {
      final controller = StreamController<List<CommentModel>>();
      when(() => mockDataSource.getComments(any()))
          .thenAnswer((_) => controller.stream);

      final stream = repository.getComments(tArticleId);

      expectLater(stream, emits(isA<DataFailed>()));

      controller.addError(FirebaseException(
        plugin: 'firestore',
        code: 'unavailable',
      ));

      await controller.close();
    });
  });

  group('deleteComment', () {
    test('returns DataSuccess on success', () async {
      when(() => mockDataSource.deleteComment(
            articleId: any(named: 'articleId'),
            commentId: any(named: 'commentId'),
          )).thenAnswer((_) async {});

      final result = await repository.deleteComment(
        articleId: tArticleId,
        commentId: tCommentId,
      );

      expect(result, isA<DataSuccess>());
    });

    test('returns DataFailed on FirebaseException', () async {
      when(() => mockDataSource.deleteComment(
            articleId: any(named: 'articleId'),
            commentId: any(named: 'commentId'),
          )).thenThrow(FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
      ));

      final result = await repository.deleteComment(
        articleId: tArticleId,
        commentId: tCommentId,
      );

      expect(result, isA<DataFailed>());
    });
  });
}
