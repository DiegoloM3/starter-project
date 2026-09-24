import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/app_brand.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/centered_form.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/credentials_rules.dart';

import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';
import '../../widgets/auth_failure_text.dart';

/// Skeleton of the account creation screen.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // See SignInScreen: a session failure belongs to the screen that caused
    // it, and this one starts clean.
    context.read<SessionCubit>().clearFailure();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // See SignInScreen: the brand below introduces the screen, so the bar
      // does not have to repeat the button underneath it.
      appBar: AppBar(),
      body: BlocConsumer<SessionCubit, SessionState>(
        listenWhen: (previous, current) =>
            previous.isSignedIn != current.isSignedIn,
        listener: (context, state) {
          if (state.isSignedIn) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return CenteredForm(
            footer: TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/SignIn'),
              child: Text(AppLocalizations.of(context).alreadyHaveAccount),
            ),
            children: [
              AppBrandHeader(
                subtitle: AppLocalizations.of(context).signUpSubtitle,
                compact: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (state.status == SessionStatus.failure) ...[
                AlertBanner(AuthFailureText.messageFor(
                    AppLocalizations.of(context), state.error)),
                const SizedBox(height: AppSpacing.xl),
              ],
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).displayNameOptional,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).email,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).password,
                  // Said before they type, not after they fail.
                  helperText: AppLocalizations.of(context)
                      .atLeastCharacters(CredentialsRules.passwordMinLength),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).repeatPassword,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: state.isBusy ? null : () => _signUp(context),
                child: state.isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppLocalizations.of(context).createAccount),
              ),
            ],
          );
        },
      ),
    );
  }

  void _signUp(BuildContext context) {
    context.read<SessionCubit>().signUp(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          displayName: _displayNameController.text,
        );
  }
}
