import 'package:flutter/material.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Marks the articles written by the journalists of the app, so readers can
/// tell them apart from the articles of the news API.
class JournalistBadge extends StatelessWidget {
  const JournalistBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(color: AppColors.lilac, borderRadius: AppRadius.standard),
      child: const Text(
        'Journalist',
        style: TextStyle(
          fontFamily: AppFonts.inter,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}
