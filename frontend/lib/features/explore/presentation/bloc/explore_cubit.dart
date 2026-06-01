import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'package:tortutip/features/explore/presentation/bloc/explore_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class ExploreCubit extends Cubit<ExploreState> {
  final GetAllCategoriesUseCase _getAllCategories;

  ExploreCubit(this._getAllCategories) : super(const ExploreInitial());

  Future<void> loadExplore({UserEntity? user}) async {
    emit(const ExploreLoading());

    final result = await _getAllCategories(const NoParams());
    if (!result.isSuccess) {
      emit(const ExploreError('No se pudieron cargar las categorías'));
      return;
    }

    emit(ExploreLoaded(
      categories: List<CategoryEntity>.from(result.data as List),
      streakDays: user?.streakDays ?? 0,
      categoryProgress: user?.overallProgress ?? 0.0,
    ));
  }
}
