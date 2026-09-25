import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_content_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/connect_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/delete_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/get_current_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/switch_to_existing_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/update_display_name_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/screens/welcome_screen.dart';

class _GuestRepository implements AccountRepository {
  @override
  Future<DataState<AccountEntity>> getCurrentAccount() async =>
      const DataSuccess(AccountEntity(id: 'guest', isGuest: true));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoContent implements AccountContentRepository {
  @override
  Future<DataState<void>> deleteAllContent() async => const DataSuccess(null);
}

Widget _app({required VoidCallback onDone}) {
  final repository = _GuestRepository();
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: BlocProvider(
      create: (_) => AccountCubit(
        GetCurrentAccountUseCase(repository),
        ConnectAccountUseCase(repository),
        SwitchToExistingAccountUseCase(repository),
        SignOutUseCase(repository),
        DeleteAccountUseCase(repository, _NoContent()),
        UpdateDisplayNameUseCase(repository),
      ),
      child: WelcomeScreen(onDone: (_) => onDone()),
    ),
  );
}

void main() {
  testWidgets('"Continue as guest" goes straight into the app',
      (tester) async {
    var entered = false;
    await tester.pumpWidget(_app(onDone: () => entered = true));
    await tester.pump();

    await tester.tap(find.text('Continue as guest'));

    expect(entered, isTrue);
  });

  testWidgets(
      'Google is the first thing offered; email is a link at the very '
      'bottom, not an equally-weighted button', (tester) async {
    await tester.pumpWidget(_app(onDone: () {}));
    await tester.pump();

    final googleTop = tester.getTopLeft(find.text('Continue with Google')).dy;
    final guestTop = tester.getTopLeft(find.text('Continue as guest')).dy;
    final emailLinkTop = tester
        .getTopLeft(find.text("Don't have an account? Sign up with email"))
        .dy;
    expect(googleTop, lessThan(guestTop));
    expect(guestTop, lessThan(emailLinkTop));
    // Not a full button here anymore -- that's now only how the email
    // link's tap target renders (a plain TextButton, not the same
    // full-width outlined style Google uses).
    expect(find.text('Continue with email'), findsNothing);
  });

  testWidgets('the bottom email link still opens the same sign-in form',
      (tester) async {
    await tester.pumpWidget(_app(onDone: () {}));
    await tester.pump();

    await tester.tap(find.text("Don't have an account? Sign up with email"));
    await tester.pump();

    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('fits a small phone with a large system font', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(onDone: () {}));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
