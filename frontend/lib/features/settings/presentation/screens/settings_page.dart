import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_bloc.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_event.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/locale/locale_state.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(title: t.settingsLanguageSection),
          const _LanguageSection(),
          const SizedBox(height: 16),
          _SectionHeader(title: t.settingsPermissionsSection),
          const _PermissionsSection(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return RadioGroup<LocalePreference>(
          groupValue: state.preference,
          onChanged: (value) {
            if (value == null) return;
            context.read<LocaleBloc>().add(LocalePreferenceChanged(value));
          },
          child: Column(
            children: [
              RadioListTile<LocalePreference>(
                title: Text(t.settingsLanguageSystem),
                subtitle: Text(t.settingsLanguageSystemSubtitle),
                value: LocalePreference.system,
              ),
              RadioListTile<LocalePreference>(
                title: Text(t.languageEnglish),
                value: LocalePreference.english,
              ),
              RadioListTile<LocalePreference>(
                title: Text(t.languageSpanish),
                value: LocalePreference.spanish,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        _PermissionTile(
          icon: Icons.camera_alt_outlined,
          title: t.permissionCameraTitle,
          reason: t.permissionCameraReason,
        ),
        _PermissionTile(
          icon: Icons.photo_library_outlined,
          title: t.permissionPhotosTitle,
          reason: t.permissionPhotosReason,
        ),
        _PermissionTile(
          icon: Icons.public,
          title: t.permissionInternetTitle,
          reason: t.permissionInternetReason,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Text(
            t.settingsPermissionsHelp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reason;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(reason),
    );
  }
}
