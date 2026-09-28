import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/remote/remote_article_state.dart';

/// UI state machine for remote top headlines.
@injectable
class RemoteArticlesBloc
    extends Bloc<RemoteArticlesEvent, RemoteArticlesState> {
  static final _log = Logger('RemoteArticlesBloc');

  final GetArticleUseCase _getArticleUseCase;

  RemoteArticlesBloc(this._getArticleUseCase)
      : super(const RemoteArticlesLoading()) {
    on<GetArticles>(onGetArticles);
  }

  void onGetArticles(
      GetArticles event, Emitter<RemoteArticlesState> emit) async {
    _log.info('onGetArticles → fetching articles');

    final dataState = await _getArticleUseCase();

    if (dataState is DataSuccess) {
      final articles = dataState.data ?? [];
      _log.info('onGetArticles → success, ${articles.length} articles');
      emit(RemoteArticlesDone(articles));
      return;
    }

    if (dataState is DataDioFailed) {
      _log.severe(
        'onGetArticles → DataDioFailed '
        '[type=${dataState.error?.type} '
        'status=${dataState.error?.response?.statusCode}]',
        dataState.error,
      );
      emit(
        RemoteArticlesError(
          dataState.error?.message ??
              dataState.error?.toString() ??
              'Could not load articles.',
        ),
      );
      return;
    }

    if (dataState is DataGenericFailed) {
      _log.severe(
          'onGetArticles → DataGenericFailed: ${dataState.errorMessage}');
      emit(
        RemoteArticlesError(
          dataState.errorMessage ?? 'Could not load articles.',
        ),
      );
    }
  }
}
