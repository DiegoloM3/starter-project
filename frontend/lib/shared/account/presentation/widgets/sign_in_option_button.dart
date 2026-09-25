import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

enum SignInOption { google, email }

class SignInOptionButton extends StatelessWidget {
  final SignInOption option;
  final VoidCallback? onPressed;

  const SignInOptionButton({
    super.key,
    required this.option,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedOpacity(
      opacity: onPressed == null ? 0.5 : 1,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(_icon, size: 20),
          label: Text(_label(context.l10n)),
          style: _style(theme.colorScheme, theme.textTheme),
        ),
      ),
    );
  }

  IconData get _icon => switch (option) {
        SignInOption.google => Ionicons.logo_google,
        SignInOption.email => Ionicons.mail_outline,
      };

  String _label(AppLocalizations l10n) => switch (option) {
        SignInOption.google => l10n.continueWithGoogle,
        SignInOption.email => l10n.continueWithEmail,
      };

  ButtonStyle _style(ColorScheme colorScheme, TextTheme textTheme) {
    final (background, foreground, border) = switch (option) {
      SignInOption.google => (
          colorScheme.surfaceContainerLowest,
          colorScheme.onSurface,
          colorScheme.outlineVariant,
        ),
      SignInOption.email => _softAccentColors(colorScheme),
    };
    return OutlinedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: background,
      disabledForegroundColor: foreground,
      side: BorderSide(color: border),
      shape: const StadiumBorder(),
      textStyle: textTheme.titleMedium,
    );
  }

  // Same pairing as the "New article" card, DESIGN.md's soft secondary action.
  (Color, Color, Color) _softAccentColors(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.light) {
      return (
        AppColors.lightFabTint,
        colorScheme.primaryContainer,
        AppColors.lightFabTint,
      );
    }
    return (
      colorScheme.secondaryContainer,
      colorScheme.onSecondaryContainer,
      colorScheme.secondaryContainer,
    );
  }
}
