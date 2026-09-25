import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';

import '../widgets/account_error_message.dart';
import '../widgets/email_sign_in_form.dart';
import '../widgets/sign_in_option_button.dart';
import '../widgets/switch_account_dialog.dart';

/// The first screen of a fresh install: sign in with Google or email, or
/// just start reading as a guest. It's the same connect/switch flow the
/// Profile tab offers later, so it also brings back an account after a
/// reinstall.
class WelcomeScreen extends StatefulWidget {
  /// Leaves this screen for the app, whichever way the user chose.
  final void Function(BuildContext context) onDone;

  const WelcomeScreen({super.key, required this.onDone});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showEmailForm = false;

  void _setEmailFormVisible(bool visible) {
    context.read<AccountCubit>().resetActionStatus();
    setState(() => _showEmailForm = visible);
  }

  void _onActionStatusChanged(BuildContext context, AccountState state) {
    switch (state.actionStatus) {
      case AccountActionStatus.connected || AccountActionStatus.switched:
        widget.onDone(context);
      case AccountActionStatus.existingAccountFound:
        unawaited(confirmSwitchToExistingAccount(context));
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: _onActionStatusChanged,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) => LayoutBuilder(
              // Centered on tall phones, scrollable when the keyboard or a
              // large system font leaves too little room.
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Brand(),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 4,
                        child: state.isBusy
                            ? const LinearProgressIndicator()
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildOptions(context, state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, AccountState state) {
    final theme = Theme.of(context);
    final errorText = state.actionStatus == AccountActionStatus.failed
        ? state.errorReason?.messageIn(context.l10n)
        : null;
    if (_showEmailForm) {
      return EmailSignInForm(
        isBusy: state.isBusy,
        errorText: errorText,
        onBack: () => _setEmailFormVisible(false),
      );
    }
    // Google first and full-width, so it reads as the one obvious way in;
    // guest right under it as the no-commitment fallback; email demoted to
    // a plain link at the very bottom ("no account? sign up"), the usual
    // place apps put the option that isn't one tap away.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.welcomeSignInHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        SignInOptionButton(
          option: SignInOption.google,
          onPressed: state.isBusy
              ? null
              : () => context
                  .read<AccountCubit>()
                  .connect(const GoogleSignInMethod()),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 20),
        TextButton(
          onPressed: state.isBusy ? null : () => widget.onDone(context),
          child: Text(context.l10n.continueAsGuest),
        ),
        Text(
          context.l10n.connectLater,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: state.isBusy ? null : () => _setEmailFormVisible(true),
          child: Text(context.l10n.noAccountSignUpWithEmail),
        ),
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.newspaper,
              size: 36, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: theme.textTheme.displayLarge,
            children: [
              const TextSpan(text: 'Daily '),
              TextSpan(
                text: 'News',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.welcomeTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
