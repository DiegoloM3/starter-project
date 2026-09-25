import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';

import 'account_error_message.dart';
import 'email_sign_in_form.dart';
import 'sign_in_option_button.dart';

class GuestAccountView extends StatefulWidget {
  final AccountState state;

  const GuestAccountView({super.key, required this.state});

  @override
  State<GuestAccountView> createState() => _GuestAccountViewState();
}

class _GuestAccountViewState extends State<GuestAccountView> {
  bool _showEmailForm = false;

  void _setEmailFormVisible(bool visible) {
    // An error from the other option doesn't belong on this one.
    context.read<AccountCubit>().resetActionStatus();
    setState(() => _showEmailForm = visible);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final errorText = state.actionStatus == AccountActionStatus.failed
        ? state.errorReason?.messageIn(context.l10n)
        : null;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.keepYourArticles, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          context.l10n.guestExplanation,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _buildOptions(state, errorText),
      ],
    );
  }

  Widget _buildOptions(AccountState state, String? errorText) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: _showEmailForm
          ? EmailSignInForm(
              isBusy: state.isBusy,
              errorText: errorText,
              onBack: () => _setEmailFormVisible(false),
            )
          : _SignInOptions(
              isBusy: state.isBusy,
              errorText: errorText,
              onEmailSelected: () => _setEmailFormVisible(true),
            ),
    );
  }
}

class _SignInOptions extends StatelessWidget {
  final bool isBusy;
  final String? errorText;
  final VoidCallback onEmailSelected;

  const _SignInOptions({
    required this.isBusy,
    required this.errorText,
    required this.onEmailSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AccountCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SignInOptionButton(
          option: SignInOption.google,
          onPressed:
              isBusy ? null : () => cubit.connect(const GoogleSignInMethod()),
        ),
        const SizedBox(height: 12),
        SignInOptionButton(
          option: SignInOption.email,
          onPressed: isBusy ? null : onEmailSelected,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText!,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }
}
