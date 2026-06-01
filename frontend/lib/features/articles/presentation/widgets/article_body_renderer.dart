import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_typography.dart';

class ArticleBodyRenderer extends StatelessWidget {
  final String body;

  const ArticleBodyRenderer({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Text(
      body,
      style: AppTypography.body.copyWith(
        color: AppColors.textPrimary,
        height: 1.6,
      ),
    );
  }
}
