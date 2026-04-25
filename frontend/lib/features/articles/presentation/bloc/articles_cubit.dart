import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/articles/domain/failures/article_failure.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/create_article_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/delete_article_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_my_articles_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/update_article_use_case.dart';
import 'package:news_app_clean_architecture/features/articles/presentation/bloc/articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  final GetArticlesUseCase _getArticlesUseCase;
  final GetMyArticlesUseCase _getMyArticlesUseCase;
  final CreateArticleUseCase _createArticleUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  ArticlesCubit(
    this._getArticlesUseCase,
    this._getMyArticlesUseCase,
    this._createArticleUseCase,
    this._updateArticleUseCase,
    this._deleteArticleUseCase,
  ) : super(const ArticlesInitial());

  /// The current article list, derived from state. Empty if not yet loaded.
  List<ArticleEntity> get _currentArticles {
    final s = state;
    if (s is ArticlesLoaded) return s.articles;
    if (s is ArticleMutationSuccess) return s.articles;
    if (s is ArticleMutationError) return s.articles;
    return const [];
  }

  Future<void> loadArticles({String? category}) async {
    emit(const ArticlesLoading());
    try {
      final result = await _getArticlesUseCase(
        params: GetArticlesParams(category: category),
      );
      if (result is DataSuccess) {
        emit(ArticlesLoaded(result.data!));
      } else if (result is DataFailed) {
        emit(ArticlesError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const ArticlesError('Something went wrong. Please try again.'));
    }
  }

  Future<void> loadMyArticles(String authorId, {String? status}) async {
    emit(const ArticlesLoading());
    try {
      final result = await _getMyArticlesUseCase(
        params: GetMyArticlesParams(authorId: authorId, status: status),
      );
      if (result is DataSuccess) {
        emit(ArticlesLoaded(result.data!));
      } else if (result is DataFailed) {
        emit(ArticlesError(_messageFrom(result)));
      }
    } catch (_) {
      emit(const ArticlesError('Something went wrong. Please try again.'));
    }
  }

  Future<void> createArticle(ArticleEntity article, {File? thumbnail}) async {
    final current = _currentArticles;
    emit(ArticlesLoaded(current, isMutating: true));
    try {
      final result = await _createArticleUseCase(
        params: CreateArticleParams(article: article, thumbnail: thumbnail),
      );
      if (result is DataSuccess) {
        final updated = [result.data!, ...current];
        emit(ArticleMutationSuccess(articles: updated, article: result.data!));
      } else if (result is DataFailed) {
        emit(ArticleMutationError(
            articles: current, message: _messageFrom(result)));
      }
    } catch (_) {
      emit(ArticleMutationError(
          articles: current,
          message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> updateArticle(ArticleEntity article, {File? thumbnail}) async {
    final current = _currentArticles;
    emit(ArticlesLoaded(current, isMutating: true));
    try {
      final result = await _updateArticleUseCase(
        params: UpdateArticleParams(article: article, thumbnail: thumbnail),
      );
      if (result is DataSuccess) {
        final updated = current
            .map((a) => a.id == result.data!.id ? result.data! : a)
            .toList();
        emit(ArticleMutationSuccess(articles: updated, article: result.data!));
      } else if (result is DataFailed) {
        emit(ArticleMutationError(
            articles: current, message: _messageFrom(result)));
      }
    } catch (_) {
      emit(ArticleMutationError(
          articles: current,
          message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> deleteArticle(String id) async {
    final current = _currentArticles;
    emit(ArticlesLoaded(current, isMutating: true));
    try {
      final result = await _deleteArticleUseCase(
        params: DeleteArticleParams(id: id),
      );
      if (result is DataSuccess) {
        final updated = current.where((a) => a.id != id).toList();
        emit(ArticleMutationSuccess(
            articles: updated, deletedArticleId: id));
      } else if (result is DataFailed) {
        emit(ArticleMutationError(
            articles: current, message: _messageFrom(result)));
      }
    } catch (_) {
      emit(ArticleMutationError(
          articles: current,
          message: 'Something went wrong. Please try again.'));
    }
  }

  String _messageFrom(DataState result) {
    final failure = result.error?.error;
    return failure is ArticleFailure
        ? failure.message
        : 'Something went wrong. Please try again.';
  }
}
