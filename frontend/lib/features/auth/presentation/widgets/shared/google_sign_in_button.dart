import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/google_mark.dart';

/// "Continue with Google": the outlined block with the brand mark.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GoogleMark(size: AppSizes.buttonIcon),
          SizedBox(width: AppSpacing.md),
          Text('Continue with Google'),
        ],
      ),
    );
  }
}
