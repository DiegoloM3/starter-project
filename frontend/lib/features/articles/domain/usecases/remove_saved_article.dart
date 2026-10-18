import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import 'mock/mock_articles.dart';

class RemoveSavedArticleUseCase implements UseCase<DataState<void>, String> {
  @override
  Future<DataState<void>> call(String articleId) async {
    await Future.delayed(mockNetworkDelay);
    return const DataSuccess(null);
  }
}
