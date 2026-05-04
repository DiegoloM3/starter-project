import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/signup/signup_page.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _anonUser = AuthUserEntity(
  uid: 'anon',
  providerId: 'anonymous',
  isAnonymous: true,
);

const _unauthUser = AuthUnauthenticated();

Widget _buildPage(AuthBloc bloc) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SignupPage(),
    ),
  );
}

Future<void> _fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(
      find.byKey(const Key('signup_displayname_field')), 'Alice');
  await tester.enterText(
      find.byKey(const Key('signup_email_field')), 'alice@example.com');
  await tester.enterText(
      find.byKey(const Key('signup_password_field')), 'pass1234');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
}

void main() {
  late MockAuthBloc bloc;

  setUpAll(() {
    registerFallbackValue(
      const SignUpWithEmailEvent(
        SignUpParams(email: '', password: '', displayName: ''),
      ),
    );
    registerFallbackValue(
      const LinkAnonymousWithEmailEvent(
        SignUpParams(email: '', password: '', displayName: ''),
      ),
    );
    registerFallbackValue(const LinkAnonymousWithGoogleEvent());
  });

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
  });

  tearDown(() => bloc.close());

  group('SignupPage return-to navigation', () {
    Widget buildPageWithRouter(
      AuthBloc authBloc, {
      String initialLocation = '/signup',
    }) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/signup',
            builder: (context, state) => const SignupPage(),
          ),
          GoRoute(
            path: '/article/upload',
            builder: (context, state) => const Scaffold(
              body: Text('ArticleUploadPage'),
            ),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Text('Home'),
            ),
          ),
        ],
      );
      return BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    testWidgets(
        'navigates to ?return= path on AuthAuthenticated when return param present',
        (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          const AuthAnonymous(_anonUser),
          const AuthAuthenticated(AuthUserEntity(
            uid: 'user-1',
            email: 'a@b.com',
            displayName: 'A',
            providerId: 'password',
            isAnonymous: false,
          )),
        ]),
        initialState: const AuthAnonymous(_anonUser),
      );

      await tester.pumpWidget(
        buildPageWithRouter(bloc,
            initialLocation: '/signup?return=%2Farticle%2Fupload'),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('ArticleUploadPage'), findsOneWidget);
    });

    testWidgets(
        'navigates to / on AuthAuthenticated when no return param present',
        (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          const AuthAnonymous(_anonUser),
          const AuthAuthenticated(AuthUserEntity(
            uid: 'user-1',
            email: 'a@b.com',
            displayName: 'A',
            providerId: 'password',
            isAnonymous: false,
          )),
        ]),
        initialState: const AuthAnonymous(_anonUser),
      );

      await tester.pumpWidget(buildPageWithRouter(bloc));
      await tester.pump();
      await tester.pump();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets(
        'navigates to ?return= on AuthAuthenticated after link-anonymous (anon to authenticated)',
        (tester) async {
      whenListen(
        bloc,
        Stream.fromIterable([
          const AuthAnonymous(_anonUser),
          const AuthAuthenticated(AuthUserEntity(
            uid: 'anon',
            email: 'a@b.com',
            displayName: 'A',
            providerId: 'password',
            isAnonymous: false,
          )),
        ]),
        initialState: const AuthAnonymous(_anonUser),
      );

      await tester.pumpWidget(
        buildPageWithRouter(bloc,
            initialLocation: '/signup?return=%2Farticle%2Fupload'),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('ArticleUploadPage'), findsOneWidget);
    });
  });

  group('SignupPage', () {
    testWidgets('renders displayName field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(find.byKey(const Key('signup_displayname_field')), findsOneWidget);
    });

    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(find.byKey(const Key('signup_email_field')), findsOneWidget);
    });

    testWidgets('renders password field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(find.byKey(const Key('signup_password_field')), findsOneWidget);
    });

    testWidgets('renders Create account button', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Create account'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows CircularProgressIndicator when AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'CTA is replaced by progress indicator during AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Create account'),
        ),
        findsNothing,
      );
    });

    testWidgets(
        'dispatches SignUpWithEmailEvent when state is NOT AuthAnonymous',
        (tester) async {
      when(() => bloc.state).thenReturn(_unauthUser);

      await tester.pumpWidget(_buildPage(bloc));
      await _fillAndSubmit(tester);

      verify(() => bloc.add(any(that: isA<SignUpWithEmailEvent>()))).called(1);
      verifyNever(() => bloc.add(any(that: isA<LinkAnonymousWithEmailEvent>())));
    });

    testWidgets(
        'dispatches LinkAnonymousWithEmailEvent when state is AuthAnonymous',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));

      await tester.pumpWidget(_buildPage(bloc));
      await _fillAndSubmit(tester);

      verify(() => bloc.add(any(that: isA<LinkAnonymousWithEmailEvent>())))
          .called(1);
      verifyNever(() => bloc.add(any(that: isA<SignUpWithEmailEvent>())));
    });
  });
}
