import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';

/// Small-capitals section head over a 2px rule, then its rows divided by
/// soft rules. No card: the rules do the grouping.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.md, AppSpacing.screenMargin, AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.sectionOverline.copyWith(color: palette.inkSecondary),
          ),
        ),
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) Divider(color: palette.outline),
          children[index],
        ],
      ],
    );
  }
}
