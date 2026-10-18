import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/resources/data_state.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/appearance.dart';
import '../../../domain/usecases/get_appearance.dart';
import '../../../domain/usecases/save_appearance.dart';

/// Appearance of the whole app. The state is the appearance itself, nothing else is needed.
class AppearanceCubit extends Cubit<Appearance> {
  final GetAppearanceUseCase _getAppearanceUseCase;
  final SaveAppearanceUseCase _saveAppearanceUseCase;

  AppearanceCubit(this._getAppearanceUseCase, this._saveAppearanceUseCase) : super(Appearance.light);

  /// Keeps the light appearance when the saved one cannot be read.
  Future<void> load() async {
    final result = await _getAppearanceUseCase(const NoParams());
    if (result is DataSuccess) emit(result.data!);
  }

  /// The change is shown at once. If saving fails, it still applies until the app is closed.
  Future<void> choose(Appearance appearance) async {
    emit(appearance);
    await _saveAppearanceUseCase(appearance);
  }
}
