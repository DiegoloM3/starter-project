import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Color backgroundOfInitials(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.ancestor(of: find.text('MH'), matching: find.byType(Container)).first,
    );
    return (container.decoration as BoxDecoration).color!;
  }

  testWidgets('without a photo it shows initials on the ink block for the current user',
      (tester) async {
    await pumpApp(tester, const UserAvatar(name: 'Miriam Hale', isCurrentUser: true));

    expect(find.text('MH'), findsOneWidget);
    expect(backgroundOfInitials(tester), AppPalette.light.accent);
  });

  testWidgets('other authors get the surface tone', (tester) async {
    await pumpApp(tester, const UserAvatar(name: 'Miriam Hale'));

    expect(backgroundOfInitials(tester), AppPalette.light.surface);
  });

  testWidgets('a blank photo url counts as no photo', (tester) async {
    await pumpApp(tester, const UserAvatar(name: 'Miriam Hale', photoUrl: '  '));

    expect(find.text('MH'), findsOneWidget);
  });

  testWidgets('ringed avatars are padded by the ring', (tester) async {
    await pumpApp(tester, const Center(child: UserAvatar(name: 'Miriam Hale', size: 88, ringed: true)));

    final size = tester.getSize(find.byType(UserAvatar));
    expect(size.width, 96);
  });
}
