import '../../../../core/resources/data_state.dart';
import '../entities/appearance.dart';

/// Preferences of this device.
abstract class SettingsRepository {
  Future<DataState<Appearance>> getAppearance();

  Future<DataState<void>> saveAppearance(Appearance appearance);
}
