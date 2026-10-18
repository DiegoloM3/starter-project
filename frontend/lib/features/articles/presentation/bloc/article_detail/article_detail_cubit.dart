import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/delete_article.dart';
import '../../../domain/usecases/get_article.dart';
import 'article_detail_state.dart';

class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final GetArticleUseCase _getArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;

  ArticleDetailCubit(ArticleEntity article, this._getArticleUseCase, this._deleteArticleUseCase)
    : super(ArticleDetailState(article: article));

  /// Loads the latest version, for example after the author edits it.
  Future<void> refresh() async {
    final result = await _getArticleUseCase(state.article.id);
    if (result is DataSuccess) emit(ArticleDetailState(article: result.data!));
  }

  Future<void> delete() async {
    emit(ArticleDetailState(article: state.article, status: ArticleDetailStatus.deleting));
    final result = await _deleteArticleUseCase(state.article.id);
    final status = result is DataSuccess ? ArticleDetailStatus.deleted : ArticleDetailStatus.deleteFailure;
    emit(ArticleDetailState(article: state.article, status: status));
  }
}
