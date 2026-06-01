import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/categories/data/data_sources/category_remote_data_source.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/repository/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _dataSource;
  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<DataState<List<CategoryEntity>>> getAllCategories() async {
    try {
      final models = await _dataSource.getAllCategories();
      return DataSuccess(models.cast<CategoryEntity>().toList());
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }
}
