import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';

/// Page frame shared by the picker screens: labelled Back, the title in
/// capitals and the list underneath.
class OptionPickerScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const OptionPickerScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: LabeledIconButton.back(onPressed: () => Navigator.of(context).pop()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.sm, AppSpacing.screenMargin, AppSpacing.lg),
              child: Text(title.toUpperCase(), style: AppTypography.tabTitle.copyWith(color: palette.ink)),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
