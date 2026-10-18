import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/delete_article.dart';
import '../../../domain/usecases/get_article.dart';
import '../../../domain/usecases/record_article_view.dart';
import 'article_detail_state.dart';

class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final GetArticleUseCase _getArticleUseCase;
  final DeleteArticleUseCase _deleteArticleUseCase;
  final RecordArticleViewUseCase _recordArticleViewUseCase;

  ArticleDetailCubit(
    ArticleEntity article,
    this._getArticleUseCase,
    this._deleteArticleUseCase,
    this._recordArticleViewUseCase,
  ) : super(ArticleDetailState(article: article));

  /// Adds the article to the reading history. A failure is not shown: the user is reading,
  /// and missing one entry of the history is not worth interrupting them.
  Future<void> recordView() => _recordArticleViewUseCase(state.article.id);

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
