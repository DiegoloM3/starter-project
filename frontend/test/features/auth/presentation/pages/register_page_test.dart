import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/register/register_page.dart';

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
    // Use a larger surface so the form content and button are fully in viewport.
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(800, 1200)),
        child: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: child ?? const RegisterPage(),
        ),
      ),
    );
  }

  testWidgets('renders all register UI elements', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('YOUR NAME'), findsOneWidget);
    expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('validates required fields and password length', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Scroll to make button visible, then tap
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    expect(find.text('Please confirm your password.'), findsOneWidget);
    expect(mockAuthBloc.addedEvents, isEmpty);
  });

  testWidgets('validates password mismatch and length < 6', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
      find.widgetWithText(TextFormField, 'At least 6 characters'),
      '123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Repeat password'),
      '456',
    );

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(mockAuthBloc.addedEvents, isEmpty);
  });

  testWidgets('dispatches RegisterRequested when fields are valid',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'John Doe'),
      'Jane Doe',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'name@example.com'),
      'jane@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'At least 6 characters'),
      'secretPass',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Repeat password'),
      'secretPass',
    );

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    final registerEvents =
        mockAuthBloc.addedEvents.whereType<RegisterRequested>().toList();
    expect(registerEvents.length, 1);
    expect(registerEvents.first.displayName, 'Jane Doe');
    expect(registerEvents.first.email, 'jane@example.com');
    expect(registerEvents.first.password, 'secretPass');
  });

  testWidgets('shows loading indicator when state is AuthLoading',
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

  testWidgets('shows error SnackBar on AuthError and adds ClearAuthError',
      (tester) async {
    final streamController = StreamController<AuthState>.broadcast();
    whenListen(
      mockAuthBloc,
      streamController.stream,
      initialState: const Unauthenticated(),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    streamController.add(const AuthError('Email already registered'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Email already registered'), findsOneWidget);
    expect(mockAuthBloc.addedEvents, contains(const ClearAuthError()));

    await streamController.close();
  });

  testWidgets('shows success SnackBar and pops on Authenticated',
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
                    child: const RegisterPage(),
                  ),
                ),
              ),
              child: const Text('Open Register'),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Register'));
    await tester.pumpAndSettle();
    expect(find.text('Create an Account'), findsOneWidget);

    streamController.add(const Authenticated(UserEntity(
      id: '2',
      email: 'jane@example.com',
      displayName: 'Jane Doe',
    )));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Account created! Welcome, Jane Doe!'), findsOneWidget);
    expect(find.text('Open Register'), findsOneWidget);

    await streamController.close();
  });
}
