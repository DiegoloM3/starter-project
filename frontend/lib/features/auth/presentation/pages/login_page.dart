import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

import '../../../../config/theme/app_themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            curr is AuthFailure || curr is AuthAuthenticated,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.error?.message ?? 'Sign in failed'),
              ),
            );
          }
        },
        child: Column(
          children: [
            // ── Masthead (dark header) ──
            _buildMasthead(),
            // ── Form Card ──
            Expanded(child: _buildFormCard(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMasthead() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 30,
        bottom: 32,
        left: 28,
        right: 28,
      ),
      decoration: const BoxDecoration(color: AppColors.ink),
      child: Column(
        children: [
          // Logo mark
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4AB91C1C),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'S',
              style: AppTypography.serif(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Wordmark
          Text(
            'Simmetry',
            style: AppTypography.serif(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          // Decorative rule
          SizedBox(
            width: 160,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                Container(
                  width: 20,
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          // Tagline
          Text(
            'YOUR DAILY BRIEFING',
            style: AppTypography.sans(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.36),
              letterSpacing: 3.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
              Text(
                'Welcome back',
                style: AppTypography.serif(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.t1,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to continue reading',
                style: AppTypography.sans(
                  fontSize: 13.5,
                  color: AppColors.t2,
                ),
              ),
              const SizedBox(height: 24),
              // Email field
              _buildFieldLabel('EMAIL'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: AppTypography.sans(fontSize: 15, color: AppColors.t1),
                decoration: _fieldDecoration(
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex =
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Password field
              _buildFieldLabel('PASSWORD'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTypography.sans(fontSize: 15, color: AppColors.t1),
                decoration: _fieldDecoration(
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.t2,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              // Sign In button
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, curr) =>
                    curr is AuthLoading ||
                    curr is AuthFailure ||
                    curr is AuthUnauthenticated ||
                    curr is AuthAuthenticated,
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return _PrimaryButton(
                    label: 'Sign In',
                    loadingLabel: 'Signing in…',
                    isLoading: isLoading,
                    onPressed: _onSignIn,
                  );
                },
              ),
              const SizedBox(height: 32),
              // Register link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.sans(
                        fontSize: 13.5,
                        color: AppColors.t2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(
                          context, '/Register'),
                      child: Text(
                        'Register',
                        style: AppTypography.sans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTypography.sans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.t2,
        letterSpacing: 1.8,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.sans(fontSize: 15, color: AppColors.t3),
      prefixIcon: Icon(prefixIcon, color: AppColors.t2, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: AppTypography.sans(
        fontSize: 11,
        color: AppColors.error,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _onSignIn() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthSignInRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
  }
}

/// Full-width vermilion CTA button matching the design.
class _PrimaryButton extends StatelessWidget {
  final String label;
  final String loadingLabel;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.loadingLabel,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? const Color(0xFF991818)
              : AppColors.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF991818),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.88),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: isLoading ? 0 : 4,
          shadowColor: AppColors.red.withValues(alpha: 0.21),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loadingLabel,
                    style: AppTypography.sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: AppTypography.sans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
