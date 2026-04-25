import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/widgets/app_button.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text_field.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/auth_layout.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AuthBody();
}

class _AuthBody extends StatefulWidget {
  const _AuthBody();

  @override
  State<_AuthBody> createState() => _AuthBodyState();
}

class _AuthBodyState extends State<_AuthBody> {
  int _tabIndex = 0;

  // Sign In
  final _signInEmailCtrl = TextEditingController();
  final _signInPasswordCtrl = TextEditingController();
  bool _signInPasswordVisible = false;

  // Sign Up
  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPasswordCtrl = TextEditingController();
  bool _signUpPasswordVisible = false;

  @override
  void dispose() {
    _signInEmailCtrl.dispose();
    _signInPasswordCtrl.dispose();
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPasswordCtrl.dispose();
    super.dispose();
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/');
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    } else if (state is AuthPasswordResetSent) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Check your inbox.'),
          ),
        );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTabToggle(),
                SizedBox(height: AppSpacing.lg),
                if (_tabIndex == 0)
                  _buildSignInForm(context, isLoading)
                else
                  _buildSignUpForm(context, isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Tab toggle ───────────────────────────────────────────────────────────

  Widget _buildTabToggle() {
    return Container(
      height: AppMetrics.h(48),
      padding: EdgeInsets.all(AppMetrics.r(4)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppMetrics.r(12)),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Sign In'),
          _buildTab(1, 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        borderRadius: BorderRadius.circular(AppMetrics.r(8)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(AppMetrics.r(8)),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: AppMetrics.r(8),
                      offset: Offset(0, AppMetrics.h(2)),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign In form ─────────────────────────────────────────────────────────

  Widget _buildSignInForm(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _signInEmailCtrl,
          label: 'Email Address',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _signInPasswordCtrl,
          label: 'Password',
          hint: '••••••••',
          obscureText: !_signInPasswordVisible,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              _signInPasswordVisible
                  ? Ionicons.eye_off_outline
                  : Ionicons.eye_outline,
              color: AppColors.textSecondary,
              size: AppMetrics.r(20),
            ),
            onPressed: () => setState(
                () => _signInPasswordVisible = !_signInPasswordVisible),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('/forgot-password'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot password?',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.accent),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Sign In',
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () => context.read<AuthCubit>().signIn(
                    email: _signInEmailCtrl.text.trim(),
                    password: _signInPasswordCtrl.text,
                  ),
        ),
        SizedBox(height: AppSpacing.lg),
        _buildDivider(),
        SizedBox(height: AppSpacing.lg),
        _buildGoogleButton(context, isLoading),
        SizedBox(height: AppSpacing.lg),
        _buildBottomLink(
          question: "Don't have an account?",
          actionLabel: 'Sign up',
          onTap: () => setState(() => _tabIndex = 1),
        ),
      ],
    );
  }

  // ── Sign Up form ─────────────────────────────────────────────────────────

  Widget _buildSignUpForm(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _signUpNameCtrl,
          label: 'Full Name',
          hint: 'John Doe',
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _signUpEmailCtrl,
          label: 'Email Address',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _signUpPasswordCtrl,
          label: 'Password',
          hint: '••••••••',
          obscureText: !_signUpPasswordVisible,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              _signUpPasswordVisible
                  ? Ionicons.eye_off_outline
                  : Ionicons.eye_outline,
              color: AppColors.textSecondary,
              size: AppMetrics.r(20),
            ),
            onPressed: () => setState(
                () => _signUpPasswordVisible = !_signUpPasswordVisible),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Create Account',
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () => context.read<AuthCubit>().signUp(
                    email: _signUpEmailCtrl.text.trim(),
                    password: _signUpPasswordCtrl.text,
                    displayName: _signUpNameCtrl.text.trim(),
                  ),
        ),
        SizedBox(height: AppSpacing.lg),
        _buildDivider(),
        SizedBox(height: AppSpacing.lg),
        _buildGoogleButton(context, isLoading),
        SizedBox(height: AppSpacing.lg),
        _buildBottomLink(
          question: 'Already have an account?',
          actionLabel: 'Sign in',
          onTap: () => setState(() => _tabIndex = 0),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'By continuing you agree to our Terms of Service',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Shared helpers ───────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('or', style: AppTypography.bodySmall),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context, bool isLoading) {
    return SizedBox(
      height: AppMetrics.h(52),
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () => context.read<AuthCubit>().signInWithGoogle(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppMetrics.r(12)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.logo_google,
              size: AppMetrics.r(20),
              color: AppColors.textPrimary,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Continue with Google',
              style: AppTypography.labelLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLink({
    required String question,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, style: AppTypography.bodyMedium),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
