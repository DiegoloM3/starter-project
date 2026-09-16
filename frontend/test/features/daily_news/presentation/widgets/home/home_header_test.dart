import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/home/home_header.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  const user = UserEntity(id: '1', displayName: 'Miriam Hale');

  testWidgets('greets by time of day and shows the long date', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      HomeHeader(
        user: user,
        now: DateTime(2026, 9, 15, 9, 40),
        onAvatarTap: () => tapped = true,
      ),
    );

    expect(find.text('GOOD MORNING, MIRIAM'), findsOneWidget);
    expect(find.text('TUESDAY, 15 SEPTEMBER'), findsOneWidget);

    await tester.tap(find.byType(UserAvatar));
    expect(tapped, isTrue);
  });

  testWidgets('the evening greeting changes with the hour', (tester) async {
    await pumpApp(
      tester,
      HomeHeader(user: user, now: DateTime(2026, 9, 15, 21), onAvatarTap: () {}),
    );

    expect(find.text('GOOD EVENING, MIRIAM'), findsOneWidget);
  });
}
