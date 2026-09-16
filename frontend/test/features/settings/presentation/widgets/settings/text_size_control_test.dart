import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/text_size_control.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the step name and a preview, and reports slider changes', (tester) async {
    TextSizePreference? chosen;
    await pumpApp(
      tester,
      TextSizeControl(selected: TextSizePreference.large, onChanged: (s) => chosen = s),
    );

    expect(find.text('Large'), findsOneWidget);
    expect(find.text(TextSizeControl.previewText), findsOneWidget);

    tester.widget<Slider>(find.byType(Slider)).onChanged!(0);
    expect(chosen, TextSizePreference.small);
  });
}
