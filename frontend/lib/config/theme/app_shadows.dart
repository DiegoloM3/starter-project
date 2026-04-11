import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> ctaGreen = [
    BoxShadow(
        offset: Offset(0, AppDimensions.shadowOffsetY4),
        blurRadius: AppDimensions.shadowBlurLg,
        color: AppColors.shadowGreenLight),
    BoxShadow(
        offset: Offset(0, AppDimensions.shadowOffsetY6),
        blurRadius: AppDimensions.shadowBlurXl,
        color: AppColors.shadowGreenStrong),
  ];

  static const List<BoxShadow> cardStandard = [
    BoxShadow(
        offset: Offset(0, AppDimensions.shadowOffsetY2),
        blurRadius: AppDimensions.shadowBlurMd,
        color: AppColors.shadowDarkMedium),
  ];

  static const List<BoxShadow> cardSubtle = [
    BoxShadow(
        offset: Offset(0, AppDimensions.shadowOffsetY1),
        blurRadius: AppDimensions.shadowBlurSm,
        color: AppColors.shadowDarkSubtle),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
        offset: Offset(0, AppDimensions.shadowOffsetY1),
        blurRadius: AppDimensions.shadowBlurSm,
        color: AppColors.shadowDarkLight),
  ];
}
