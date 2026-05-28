import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/shared/data/errors/exception_mapper.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_comment_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/comment.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final FirestoreCommentDataSource _dataSource;

  CommentRepositoryImpl(this._dataSource);

  @override
  Future<DataState<CommentEntity>> addComment(CommentEntity comment) async {
    try {
      final model = CommentModel.fromEntity(comment);
      final created = await _dataSource.addComment(model);
      return DataSuccess(created.toEntity());
    } on FirebaseException catch (e) {
      return DataFailed(ExceptionMapper.fromFirebaseException(e));
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }

  @override
  Stream<DataState<List<CommentEntity>>> getComments(String articleId) {
    return _dataSource.getComments(articleId).transform(
          StreamTransformer<List<CommentModel>,
              DataState<List<CommentEntity>>>.fromHandlers(
            handleData: (models, sink) {
              sink.add(
                  DataSuccess(models.map((m) => m.toEntity()).toList()));
            },
            handleError: (error, stackTrace, sink) {
              sink.add(
                  DataFailed(ExceptionMapper.fromException(error)));
            },
          ),
        );
  }

  @override
  Future<DataState<void>> deleteComment({
    required String articleId,
    required String commentId,
  }) async {
    try {
      await _dataSource.deleteComment(
        articleId: articleId,
        commentId: commentId,
      );
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(ExceptionMapper.fromFirebaseException(e));
    } catch (e) {
      return DataFailed(ExceptionMapper.fromException(e));
    }
  }
}
