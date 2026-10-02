import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/theme/theme_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/theme_option_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        shape: Border(bottom: BorderSide(color: palette.divider)),
      ),
      body: BlocBuilder<ThemeCubit, AppTheme>(
        builder: (context, selectedTheme) => ListView(
          // The bottom padding keeps the content above the translucent navigation bar.
          padding: EdgeInsets.fromLTRB(16, 24, 16, MediaQuery.paddingOf(context).bottom + 16),
          children: [
            _buildSectionTitle(palette),
            const SizedBox(height: 10),
            _buildThemeOptions(context, selectedTheme),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Your choice is kept on this phone.',
                style: TextStyle(fontSize: 12, height: 1.5, color: palette.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        'APPEARANCE',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildThemeOptions(BuildContext context, AppTheme selectedTheme) {
    final palette = context.palette;
    final cubit = context.read<ThemeCubit>();
    ThemeOptionTile option(AppTheme theme, IconData icon, String label, String detail) => ThemeOptionTile(
          icon: icon,
          label: label,
          detail: detail,
          isSelected: theme == selectedTheme,
          onSelected: () => cubit.selectTheme(theme),
        );
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          option(AppTheme.light, Icons.light_mode_outlined, 'Light', 'Always use the light theme'),
          Divider(height: 1, color: palette.divider),
          option(AppTheme.dark, Icons.dark_mode_outlined, 'Dark', 'Always use the dark theme'),
          Divider(height: 1, color: palette.divider),
          option(AppTheme.system, Icons.smartphone_outlined, 'System', 'Follow your phone’s setting'),
        ],
      ),
    );
  }
}
