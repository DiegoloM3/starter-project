import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_buttons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/app_toasts.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/credentials_rules.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/labeled_text_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/password_text_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/daily_news_label.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// Form where a journalist logs in with their email and password.
/// Once signed in, it closes and the app shows the news.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInCubit, SignInState>(
      listener: _onStateChanged,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
            icon: const Icon(Ionicons.chevronBack),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SignInHeader(),
                const SizedBox(height: 28),
                _SignInForm(state: state),
                const SizedBox(height: 28),
                AppPrimaryButton(
                  label: 'Log in',
                  isLoading: state is SignInInProgress,
                  onPressed: context.read<SignInCubit>().signIn,
                ),
                const SizedBox(height: 16),
                AuthSwitchPrompt(
                  question: 'Don’t have an account?',
                  action: 'Sign up',
                  onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, SignInState state) {
    if (state is SignInSuccess) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    if (state is SignInFailure) {
      showAppToast(context, AppToast.error(authFailureMessage(state.error)));
    }
  }
}

class _SignInHeader extends StatelessWidget {
  const _SignInHeader();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: palette.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: palette.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Icon(Ionicons.newspaperOutline, size: 32, color: palette.onPrimary),
        ),
        const SizedBox(height: 14),
        const DailyNewsLabel(),
        const SizedBox(height: 14),
        const Text('Welcome back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        Text(
          'Log in to publish and save your articles.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.5, color: palette.textSecondary),
        ),
      ],
    );
  }
}

class _SignInForm extends StatelessWidget {
  final SignInState state;

  const _SignInForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignInCubit>();
    final params = state.params;
    final isEditable = state is! SignInInProgress;
    return AutofillGroup(
      child: AuthFormCard(
        fields: [
          LabeledTextField(
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            errorText: _visibleError(params.emailError),
            enabled: isEditable,
            onChanged: cubit.updateEmail,
          ),
          PasswordTextField(
            label: 'Password',
            hint: 'Your password',
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            errorText: _visibleError(params.passwordError),
            enabled: isEditable,
            onChanged: cubit.updatePassword,
            onSubmitted: (_) => cubit.signIn(),
          ),
        ],
      ),
    );
  }

  String? _visibleError(CredentialsError? error) {
    final showsErrors = state is SignInEditing && (state as SignInEditing).showsValidationErrors;
    return showsErrors ? error?.message : null;
  }
}
