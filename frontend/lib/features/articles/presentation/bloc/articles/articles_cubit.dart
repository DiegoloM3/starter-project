import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/usecases/get_articles.dart';
import 'articles_state.dart';

/// Articles of the news feed.
class ArticlesCubit extends Cubit<ArticlesState> {
  final GetArticlesUseCase _getArticlesUseCase;

  ArticlesCubit(this._getArticlesUseCase) : super(const ArticlesState());

  /// The current articles stay visible while loading and when it fails.
  Future<void> load() async {
    emit(ArticlesState(status: ArticlesStatus.loading, articles: state.articles));
    final result = await _getArticlesUseCase(const NoParams());
    if (result is DataSuccess) {
      emit(ArticlesState(status: ArticlesStatus.success, articles: result.data!));
    } else {
      emit(ArticlesState(status: ArticlesStatus.failure, articles: state.articles));
    }
  }
}
