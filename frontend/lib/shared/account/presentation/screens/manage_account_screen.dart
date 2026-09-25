import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_provider.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';

import '../widgets/account_error_message.dart';
import '../widgets/confirm_password_dialog.dart';
import '../widgets/profile_card.dart';
import 'privacy_policy_screen.dart';

/// What app stores require an account screen to offer: how you sign in,
/// the privacy policy, and deleting the account from inside the app.
class ManageAccountScreen extends StatelessWidget {
  const ManageAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        // The Profile tab underneath shows the confirmation message.
        if (state.actionStatus == AccountActionStatus.deleted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.manageAccount)),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              ProfileCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: Text(context.l10n.signedInWith),
                    subtitle: Text(_signInDescription(context.l10n, state)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(context.l10n.privacyPolicy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 4,
                child: state.isBusy ? const LinearProgressIndicator() : null,
              ),
              const SizedBox(height: 12),
              _DeleteAccountSection(state: state),
            ],
          ),
        ),
      ),
    );
  }

  String _signInDescription(AppLocalizations l10n, AccountState state) {
    final account = state.account;
    if (state.isGuest || account == null) {
      return l10n.guestOnThisPhone;
    }
    final method = switch (account.signInProvider) {
      SignInProvider.google => l10n.signInGoogle,
      SignInProvider.email => l10n.signInEmailAndPassword,
      null => l10n.yourAccount,
    };
    final email = account.email;
    return email == null ? method : '$method · $email';
  }
}

class _DeleteAccountSection extends StatelessWidget {
  final AccountState state;

  const _DeleteAccountSection({required this.state});

  String _title(AppLocalizations l10n) =>
      state.isGuest ? l10n.deleteMyData : l10n.deleteAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = state.actionStatus == AccountActionStatus.failed
        ? state.errorReason?.messageIn(context.l10n)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.isGuest
              ? context.l10n.deleteMyDataDescription
              : context.l10n.deleteAccountDescription,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        if (errorText != null) ...[
          Text(
            errorText,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: state.isBusy ? null : () => _startDeletion(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          icon: const Icon(Icons.delete_forever_outlined),
          label: Text(_title(context.l10n)),
        ),
      ],
    );
  }

  Future<void> _startDeletion(BuildContext context) async {
    final cubit = context.read<AccountCubit>();
    final confirmed = await _confirm(context);
    if (!confirmed || !context.mounted) return;
    final account = state.account;
    // Firebase only deletes an account that signed in recently, so a real
    // account proves who it is again first. A guest has nothing to prove.
    switch (state.isGuest ? null : account?.signInProvider) {
      case SignInProvider.email:
        final password = await ConfirmPasswordDialog.show(context);
        if (password == null) return;
        await cubit.deleteAccount(
          EmailSignInMethod(email: account?.email ?? '', password: password),
        );
      case SignInProvider.google:
        await cubit.deleteAccount(const GoogleSignInMethod());
      case null:
        await cubit.deleteAccount(null);
    }
  }

  Future<bool> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(state.isGuest
            ? dialogContext.l10n.deleteMyDataQuestion
            : dialogContext.l10n.deleteAccountQuestion),
        content: Text(
          state.isGuest
              ? dialogContext.l10n.deleteMyDataWarning
              : dialogContext.l10n.deleteAccountWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(dialogContext.l10n.delete),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
