import '../../domain/entities/article_draft_entity.dart';
import '../../domain/repository/draft_repository.dart';
import '../data_sources/draft_local_datasource.dart';
import '../models/article_draft_model.dart';

class DraftRepositoryImpl implements DraftRepository {
  final DraftLocalDataSource _dataSource;
  const DraftRepositoryImpl(this._dataSource);

  @override
  Future<void> saveDraft(ArticleDraftEntity draft) =>
      _dataSource.saveDraft(ArticleDraftModel.fromEntity(draft));

  @override
  Future<ArticleDraftEntity?> loadDraft() => _dataSource.loadDraft();

  @override
  Future<void> clearDraft() => _dataSource.clearDraft();
}
