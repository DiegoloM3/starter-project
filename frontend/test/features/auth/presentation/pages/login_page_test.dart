import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/login/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {
  final List<AuthEvent> addedEvents = [];

  @override
  void add(AuthEvent event) {
    addedEvents.add(event);
    // Do NOT call super.add() — MockBloc stream is driven by whenListen.
  }
}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget buildWidget({Widget? child}) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: child ?? const LoginPage(),
      ),
    );
  }

  testWidgets('renders all login UI elements', (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsNWidgets(2)); // AppBar and button
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('shows validation errors when fields are empty', (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Tap Sign In button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    expect(mockAuthBloc.addedEvents, isEmpty);
  });

  testWidgets('shows validation error on invalid email format', (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'name@example.com'),
      'invalid-email',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      '123456',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(mockAuthBloc.addedEvents, isEmpty);
  });

  testWidgets('dispatches LoginRequested when credentials are valid',
      (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'name@example.com'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter your password'),
      'secret123',
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    final loginEvents =
        mockAuthBloc.addedEvents.whereType<LoginRequested>().toList();
    expect(loginEvents.length, 1);
    expect(loginEvents.first.email, 'user@example.com');
    expect(loginEvents.first.password, 'secret123');
  });

  testWidgets('shows activity indicator when state is AuthLoading',
      (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthLoading(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('shows SnackBar and adds ClearAuthError on AuthError',
      (tester) async {
    final streamController = StreamController<AuthState>.broadcast();
    whenListen(
      mockAuthBloc,
      streamController.stream,
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    streamController.add(const AuthError('Invalid credentials'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Invalid credentials'), findsOneWidget);
    expect(mockAuthBloc.addedEvents, contains(const ClearAuthError()));

    await streamController.close();
  });

  testWidgets('shows welcome SnackBar and pops on Authenticated',
      (tester) async {
    final streamController = StreamController<AuthState>.broadcast();
    whenListen(
      mockAuthBloc,
      streamController.stream,
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider<AuthBloc>.value(
                    value: mockAuthBloc,
                    child: const LoginPage(),
                  ),
                ),
              ),
              child: const Text('Open Login'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);

    streamController.add(const Authenticated(UserEntity(
      id: '1',
      email: 'alex@example.com',
      displayName: 'Alex',
    )));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Alex!'), findsOneWidget);
    expect(find.text('Open Login'), findsOneWidget);

    await streamController.close();
  });

  testWidgets('toggles password visibility when eye icon is tapped',
      (tester) async {
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Password field should be obscured initially — check via EditableText
    final editableTexts = tester.widgetList<EditableText>(find.byType(EditableText)).toList();
    // Email is first, password is second
    expect(editableTexts.length, greaterThanOrEqualTo(2));
    expect(editableTexts[1].obscureText, isTrue);

    // Tap eye icon to show password
    await tester.tap(find.byIcon(Ionicons.eyeOffOutline));
    await tester.pumpAndSettle();

    final editableTextsAfter =
        tester.widgetList<EditableText>(find.byType(EditableText)).toList();
    expect(editableTextsAfter[1].obscureText, isFalse);
  });
}
