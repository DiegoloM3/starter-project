import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/journalist_article.dart';
import '../../../domain/params/increment_article_view_count_params.dart';
import '../../../domain/use_cases/increment_article_view_count.dart';
import 'article_reader_state.dart';

/// Drives one community article being read.
///
/// This is the caller `IncrementArticleViewCountUseCase` was waiting for: the
/// use case was written in stage 3 but deliberately left unwired, because
/// until this screen existed there was no honest moment at which somebody had
/// read an article (see `docs/DECISIONS.md` decision #24).
class ArticleReaderCubit extends Cubit<ArticleReaderState> {
  final IncrementArticleViewCountUseCase _incrementViewCount;

  ArticleReaderCubit(
    this._incrementViewCount, {
    required JournalistArticleEntity article,
  }) : super(ArticleReaderState(article: article));

  /// Counts this reading, once.
  Future<void> recordView() async {
    final articleId = state.article.id;

    if (state.viewRecorded || articleId == null) {
      return;
    }

    // Counted on screen straight away and never rolled back. A view is a
    // statistic, not a transaction: interrupting somebody's reading with an
    // error because a counter did not tick would cost more than the count is
    // worth. The backend's number stays authoritative on the next load.
    emit(state.copyWith(
      article: state.article.copyWith(
        viewCount: state.article.viewCount + 1,
      ),
      viewRecorded: true,
    ));

    await _incrementViewCount(IncrementArticleViewCountParams(articleId));
  }
}
