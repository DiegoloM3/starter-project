import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/theme_mode_selector.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('reports the tapped segment', (tester) async {
    AppThemeMode? chosen;
    await pumpApp(
      tester,
      ThemeModeSelector(selected: AppThemeMode.system, onChanged: (mode) => chosen = mode),
    );

    await tester.tap(find.text('Light'));
    expect(chosen, AppThemeMode.light);
  });
}
