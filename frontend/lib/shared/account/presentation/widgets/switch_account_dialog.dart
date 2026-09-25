import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';

/// Shown when the Google/email sign-in the user picked already belongs to an
/// account: switch to it, or stay as they are.
Future<void> confirmSwitchToExistingAccount(BuildContext context) async {
  final cubit = context.read<AccountCubit>();
  final shouldSwitch = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(dialogContext.l10n.alreadyHaveAccountTitle),
      content: Text(dialogContext.l10n.alreadyHaveAccountMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(dialogContext.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(dialogContext.l10n.switchAccount),
        ),
      ],
    ),
  );
  if (shouldSwitch ?? false) {
    await cubit.switchToExistingAccount();
  } else {
    cubit.resetActionStatus();
  }
}
