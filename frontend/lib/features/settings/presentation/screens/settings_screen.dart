import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/constants/app_info.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_row.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/settings_section.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/text_size_control.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/widgets/settings/theme_mode_selector.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';

/// Appearance, feed defaults, listening, about, and the account actions,
/// each section headed in small capitals over a rule.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, current) =>
              current is SessionAuthenticated && current.failure != null,
          listener: (context, state) => showAppSnackBar(
            context,
            FailureMessageFormatter.of((state as SessionAuthenticated).failure!),
          ),
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) => current.saveFailure != null,
          listener: (context, state) => showAppSnackBar(
            context,
            FailureMessageFormatter.of(state.saveFailure!),
          ),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LabeledIconButton.back(onPressed: () => Navigator.of(context).pop()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.sm, AppSpacing.screenMargin, AppSpacing.lg),
                child: Text('SETTINGS', style: AppTypography.tabTitle.copyWith(color: palette.ink)),
              ),
              const _AppearanceSection(),
              const _FeedSection(),
              const _ReadingSection(),
              const _AboutSection(),
              const _AccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSection(
          title: 'Appearance',
          children: [
            ThemeModeSelector(
              selected: state.settings.themeMode,
              onChanged: cubit.setThemeMode,
            ),
            TextSizeControl(
              selected: state.settings.textSize,
              onChanged: cubit.setTextSize,
            ),
          ],
        );
      },
    );
  }
}

class _FeedSection extends StatelessWidget {
  const _FeedSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSection(
          title: 'Feed',
          children: [
            SettingsRow(
              label: 'Default category',
              value: state.settings.defaultCategory.label,
              onTap: context.pushDefaultCategoryPicker,
            ),
          ],
        );
      },
    );
  }
}

class _ReadingSection extends StatelessWidget {
  const _ReadingSection();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSection(
          title: 'Listen',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.md, AppSpacing.screenMargin, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reading speed', style: AppTypography.valueLine.copyWith(color: palette.ink, fontSize: 16)),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedButton<SpeechRatePreference>(
                    showSelectedIcon: false,
                    expandedInsets: EdgeInsets.zero,
                    segments: [
                      for (final rate in SpeechRatePreference.values)
                        ButtonSegment(value: rate, label: Text(rate.label)),
                    ],
                    selected: {state.settings.speechRate},
                    onSelectionChanged: (selection) =>
                        context.read<SettingsCubit>().setSpeechRate(selection.first),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'About',
      children: [
        SettingsRow(
          label: 'About ${AppInfo.name}',
          value: 'v${AppInfo.version}',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: AppInfo.name,
            applicationVersion: AppInfo.version,
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        final email = state.user?.email;
        return SettingsSection(
          title: email == null ? 'Account' : 'Account · $email',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.md, AppSpacing.screenMargin, AppSpacing.xl),
              child: OutlinedButton.icon(
                onPressed: _isBusy(state) ? null : context.read<SessionCubit>().signOut,
                icon: const Icon(Icons.logout_rounded, size: AppSizes.buttonIcon),
                label: const Text('Sign out'),
              ),
            ),
          ],
        );
      },
    );
  }
}

bool _isBusy(SessionState state) => state is SessionAuthenticated && state.isBusy;
