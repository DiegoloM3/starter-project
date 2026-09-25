import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/presentation/widgets/app_toast.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_state.dart';

import '../widgets/guest_account_view.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/signed_in_account_view.dart';
import '../widgets/switch_account_dialog.dart';
import 'manage_account_screen.dart';

class ProfileScreen extends StatelessWidget {
  /// Rows contributed by the rest of the app (the dark-mode switch).
  /// Passed in rather than built here, so shared/account never depends on
  /// the features that use it.
  final List<Widget> sections;

  const ProfileScreen({super.key, this.sections = const []});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: _onActionStatusChanged,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.profileTitle)),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) => ListView(
            // Bottom padding clears the floating tab bar.
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              ProfileHeader(account: state.account),
              const SizedBox(height: 24),
              ProfileCard(
                children: [
                  ...sections,
                  ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: Text(context.l10n.manageAccount),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openManageAccount(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Fixed height so the layout doesn't jump when it appears.
              SizedBox(
                height: 4,
                child: state.isBusy ? const LinearProgressIndicator() : null,
              ),
              const SizedBox(height: 12),
              if (state.isGuest)
                GuestAccountView(state: state)
              else
                SignedInAccountView(state: state),
            ],
          ),
        ),
      ),
    );
  }

  void _openManageAccount(BuildContext context) {
    final cubit = context.read<AccountCubit>();
    cubit.resetActionStatus();
    unawaited(Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const ManageAccountScreen(),
        ),
      ),
    ));
  }

  void _onActionStatusChanged(BuildContext context, AccountState state) {
    switch (state.actionStatus) {
      case AccountActionStatus.connected:
        AppToast.show(context, message: context.l10n.accountConnected);
      case AccountActionStatus.switched:
        AppToast.show(context, message: context.l10n.signedInToAccount);
      case AccountActionStatus.signedOut:
        AppToast.show(context, message: context.l10n.signedOutAsGuest);
      case AccountActionStatus.deleted:
        AppToast.show(context, message: context.l10n.accountDeleted);
      case AccountActionStatus.nameUpdated:
        AppToast.show(context, message: context.l10n.nameUpdated);
      case AccountActionStatus.existingAccountFound:
        unawaited(confirmSwitchToExistingAccount(context));
      case AccountActionStatus.idle ||
            AccountActionStatus.inProgress ||
            AccountActionStatus.failed:
        break;
    }
  }
}
