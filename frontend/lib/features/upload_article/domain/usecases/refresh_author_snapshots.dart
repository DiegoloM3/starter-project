import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/user_article_repository.dart';

class RefreshAuthorSnapshotsUseCase implements UseCase<void, void> {
  final UserArticleRepository _repository;

  RefreshAuthorSnapshotsUseCase(this._repository);

  @override
  Future<void> call({void params}) =>
      _repository.refreshAuthorSnapshotsForCurrentUser();
}
