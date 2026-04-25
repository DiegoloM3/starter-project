import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:news_app_clean_architecture/core/models/home_category.dart';
import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text.dart';
import 'package:news_app_clean_architecture/core/widgets/category_chip.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({
    super.key,
    required this.body,
    required this.categories,
    required this.onSearchTap,
    required this.onBookmarkTap,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.showFAB = false,
    this.onFABTap,
  });

  final Widget body;
  final List<HomeCategory> categories;
  final VoidCallback onSearchTap;
  final VoidCallback onBookmarkTap;
  final String selectedCategory;
  final void Function(String) onCategoryChanged;
  final bool showFAB;
  final VoidCallback? onFABTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'The',
              variant: AppTextVariant.labelSmall,
              color: AppColors.textSecondary,
            ),
            AppText(
              'Pulse',
              variant: AppTextVariant.displayMedium,
              color: AppColors.textPrimary,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined,
                color: AppColors.textSecondary, size: 24.r),
            onPressed: onSearchTap,
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border,
                color: AppColors.textSecondary, size: 24.r),
            onPressed: onBookmarkTap,
          ),
          SizedBox(width: AppMetrics.w(8)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: AppMetrics.h(80),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.symmetric(horizontal: AppMetrics.w(16)),
              itemCount: categories.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSpacing.xs),
              itemBuilder: (_, index) {
                final c = categories[index];
                return CategoryChip(
                  category: c.label,
                  icon: c.icon,
                  isActive: selectedCategory == c.slug,
                  onTap: () => onCategoryChanged(c.slug),
                );
              },
            ),
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: showFAB && onFABTap != null
          ? SizedBox(
              width: 56.r,
              height: 56.r,
              child: FloatingActionButton(
                onPressed: onFABTap,
                backgroundColor: AppColors.accent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
