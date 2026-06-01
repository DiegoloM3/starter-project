import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetAllCategoriesUseCase _getAllCategories;
  CategoryCubit(this._getAllCategories) : super(const CategoryInitial());

  Future<void> loadCategories() async {
    emit(const CategoryLoading());
    final result = await _getAllCategories(const NoParams());
    if (result.isSuccess) {
      emit(CategoryLoaded(result.data!));
    } else {
      emit(CategoryError(_mapErrorToMessage(result.error!)));
    }
  }

  String _mapErrorToMessage(Exception error) {
    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable' => 'Sin conexión. Inténtalo de nuevo',
        _             => 'No se pudieron cargar las categorías',
      };
    }
    return 'No se pudieron cargar las categorías';
  }
}
