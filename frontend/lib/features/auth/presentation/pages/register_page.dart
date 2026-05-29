import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/primary_button.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../config/theme/app_themes.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

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
                content: Text(
                  state.error?.message ??
                      AppLocalizations.of(context)!.registrationFailed,
                ),
              ),
            );
          }
        },
        child: const Column(
          children: [
            _RegisterMasthead(),
            Expanded(child: _RegisterForm()),
          ],
        ),
      ),
    );
  }
}

/// Compact masthead with back button + S logo + wordmark.
class _RegisterMasthead extends StatelessWidget {
  const _RegisterMasthead();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        bottom: AppSpacing.lg,
        left: AppSpacing.md,
        right: AppSpacing.xl,
      ),
      color: cs.onSurface,
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // S mark + wordmark
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.center,
            child: Text(
              'S',
              style: tt.bodyLarge?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Text(
            l10n.appName,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl2, 26, AppSpacing.xl2, 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
              Text(
                l10n.createAccount,
                style: tt.headlineMedium?.copyWith(
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.registerSubtitle,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              // Full name
              _buildFieldLabel(l10n.fullNameLabel.toUpperCase()),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w400),
                decoration: _fieldDecoration(
                  hint: l10n.fullNameHint,
                  prefixIcon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameRequired;
                  }
                  if (value.trim().length > 50) {
                    return l10n.nameMaxLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Email
              _buildFieldLabel(l10n.emailLabel.toUpperCase()),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w400),
                decoration: _fieldDecoration(
                  hint: l10n.emailHint,
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.emailRequired;
                  }
                  final emailRegex =
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return l10n.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Password
              _buildFieldLabel(l10n.passwordLabel.toUpperCase()),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w400),
                decoration: _fieldDecoration(
                  hint: l10n.passwordHint,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.passwordRequired;
                  }
                  if (value.length < 6) {
                    return l10n.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Confirm Password
              _buildFieldLabel(l10n.confirmPasswordLabel.toUpperCase()),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w400),
                decoration: _fieldDecoration(
                  hint: l10n.confirmPasswordHint,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return l10n.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              // Create Account button
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, curr) =>
                    curr is AuthLoading ||
                    curr is AuthFailure ||
                    curr is AuthUnauthenticated ||
                    curr is AuthAuthenticated,
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return PrimaryButton(
                    label: l10n.createAccount,
                    loadingLabel: l10n.creatingAccount,
                    isLoading: isLoading,
                    onPressed: _onRegister,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl2),
              // Sign in link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l10n.alreadyHaveAccount} ',
                      style: tt.labelLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        l10n.signIn,
                        style: tt.labelLarge?.copyWith(
                          letterSpacing: 0,
                          color: cs.primary,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Text(
      label,
      style: tt.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: tt.titleMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: cs.outlineVariant,
      ),
      prefixIcon: Icon(prefixIcon, color: cs.onSurfaceVariant, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: cs.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: cs.outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      errorStyle: tt.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: cs.error,
      ),
    );
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthSignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _nameController.text.trim(),
          ),
        );
  }
}
