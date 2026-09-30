import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/entities/article_draft.dart';
import '../../domain/repository/article_draft_repository.dart';
import '../data_sources/local/article_draft_local_data_source.dart';

class ArticleDraftRepositoryImpl implements ArticleDraftRepository {
  final ArticleDraftLocalDataSource _articleDraftLocalDataSource;

  ArticleDraftRepositoryImpl(this._articleDraftLocalDataSource);

  @override
  Future<DataState<ArticleDraftEntity?>> getSavedDraft() async {
    try {
      return DataSuccess(_articleDraftLocalDataSource.readDraft()?.toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> saveDraft(ArticleDraftEntity draft) async {
    try {
      await _articleDraftLocalDataSource.writeDraft(draft);
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> deleteSavedDraft() async {
    try {
      await _articleDraftLocalDataSource.deleteDraft();
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
