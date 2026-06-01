import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppDecorations {
  AppDecorations._();

  // ── Cards ────────────────────────────────────────────────────
  static const BoxDecoration articleCard = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusXl)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.border, width: 0.5),
    ),
  );

  static const BoxDecoration surfaceCard = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusXl)),
  );

  static const BoxDecoration whiteCard = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusXl)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.border, width: 0.5),
    ),
  );

  // ── Inputs ───────────────────────────────────────────────────
  static const BoxDecoration input = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.border, width: 1),
    ),
  );

  static const BoxDecoration inputFocused = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );

  // ── Quote block ──────────────────────────────────────────────
  static const BoxDecoration quoteBlock = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.border, width: 1),
    ),
  );

  // ── TabBar ───────────────────────────────────────────────────
  static const BoxDecoration tabBar = BoxDecoration(
    color: AppColors.dark,
    borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusFull)),
  );

  // ── Imagen de cover ──────────────────────────────────────────
  static BoxDecoration coverImagePlaceholder = BoxDecoration(
    color: AppColors.surface,
    borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
    border: Border.all(
      color: AppColors.border,
      width: 1,
      style: BorderStyle.solid,
    ),
  );
}
