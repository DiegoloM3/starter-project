import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/login/login_page.dart';
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
      home: const LoginPage(),
    ),
  );
}

void main() {
  late MockAuthBloc bloc;

  setUpAll(() {
    registerFallbackValue(SignInWithGoogleEvent());
    registerFallbackValue(const LinkAnonymousWithGoogleEvent());
  });

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));
  });

  tearDown(() {
    bloc.close();
  });

  group('LoginPage return-to navigation', () {
    Widget buildPageWithRouter(
      AuthBloc authBloc, {
      String initialLocation = '/login',
    }) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginPage(),
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
            initialLocation: '/login?return=%2Farticle%2Fupload'),
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
  });

  group('LoginPage', () {
    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    });

    testWidgets('renders password field', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    });

    testWidgets('renders Sign in button', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      // AppBar says 'Sign in', button also says 'Sign in' → at least 1
      expect(find.text('Sign in'), findsWidgets);
      // The ElevatedButton with 'Sign in' text exists
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign in'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Google sign-in button', (tester) async {
      await tester.pumpWidget(_buildPage(bloc));

      expect(find.textContaining('Google'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CTA is replaced by progress indicator during AuthAuthenticating',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAuthenticating());

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();

      // The ElevatedButton CTA with 'Sign in' is replaced by CircularProgressIndicator
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Sign in'),
        ),
        findsNothing,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows SnackBar when AuthError is emitted', (tester) async {
      const error = AuthException(
        message: 'wrong-password',
        code: 'wrong-password',
      );

      whenListen(
        bloc,
        Stream.fromIterable([
          const AuthAnonymous(_anonUser),
          const AuthError(error, previousState: AuthAnonymous(_anonUser)),
        ]),
        initialState: const AuthAnonymous(_anonUser),
      );

      await tester.pumpWidget(_buildPage(bloc));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets(
        'Google button dispatches SignInWithGoogleEvent when NOT anonymous',
        (tester) async {
      when(() => bloc.state).thenReturn(_unauthUser);

      await tester.pumpWidget(_buildPage(bloc));
      await tester.tap(find.textContaining('Google'));
      await tester.pump();

      verify(() => bloc.add(any(that: isA<SignInWithGoogleEvent>()))).called(1);
      verifyNever(
          () => bloc.add(any(that: isA<LinkAnonymousWithGoogleEvent>())));
    });

    testWidgets(
        'Google button dispatches LinkAnonymousWithGoogleEvent when anonymous',
        (tester) async {
      when(() => bloc.state).thenReturn(const AuthAnonymous(_anonUser));

      await tester.pumpWidget(_buildPage(bloc));
      await tester.tap(find.textContaining('Google'));
      await tester.pump();

      verify(() =>
              bloc.add(any(that: isA<LinkAnonymousWithGoogleEvent>())))
          .called(1);
      verifyNever(() => bloc.add(any(that: isA<SignInWithGoogleEvent>())));
    });
  });
}
