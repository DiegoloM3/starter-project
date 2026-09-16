import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/splash_screen.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/brand_mark.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows only the logo while the session is resolved', (tester) async {
    await pumpApp(tester, const SplashScreen());

    expect(find.byType(BrandMark), findsOneWidget);
  });
}
