import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/community_article.dart';
import '../../domain/usecases/get_community_article.dart';

sealed class CommunityArticleLookupState {
  const CommunityArticleLookupState();
}

class CommunityArticleLookupLoading extends CommunityArticleLookupState {
  const CommunityArticleLookupLoading();
}

class CommunityArticleLookupLoaded extends CommunityArticleLookupState {
  final CommunityArticleEntity article;
  const CommunityArticleLookupLoaded(this.article);
}

class CommunityArticleLookupFailure extends CommunityArticleLookupState {
  final String message;
  const CommunityArticleLookupFailure(this.message);
}

class CommunityArticleLookupCubit extends Cubit<CommunityArticleLookupState> {
  final GetCommunityArticleUseCase _getArticle;
  final String articleId;

  CommunityArticleLookupCubit(this._getArticle, this.articleId)
      : super(const CommunityArticleLookupLoading());

  Future<void> load() async {
    final result = await _getArticle(articleId);
    if (isClosed) return;
    if (result is DataSuccess<CommunityArticleEntity?> && result.data != null) {
      emit(CommunityArticleLookupLoaded(result.data!));
    } else {
      emit(CommunityArticleLookupFailure(
        result.error?.message ?? 'This article is no longer available.',
      ));
    }
  }
}
