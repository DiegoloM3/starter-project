import 'dart:io' show File;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/delete_firebase_article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/use_cases/get_firebase_articles.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/presentation/bloc/firebase_articles_state.dart';
import '../../../../shared/article/domain/entities/article.dart';
import '../../domain/entities/generated_article.dart';
import '../../domain/use_cases/generate_article_content.dart';

class FirebaseArticlesCubit extends Cubit<FirebaseArticlesState> {
  final GetFirebaseArticlesUseCase _getFirebaseArticlesUseCase;
  final CreateArticleUseCase _createArticleUseCase;
  final DeleteFirebaseArticleUseCase _deleteFirebaseArticleUseCase;
  final GenerateArticleContentUseCase _generateArticleContentUseCase;
  final FirebaseArticleRepository _repository;

  FirebaseArticlesCubit(
    this._getFirebaseArticlesUseCase,
    this._createArticleUseCase,
    this._deleteFirebaseArticleUseCase,
    this._generateArticleContentUseCase,
    this._repository,
  ) : super(const FirebaseArticlesInitial());

  Future<void> getArticles() async {
    emit(const FirebaseArticlesLoading());
    try {
      final articles = await _getFirebaseArticlesUseCase();
      emit(FirebaseArticlesDone(articles));
    } catch (e) {
      emit(FirebaseArticlesError(e.toString()));
    }
  }

  Future<void> createArticle(CreateArticleParams params) async {
    final currentArticles = state is FirebaseArticlesDone
        ? (state as FirebaseArticlesDone).articles
        : <ArticleEntity>[];

    emit(const FirebaseArticlesLoading());
    try {
      final newArticle = await _createArticleUseCase(params: params);

      emit(const FirebaseArticleCreated());
      emit(FirebaseArticlesDone([newArticle, ...currentArticles]));
    } catch (e) {
      emit(FirebaseArticlesError(e.toString()));
    }
  }

  Future<void> deleteArticle(String articleId) async {
    emit(const FirebaseArticlesLoading());
    try {
      await _deleteFirebaseArticleUseCase(params: articleId);
      await getArticles();
    } catch (e) {
      emit(FirebaseArticlesError(e.toString()));
    }
  }

  Future<GeneratedArticle> generateArticleContent(String prompt) {
    return _generateArticleContentUseCase(params: prompt);
  }

  Future<File> generateArticleImage(String articleTitle) {
    return _repository.generateArticleImage(articleTitle);
  }
}
