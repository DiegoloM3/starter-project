import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../repository/bookmark_repository.dart';
import 'bookmark_params.dart';

class IsBookmarkedUseCase implements UseCase<bool, BookmarkIdentifierParams> {
  final BookmarkRepository _bookmarkRepository;

  IsBookmarkedUseCase(this._bookmarkRepository);

  @override
  Future<bool> call({BookmarkIdentifierParams? params}) =>
      _bookmarkRepository.isBookmarked(params!.sourceId, params.source);
}
