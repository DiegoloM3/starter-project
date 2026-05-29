import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

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
                content: Text(
                  state.error?.message ??
                      AppLocalizations.of(context)!.signInFailed,
                ),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 30,
        bottom: AppSpacing.xl3,
        left: 28,
        right: 28,
      ),
      decoration: BoxDecoration(color: cs.onSurface),
      child: Column(
        children: [
          // Logo mark
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary,
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
              style: tt.headlineMedium?.copyWith(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Wordmark
          Text(
            'Simmetry',
            style: tt.displayMedium?.copyWith(
              color: Colors.white,
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
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
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
            style: tt.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.36),
              fontWeight: FontWeight.w700,
              letterSpacing: 3.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl2,
          28,
          AppSpacing.xl2,
          0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
              Text(
                l10n.welcomeBack,
                style: tt.headlineMedium?.copyWith(
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.signInSubtitle,
                style: tt.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              // Email field
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
              // Password field
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
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
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
                    label: l10n.signIn,
                    loadingLabel: l10n.signingIn,
                    isLoading: isLoading,
                    onPressed: _onSignIn,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl3),
              // Register link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l10n.dontHaveAccount} ',
                      style: tt.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/Register'),
                      child: Text(
                        l10n.register,
                        style: tt.labelLarge?.copyWith(
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
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w700,
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
        color: cs.outlineVariant,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(prefixIcon, color: cs.onSurfaceVariant, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
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
        color: cs.error,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? const Color(0xFF991818)
              : cs.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF991818),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.88),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: isLoading ? 0 : 4,
          shadowColor: cs.primary.withValues(alpha: 0.21),
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
                    style: tt.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: tt.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
