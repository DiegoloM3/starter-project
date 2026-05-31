import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app_clean_architecture/core/design_system/design_system.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/routes/article_routes.dart';

import '../../routes/auth_routes.dart';
import '../widgets/google_button.dart';

/// Register screen UI only, no Firebase Auth.
class RegisterScreen extends HookWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = useTextEditingController();
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final confirmPasswordCtrl = useTextEditingController();
    final nameFocus = useFocusNode();
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final confirmFocus = useFocusNode();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    void onCreateAccount() {
      if (!(formKey.currentState?.validate() ?? false)) return;

      context.read<AuthBloc>().add(
        SignUpWithEmailRequested(
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text,
          displayName: nameCtrl.text.trim(),
        ),
      );
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthAuthenticated():
            context.goToFeed();
          case AuthError(:final failure):
            context.showSnackBar(failure.message, isError: true);
          default:
            break;
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    Text(
                      'Symmetry NEWS',
                      style: context.textTheme.headlineMedium,
                    ),
                    Text(
                      'Create an account',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Divider(),
                    const SizedBox(height: 24),
                    // FULL NAME
                    _FieldLabel('FULL NAME'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameCtrl,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      focusNode: nameFocus,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Jane Doe',
                      ),
                      onFieldSubmitted: (value) => emailFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.authEnterDisplayName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // EMAIL
                    _FieldLabel('EMAIL ADDRESS'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailCtrl,
                      focusNode: emailFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) => passwordFocus.requestFocus(),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.authEnterEmail;
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return context.l10n.authInvalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // PASSWORD
                    _FieldLabel('PASSWORD'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      focusNode: passwordFocus,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) => confirmFocus.requestFocus(),
                      decoration: InputDecoration(hintText: '•' * 8),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.authEnterPassword;
                        }
                        if (value.length < 8) {
                          return context.l10n.authWeakPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // CONFIRM PASSWORD
                    _FieldLabel('CONFIRM PASSWORD'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: confirmPasswordCtrl,
                      obscureText: true,
                      focusNode: confirmFocus,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(hintText: '•' * 8),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.authEnterPassword;
                        }
                        if (value != passwordCtrl.text) {
                          return context.l10n.authPasswordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // CREATE ACCOUNT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : onCreateAccount,
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.colorScheme.onPrimary,
                                ),
                              )
                            : const Text('CREATE ACCOUNT'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or continue with',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GoogleButton(
                      onPressed: () {
                        // Handle Google sign-in
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => context.goToLogin(),
                                child: Text(
                                  'Sign in',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.workSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: context.colorScheme.onSurface,
      ),
    );
  }
}
