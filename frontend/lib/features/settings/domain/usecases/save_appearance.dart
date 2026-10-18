import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/appearance.dart';
import '../repository/settings_repository.dart';

class SaveAppearanceUseCase implements UseCase<DataState<void>, Appearance> {
  final SettingsRepository _settingsRepository;

  SaveAppearanceUseCase(this._settingsRepository);

  @override
  Future<DataState<void>> call(Appearance appearance) => _settingsRepository.saveAppearance(appearance);
}
