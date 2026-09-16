import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/sign_in/sign_in_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_error_banner.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_footer_link.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/auth_form_header.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/google_sign_in_button.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/or_divider.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/shared/password_field.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

/// Email + password sign-in, with Google as the alternative. On success the
/// session changes and the router moves to Home by itself.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignInCubit>(),
      child: const SignInView(),
    );
  }
}

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignInCubit>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: BlocBuilder<SignInCubit, SignInState>(
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
                        title: 'Welcome back',
                        subtitle: 'Sign in to continue reading.',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
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
                      errorText: _passwordErrorText(state),
                      autofillHints: const [AutofillHints.password],
                      onChanged: cubit.passwordChanged,
                      onToggleVisibility: cubit.togglePasswordVisibility,
                      onSubmitted: (_) => cubit.submit(),
                    ),
                    if (_bannerFailure(state) case final failure?) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AuthErrorBanner(message: FailureMessageFormatter.of(failure)),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: state.isSubmitting ? 'Signing in…' : 'Sign in',
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
                      prompt: 'New here?',
                      action: 'Create an account',
                      onPressed: context.goToSignUp,
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

  /// A rejected password reads as a field error, right where it was typed.
  static String? _passwordErrorText(SignInState state) {
    final fieldError = state.passwordError;
    if (fieldError != null) return fieldError.message;

    final failure = state.failure;
    if (failure?.type == FailureType.invalidCredentials) {
      return FailureMessageFormatter.of(failure!);
    }
    return null;
  }

  /// Every other failure is about the attempt as a whole.
  static Failure? _bannerFailure(SignInState state) {
    final failure = state.failure;
    if (failure == null || failure.type == FailureType.invalidCredentials) {
      return null;
    }
    return failure;
  }
}
