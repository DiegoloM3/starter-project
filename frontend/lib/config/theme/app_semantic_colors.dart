import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colors that have no slot in Material 3's [ColorScheme]:
/// success / warning / info (+ their on/container variants) and the
/// draft / published / archived status-badge palettes.
///
/// Registered on [ThemeData.extensions]. Read it with `context.semantic`.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.draftBg,
    required this.draftFg,
    required this.draftBorder,
    required this.publishedBg,
    required this.publishedFg,
    required this.publishedBorder,
    required this.archivedBg,
    required this.archivedFg,
    required this.archivedBorder,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color draftBg;
  final Color draftFg;
  final Color draftBorder;

  final Color publishedBg;
  final Color publishedFg;
  final Color publishedBorder;

  final Color archivedBg;
  final Color archivedFg;
  final Color archivedBorder;

  /// The light-mode instance wired into [ThemeData.extensions].
  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.success,
    onSuccess: AppColors.onSuccess,
    successContainer: AppColors.successContainer,
    onSuccessContainer: AppColors.onSuccessContainer,
    warning: AppColors.warning,
    onWarning: AppColors.onWarning,
    warningContainer: AppColors.warningContainer,
    onWarningContainer: AppColors.onWarningContainer,
    info: AppColors.info,
    onInfo: AppColors.onInfo,
    infoContainer: AppColors.infoContainer,
    onInfoContainer: AppColors.onInfoContainer,
    draftBg: AppColors.draftBg,
    draftFg: AppColors.draftFg,
    draftBorder: AppColors.draftBorder,
    publishedBg: AppColors.publishedBg,
    publishedFg: AppColors.publishedFg,
    publishedBorder: AppColors.publishedBorder,
    archivedBg: AppColors.archivedBg,
    archivedFg: AppColors.archivedFg,
    archivedBorder: AppColors.archivedBorder,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? draftBg,
    Color? draftFg,
    Color? draftBorder,
    Color? publishedBg,
    Color? publishedFg,
    Color? publishedBorder,
    Color? archivedBg,
    Color? archivedFg,
    Color? archivedBorder,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      draftBg: draftBg ?? this.draftBg,
      draftFg: draftFg ?? this.draftFg,
      draftBorder: draftBorder ?? this.draftBorder,
      publishedBg: publishedBg ?? this.publishedBg,
      publishedFg: publishedFg ?? this.publishedFg,
      publishedBorder: publishedBorder ?? this.publishedBorder,
      archivedBg: archivedBg ?? this.archivedBg,
      archivedFg: archivedFg ?? this.archivedFg,
      archivedBorder: archivedBorder ?? this.archivedBorder,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      draftBg: Color.lerp(draftBg, other.draftBg, t)!,
      draftFg: Color.lerp(draftFg, other.draftFg, t)!,
      draftBorder: Color.lerp(draftBorder, other.draftBorder, t)!,
      publishedBg: Color.lerp(publishedBg, other.publishedBg, t)!,
      publishedFg: Color.lerp(publishedFg, other.publishedFg, t)!,
      publishedBorder: Color.lerp(publishedBorder, other.publishedBorder, t)!,
      archivedBg: Color.lerp(archivedBg, other.archivedBg, t)!,
      archivedFg: Color.lerp(archivedFg, other.archivedFg, t)!,
      archivedBorder: Color.lerp(archivedBorder, other.archivedBorder, t)!,
    );
  }
}

/// Convenience accessor: `context.semantic.success`, `context.semantic.draftBg`…
///
/// Falls back to [AppSemanticColors.light] if the extension is not registered
/// (e.g. a widget test that pumps a bare MaterialApp), so it never throws.
extension SemanticColorsX on BuildContext {
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
}
