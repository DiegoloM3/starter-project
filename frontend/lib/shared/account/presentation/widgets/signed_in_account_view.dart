import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';

import 'account_error_message.dart';

class SignedInAccountView extends StatelessWidget {
  final AccountState state;

  const SignedInAccountView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = state.actionStatus == AccountActionStatus.failed
        ? state.errorReason?.messageIn(context.l10n)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (errorText != null) ...[
          Text(
            errorText,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
        Center(
          child: TextButton.icon(
            onPressed: state.isBusy ? null : () => _confirmSignOut(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            icon: const Icon(Icons.logout),
            label: Text(context.l10n.signOut),
          ),
        ),
      ],
    );
  }

  // Asked first: one stray tap shouldn't drop someone back to guest.
  Future<void> _confirmSignOut(BuildContext context) async {
    final cubit = context.read<AccountCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.signOutQuestion),
        content: Text(dialogContext.l10n.signOutWarning),
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
            child: Text(dialogContext.l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.signOut();
  }
}
