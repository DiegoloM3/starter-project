import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../auth/presentation/bloc/auth/auth_cubit.dart';
import '../../../domain/entities/appearance.dart';
import '../../bloc/appearance/appearance_cubit.dart';
import '../../bloc/notifications/notifications_cubit.dart';
import '../../bloc/notifications/notifications_state.dart';
import '../../widgets/settings_section_title.dart';
import '../legal/legal_documents.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          const SettingsSectionTitle('Apariencia'),
          const Divider(),
          BlocBuilder<AppearanceCubit, Appearance>(
            builder:
                (context, currentAppearance) => Column(
                  children:
                      Appearance.values
                          .map(
                            (appearance) =>
                                _AppearanceTile(appearance: appearance, isSelected: appearance == currentAppearance),
                          )
                          .toList(),
                ),
          ),
          const Divider(),
          const SettingsSectionTitle('Notificaciones'),
          const Divider(),
          const _NotificationsTile(),
          const Divider(),
          const SettingsSectionTitle('Información'),
          const Divider(),
          for (final document in LegalDocument.values) ...[
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(document.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.legal, arguments: document),
            ),
            const Divider(),
          ],
          const SettingsSectionTitle('Cuenta'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: context.read<AuthCubit>().signOut,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
            title: Text('Eliminar cuenta', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.deleteAccount),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

/// Only the preference is stored for now: sending push notifications needs a Cloud Function.
class _NotificationsTile extends StatelessWidget {
  const _NotificationsTile();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listenWhen: (_, state) => state.saveFailed,
      listener:
          (context, _) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No se pudo guardar la preferencia. Inténtalo de nuevo.'))),
      builder:
          (context, state) => SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Nuevos artículos'),
            subtitle: const Text('Avisarme cuando publique alguien que sigo.'),
            value: state.isEnabled ?? false,
            onChanged: state.isEnabled == null ? null : context.read<NotificationsCubit>().setEnabled,
          ),
    );
  }
}

class _AppearanceTile extends StatelessWidget {
  final Appearance appearance;
  final bool isSelected;

  const _AppearanceTile({required this.appearance, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_icon),
      title: Text(_label),
      trailing: isSelected ? const Icon(Icons.check) : null,
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.onSurface,
      onTap: () => context.read<AppearanceCubit>().choose(appearance),
    );
  }

  String get _label => switch (appearance) {
    Appearance.light => 'Claro',
    Appearance.dark => 'Oscuro',
  };

  IconData get _icon => switch (appearance) {
    Appearance.light => Icons.light_mode_outlined,
    Appearance.dark => Icons.dark_mode_outlined,
  };
}
