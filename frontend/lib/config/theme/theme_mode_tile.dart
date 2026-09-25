import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

import 'theme_cubit.dart';

/// The profile's theme row: Light / Dark, replacing the old on/off
/// dark-mode switch with the same segmented-button pattern used elsewhere
/// in the app (Write/Preview, Sign in/Create account). MaterialApp animates
/// theme/color changes on its own (its default themeAnimationDuration), so
/// switching segments here already fades between the two looks instead of
/// snapping.
class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => ListTile(
        title: Text(context.l10n.theme),
        trailing: SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.wb_sunny_outlined),
              tooltip: context.l10n.themeLight,
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode_outlined),
              tooltip: context.l10n.themeDark,
            ),
          ],
          selected: {mode},
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onSelectionChanged: (selection) =>
              context.read<ThemeCubit>().setMode(selection.first),
        ),
      ),
    );
  }
}
