import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<DataState<List<CategoryEntity>>> getAllCategories();
}
