import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/params/upload_user_article_params.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/use_cases/upload_user_article_usecase.dart';

part 'upload_user_article_event.dart';
part 'upload_user_article_state.dart';

class UploadUserArticleBloc
    extends Bloc<UploadUserArticleEvent, UploadUserArticleState> {
  final UploadUserArticleUseCase _uploadArticleUseCase;

  UploadUserArticleBloc(
      {required UploadUserArticleUseCase uploadArticleUseCase})
      : _uploadArticleUseCase = uploadArticleUseCase,
        super(UploadUserArticleInitial()) {
    on<SubmitUserArticle>(_onSubmitArticle);
  }

  Future<void> _onSubmitArticle(
      SubmitUserArticle event, Emitter<UploadUserArticleState> emit) async {
    emit(UploadUserArticleLoading());
    await Future.delayed(Duration(milliseconds: 400));
    final result = await _uploadArticleUseCase.call(
      params: UploadUserArticleParams(
          title: event.title, content: event.content, image: event.image),
    );
    switch (result) {
      case DataSuccess():
        emit(const UploadUserArticleSuccess());
      case DataFailed(error: final error):
        emit(UploadUserArticleError(message: error!.toString()));
    }
  }
}
