import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../repository/bookmark_repository.dart';
import 'bookmark_params.dart';

class RemoveBookmarkUseCase implements UseCase<void, BookmarkIdentifierParams> {
  final BookmarkRepository _bookmarkRepository;

  RemoveBookmarkUseCase(this._bookmarkRepository);

  @override
  Future<void> call({BookmarkIdentifierParams? params}) =>
      _bookmarkRepository.removeBookmark(params!.sourceId, params.source);
}
