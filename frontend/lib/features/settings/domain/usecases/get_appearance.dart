import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/appearance.dart';
import '../repository/settings_repository.dart';

class GetAppearanceUseCase implements UseCase<DataState<Appearance>, NoParams> {
  final SettingsRepository _settingsRepository;

  GetAppearanceUseCase(this._settingsRepository);

  @override
  Future<DataState<Appearance>> call(NoParams params) => _settingsRepository.getAppearance();
}
