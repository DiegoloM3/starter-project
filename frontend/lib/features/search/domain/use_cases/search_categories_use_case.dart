import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/search/domain/repository/search_repository.dart';

class SearchCategoriesUseCase
    implements UseCase<DataState<List<CategoryEntity>>, String> {
  final SearchRepository _repository;

  SearchCategoriesUseCase(this._repository);

  @override
  Future<DataState<List<CategoryEntity>>> call(String query) {
    return _repository.searchCategories(query);
  }
}
