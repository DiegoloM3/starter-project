import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/config/routes/session_redirect.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';

import '../../helpers/fixtures.dart';

void main() {
  String? redirect(SessionState session, String location) =>
      SessionRedirect.resolve(session: session, location: location);

  group('while the session is unknown', () {
    const session = SessionUnknown();

    test('everything goes to the splash', () {
      expect(redirect(session, AppRoutes.home), AppRoutes.splash);
      expect(redirect(session, AppRoutes.signIn), AppRoutes.splash);
    });

    test('the splash itself stays', () {
      expect(redirect(session, AppRoutes.splash), isNull);
    });
  });

  group('when signed out', () {
    const session = SessionUnauthenticated();

    test('public routes stay', () {
      for (final location in AppRoutes.public) {
        expect(redirect(session, location), isNull, reason: location);
      }
    });

    test('private routes and the splash go to welcome', () {
      expect(redirect(session, AppRoutes.home), AppRoutes.welcome);
      expect(redirect(session, AppRoutes.settings), AppRoutes.welcome);
      expect(redirect(session, AppRoutes.splash), AppRoutes.welcome);
    });
  });

  group('when signed in', () {
    const session = SessionAuthenticated(user);

    test('the welcome flow and the splash go home', () {
      expect(redirect(session, AppRoutes.splash), AppRoutes.home);
      for (final location in AppRoutes.public) {
        expect(redirect(session, location), AppRoutes.home, reason: location);
      }
    });

    test('private routes stay', () {
      expect(redirect(session, AppRoutes.home), isNull);
      expect(redirect(session, AppRoutes.settingsCategory), isNull);
    });
  });
}
