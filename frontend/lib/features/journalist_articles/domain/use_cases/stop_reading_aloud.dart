import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../repository/article_narrator_repository.dart';

class StopReadingAloudUseCase implements UseCase<DataState<void>, void> {
  final ArticleNarratorRepository _articleNarratorRepository;

  StopReadingAloudUseCase(this._articleNarratorRepository);

  @override
  Future<DataState<void>> call({void params}) {
    return _articleNarratorRepository.stopReading();
  }
}
