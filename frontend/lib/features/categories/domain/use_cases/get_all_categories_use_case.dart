import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/repository/category_repository.dart';

class GetAllCategoriesUseCase
    implements UseCase<DataState<List<CategoryEntity>>, NoParams> {
  final CategoryRepository _repository;
  GetAllCategoriesUseCase(this._repository);

  @override
  Future<DataState<List<CategoryEntity>>> call(NoParams params) {
    return _repository.getAllCategories();
  }
}
