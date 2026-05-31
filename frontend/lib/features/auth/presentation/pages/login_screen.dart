import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/routes/article_routes.dart';

import '../../../../../core/design_system/extensions/build_context_extensions.dart';
import '../../../../../core/design_system/theme/app_colors.dart';
import '../../routes/auth_routes.dart';
import '../widgets/google_button.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = useTextEditingController();
    final emailFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final passwordCtrl = useTextEditingController();
    final obscurePassword = useState(true);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    void onSignIn() {
      if (!(formKey.currentState?.validate() ?? false)) return;

      final email = emailCtrl.text.trim();
      final password = passwordCtrl.text;

      context.read<AuthBloc>().add(
        SignInWithEmailRequested(email: email, password: password),
      );
    }

    void onGoogleSignIn() {
      context.read<AuthBloc>().add(const SignInWithGoogleRequested());
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthAuthenticated():
            final from = GoRouterState.of(context).uri.queryParameters['from'];
            if (from != null && from.isNotEmpty) {
              context.go(from);
            } else {
              context.goToFeed();
            }
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Symmetry ',
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: 'NEWS',
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 40),
                        child: Text(
                          'The editorial standard, simplified.',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    _FieldLabel('EMAIL'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: emailCtrl,
                      focusNode: emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
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
                    Row(
                      children: [
                        _FieldLabel('PASSWORD'),
                        const Spacer(),
                        TextButton(
                          onPressed: isLoading ? null : () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: obscurePassword.value,
                      focusNode: passwordFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSignIn(),
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: '•' * 8,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: isLoading
                              ? null
                              : () => obscurePassword.value =
                                    !obscurePassword.value,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.authEnterPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : onSignIn,
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.colorScheme.onPrimary,
                                ),
                              )
                            : Text(context.l10n.authSignIn),
                      ),
                    ),
                    const SizedBox(height: 28),
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
                    GoogleButton(onPressed: isLoading ? null : onGoogleSignIn),
                    const SizedBox(height: 32),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.workSans(
                            fontSize: 13,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: isLoading
                                    ? null
                                    : () => context.goToRegister(),
                                child: Text(
                                  'Sign up',
                                  style: context.textTheme.bodyMedium?.copyWith(
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
