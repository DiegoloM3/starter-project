import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_validators.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

/// Sign-up page — allows creating an account with email, password, and display name.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount(BuildContext context) {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (AuthValidators.validateDisplayName(displayName) != null ||
        AuthValidators.validateEmail(email) != null ||
        AuthValidators.validatePassword(password) != null) {
      setState(() {}); // trigger rebuild to show inline errors
      return;
    }

    final params = SignUpParams(
      email: email,
      password: password,
      displayName: displayName,
    );

    final bloc = context.read<AuthBloc>();
    if (bloc.state is AuthAnonymous) {
      bloc.add(LinkAnonymousWithEmailEvent(params));
    } else {
      bloc.add(SignUpWithEmailEvent(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.authSignUpTitle)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.localizedMessage)),
            );
            context.read<AuthBloc>().add(ErrorDismissedEvent());
          } else if (state is AuthAuthenticated) {
            final returnTo =
                GoRouterState.of(context).uri.queryParameters['return'];
            if (returnTo != null && returnTo.isNotEmpty) {
              context.go(Uri.decodeComponent(returnTo));
            } else {
              context.go('/');
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthAuthenticating;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  key: const Key('signup_displayname_field'),
                  label: t.authDisplayNameLabel,
                  controller: _displayNameController,
                  readOnly: isLoading,
                  errorText:
                      _displayNameController.text.isNotEmpty
                          ? AuthValidators.validateDisplayName(
                              _displayNameController.text)
                          : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  key: const Key('signup_email_field'),
                  label: t.authEmailLabel,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: isLoading,
                  errorText:
                      _emailController.text.isNotEmpty
                          ? AuthValidators.validateEmail(_emailController.text)
                          : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  key: const Key('signup_password_field'),
                  label: t.authPasswordLabel,
                  controller: _passwordController,
                  obscureText: true,
                  readOnly: isLoading,
                  errorText:
                      _passwordController.text.isNotEmpty
                          ? AuthValidators.validatePassword(
                              _passwordController.text)
                          : null,
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: () => _onCreateAccount(context),
                    child: Text(t.authSignUpAction),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.authHaveAccount),
                    TextButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      child: Text(t.authSignInAction),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
