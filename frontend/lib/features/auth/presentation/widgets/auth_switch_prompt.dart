import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

/// A question followed by a link to the other form, e.g. "Don't have an account? Sign up".
class AuthSwitchPrompt extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onPressed;

  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Wraps to a second line instead of overflowing with large text sizes.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(question, style: TextStyle(fontSize: 14, color: palette.textSecondary)),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: palette.primary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(48, 48),
            textStyle: const TextStyle(fontFamily: 'Muli', fontSize: 14, fontWeight: FontWeight.w800),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}
