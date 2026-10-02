import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_buttons.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/app_toasts.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/credentials_rules.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/register/register_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/register/register_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/labeled_text_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/password_text_field.dart';
import 'package:news_app_clean_architecture/core/constants/route_names.dart';

/// Form where a journalist creates their account. Once it is created, the journalist is signed in,
/// the form closes and the app shows the news.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: _onStateChanged,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
            icon: const Icon(Ionicons.chevronBack),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          children: [
            const Text('Create your account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'Join as a journalist and start publishing.',
              style: TextStyle(fontSize: 14, height: 1.5, color: palette.textSecondary),
            ),
            const SizedBox(height: 22),
            _RegisterForm(state: state),
            const SizedBox(height: 22),
            AppPrimaryButton(
              label: 'Create account',
              isLoading: state is RegisterInProgress,
              onPressed: context.read<RegisterCubit>().register,
            ),
            const SizedBox(height: 12),
            AuthSwitchPrompt(
              question: 'Already have an account?',
              action: 'Log in',
              onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.signIn),
            ),
          ],
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, RegisterState state) {
    if (state is RegisterSuccess) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    if (state is RegisterFailure) {
      showAppToast(context, AppToast.error(authFailureMessage(state.error)));
    }
  }
}

class _RegisterForm extends StatelessWidget {
  final RegisterState state;

  const _RegisterForm({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final draft = state.draft;
    final isEditable = state is! RegisterInProgress;
    return AutofillGroup(
      child: AuthFormCard(
        fields: [
          LabeledTextField(
            label: 'Full name',
            hint: 'Jane Doe',
            helperText: 'Shown as the author of your articles.',
            keyboardType: TextInputType.name,
            autofillHints: const [AutofillHints.name],
            errorText: _visibleError(draft.nameError),
            enabled: isEditable,
            onChanged: cubit.updateName,
          ),
          LabeledTextField(
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            errorText: _visibleError(draft.emailError),
            enabled: isEditable,
            onChanged: cubit.updateEmail,
          ),
          PasswordTextField(
            label: 'Password',
            hint: 'Create a password',
            helperText: 'At least ${CredentialsRules.minPasswordLength} characters.',
            autofillHints: const [AutofillHints.newPassword],
            errorText: _visibleError(draft.passwordError),
            enabled: isEditable,
            onChanged: cubit.updatePassword,
          ),
          PasswordTextField(
            label: 'Confirm password',
            hint: 'Repeat your password',
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            errorText: _visibleError(draft.passwordConfirmationError),
            enabled: isEditable,
            onChanged: cubit.updatePasswordConfirmation,
            onSubmitted: (_) => cubit.register(),
          ),
        ],
      ),
    );
  }

  String? _visibleError(CredentialsError? error) {
    final showsErrors = state is RegisterEditing && (state as RegisterEditing).showsValidationErrors;
    return showsErrors ? error?.message : null;
  }
}
