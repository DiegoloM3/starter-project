import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// The kicker above a headline: the category in small capitals, deep red.
class CategoryLabel extends StatelessWidget {
  final NewsCategory category;
  final Color? color;

  const CategoryLabel({super.key, required this.category, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      category.label.toUpperCase(),
      style: AppTypography.overline.copyWith(color: color ?? context.palette.primaryDeep),
    );
  }
}
