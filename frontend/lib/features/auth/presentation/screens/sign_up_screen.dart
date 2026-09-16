import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_up/sign_up_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_error_banner.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_footer_link.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_form_header.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/google_sign_in_button.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/or_divider.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/password_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/sign_up/password_strength_meter.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

/// Create-account form. A successful sign-up signs the user in; the router
/// then lands on Home without an email verification step.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignUpCubit>(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: BlocBuilder<SignUpCubit, SignUpState>(
            builder: (context, state) {
              return AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LabeledIconButton.back(onPressed: context.goToWelcome),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: AuthFormHeader(
                        title: 'Create your account',
                        subtitle: 'Your name appears on articles you publish.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    LabeledTextField(
                      label: 'Display name',
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      errorText: state.displayNameError?.message,
                      onChanged: cubit.displayNameChanged,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    LabeledTextField(
                      label: 'Email',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      errorText: state.emailError?.message,
                      onChanged: cubit.emailChanged,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PasswordField(
                      obscureText: state.obscurePassword,
                      errorText: state.passwordError?.message,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: cubit.passwordChanged,
                      onToggleVisibility: cubit.togglePasswordVisibility,
                      onSubmitted: (_) => cubit.submit(),
                    ),
                    if (state.passwordStrength case final strength?) ...[
                      const SizedBox(height: AppSpacing.md),
                      PasswordStrengthMeter(strength: strength),
                    ],
                    if (state.failure case final failure?) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AuthErrorBanner(message: FailureMessageFormatter.of(failure)),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: state.isSubmitting ? 'Creating account…' : 'Create account',
                      isLoading: state.isSubmitting,
                      onPressed: cubit.submit,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const OrDivider(),
                    const SizedBox(height: AppSpacing.xl),
                    GoogleSignInButton(
                      onPressed: state.isSubmitting ? null : cubit.signInWithGoogle,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AuthFooterLink(
                      prompt: 'Already have an account?',
                      action: 'Sign in',
                      onPressed: context.goToSignIn,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
