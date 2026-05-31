import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../repository/bookmark_repository.dart';
import 'bookmark_params.dart';

class AddBookmarkUseCase implements UseCase<void, BookmarkParams> {
  final BookmarkRepository _bookmarkRepository;

  const AddBookmarkUseCase(this._bookmarkRepository);

  @override
  Future<void> call({BookmarkParams? params}) =>
      _bookmarkRepository.addBookmark(params!.bookmark);
}
