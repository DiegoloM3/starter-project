import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

/// Button that triggers Google Sign-In flow.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;

  const GoogleSignInButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.grey),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.g_mobiledata, size: 24),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).authGoogleSignIn),
        ],
      ),
    );
  }
}
