import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/centered_form.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../bloc/password_reset/password_reset_cubit.dart';
import '../../bloc/password_reset/password_reset_state.dart';
import '../../widgets/auth_failure_text.dart';

/// Asking for a password reset, and being told it is on its way.
///
/// One screen, because the reset itself happens on the page Firebase emails a
/// link to (see `docs/DECISIONS.md` decision #32).
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordResetCubit, PasswordResetState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: AppSpacing.xl,
            toolbarHeight: 72,
            title: Text(
              // The title follows what happened: the request is behind them.
              state.wasSent
                  ? AppLocalizations.of(context).resetRequested
                  : AppLocalizations.of(context).resetPassword,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 30,
                  ),
            ),
          ),
          body: state.wasSent
              ? const _ResetRequested()
              : _RequestForm(
                  controller: _emailController,
                  state: state,
                ),
        );
      },
    );
  }
}

class _RequestForm extends StatelessWidget {
  final TextEditingController controller;
  final PasswordResetState state;

  const _RequestForm({required this.controller, required this.state});

  @override
  Widget build(BuildContext context) {
    return CenteredForm(
      children: [
        if (state.status == PasswordResetStatus.failure) ...[
          AlertBanner(AuthFailureText.messageFor(
              AppLocalizations.of(context), state.error)),
          const SizedBox(height: AppSpacing.xl),
        ],
        Text(
          AppLocalizations.of(context).resetInstructions,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).email,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: state.isSending
              ? null
              : () => context
                  .read<PasswordResetCubit>()
                  .requestReset(controller.text),
          child: state.isSending
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(AppLocalizations.of(context).sendResetLink),
        ),
      ],
    );
  }
}

class _ResetRequested extends StatelessWidget {
  const _ResetRequested();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mail_outline,
                size: 44,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            // Says nothing about whether that address has an account: the use
            // case promises the app cannot be used to find out who is
            // registered, and the wording is where that promise is kept.
            Text(
              AppLocalizations.of(context).resetSentMessage,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context).resetSpamHint,
              style: theme.textTheme.labelSmall?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).backToSignIn),
            ),
          ],
        ),
      ),
    );
  }
}
