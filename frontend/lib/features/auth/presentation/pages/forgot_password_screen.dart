import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/widgets/app_button.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthPasswordResetSent) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Reset link sent. Check your inbox.')),
        );
      Navigator.of(context).pop();
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _handleState,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return AuthLayout(
            showBackButton: true,
            showLogo: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      color: AppColors.accent,
                      size: 24.r,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Reset password',
                  style: AppTypography.headlineLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  "Enter your email and we'll send you a link to reset your password.",
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: isLoading
                      ? null
                      : (_) => context
                          .read<AuthCubit>()
                          .forgotPassword(email: _emailCtrl.text.trim()),
                ),
                SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Send reset link',
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () => context
                          .read<AuthCubit>()
                          .forgotPassword(email: _emailCtrl.text.trim()),
                ),
                SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: AppTypography.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Sign in',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
