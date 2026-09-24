import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/app_brand.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/centered_form.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../bloc/session/session_cubit.dart';
import '../../bloc/session/session_state.dart';
import '../../widgets/auth_failure_text.dart';

/// Skeleton of the sign in screen, plain Material widgets wired to
/// [SessionCubit] (same intent as decision #14: the Figma design comes later).
///
/// Reaching this screen is never mandatory to read the app; it is shown when
/// somebody asks for their account, or tries to do something that needs one.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The session is app wide, so a failure from the screen before this one
    // would otherwise be sitting here, describing something that happened
    // somewhere else.
    context.read<SessionCubit>().clearFailure();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No title: the screen introduces itself below, and an app bar
      // repeating "Sign in" over a button that says "Sign in" is furniture.
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
                  Navigator.pushReplacementNamed(context, '/SignUp'),
              child: Text(AppLocalizations.of(context).newHereCreateAccount),
            ),
            children: [
              AppBrandHeader(
                subtitle: AppLocalizations.of(context).signInSubtitle,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              // Above the fields, not under the button: the message is about
              // what was typed, and a reader should not have to scroll past
              // the thing they just pressed to find out what went wrong.
              if (state.status == SessionStatus.failure) ...[
                AlertBanner(AuthFailureText.messageFor(
                    AppLocalizations.of(context), state.error)),
                const SizedBox(height: AppSpacing.xl),
              ],
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
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: state.isBusy ? null : () => _signIn(context),
                child: state.isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppLocalizations.of(context).signIn),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/PasswordReset'),
                child: Text(AppLocalizations.of(context).forgotPassword),
              ),
            ],
          );
        },
      ),
    );
  }

  void _signIn(BuildContext context) {
    context.read<SessionCubit>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}
