import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/categories/data/data_sources/category_remote_data_source.dart';
import 'package:tortutip/features/categories/data/models/category_model.dart';
import 'package:tortutip/features/categories/data/repository/category_repository_impl.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';

class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(mockDataSource);
  });

  group('CategoryRepositoryImpl.getAllCategories', () {
    final models = <CategoryModel>[];

    test('should_return_DataSuccess_with_entities_when_datasource_succeeds',
        () async {
      when(() => mockDataSource.getAllCategories())
          .thenAnswer((_) async => models);

      final result = await repository.getAllCategories();

      expect(result, isA<DataSuccess<List<CategoryEntity>>>());
    });

    test('should_return_DataFailed_when_datasource_throws', () async {
      when(() => mockDataSource.getAllCategories())
          .thenThrow(Exception('Firestore error'));

      final result = await repository.getAllCategories();

      expect(result, isA<DataFailed<List<CategoryEntity>>>());
    });
  });
}
