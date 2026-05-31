import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/core/design_system/extensions/build_context_extensions.dart';
import 'package:news_app_clean_architecture/core/design_system/theme/app_colors.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/routes/auth_routes.dart';

/// Welcome / onboarding screen shown to unauthenticated users.
///
/// Acts as the app entry point for unauthenticated users.
/// Provides CTAs to sign in or continue as guest.
class WelcomeScreen extends HookWidget {
  const WelcomeScreen({super.key, required this.onGuestPressed});

  final VoidCallback onGuestPressed;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final authBloc = context.read<AuthBloc>();
        if (authBloc.state is AuthSignedOut) {
          authBloc.add(const SignOutRedirectAcknowledged());
        }
      });
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Editorial grid texture ────────────────────────────────────────
          const Positioned.fill(child: _EditorialTexture()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Brand header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 98.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Symmetry ',
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'NEWS',
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Flexible spacer fills the grid-texture area ───────────────
                const Spacer(),
                // ── Headline + description + buttons ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 107),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Stay informed.\nRead what matters.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: context.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Experience journalism designed for clarity. '
                          'Access highly curated stories, in-depth analysis, '
                          'and breaking news from trusted global sources without the noise.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 67),

                      // ── SIGN IN ─────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.goToLogin(),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(),
                            textStyle: context.textTheme.titleSmall?.copyWith(
                              letterSpacing: 1.2,
                            ),
                          ),
                          child: const Text('SIGN IN'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ── CONTINUE AS GUEST ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onGuestPressed,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: context.colorScheme.onSurface,
                            ),
                            shape: const RoundedRectangleBorder(),
                            textStyle: context.textTheme.titleSmall?.copyWith(
                              letterSpacing: 1.2,
                            ),
                          ),
                          child: const Text('CONTINUE AS GUEST'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the subtle editorial grid texture (faint lines every 48 px).
/// Matches the CSS repeating-linear-gradient used in the design reference.
class _EditorialTexture extends StatelessWidget {
  const _EditorialTexture();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  static final _verticalPaint = Paint()
    ..color =
        const Color(0x0A926E69) // outline @ 4% opacity
    ..strokeWidth = 1;

  static final _horizontalPaint = Paint()
    ..color =
        const Color(0x05926E69) // outline @ 2% opacity
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _verticalPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _horizontalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
