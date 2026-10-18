import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/bloc/auth/auth_cubit.dart';
import '../../../domain/entities/appearance.dart';
import '../../bloc/appearance/appearance_cubit.dart';
import '../../widgets/settings_section_title.dart';

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
          const SettingsSectionTitle('Cuenta'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: context.read<AuthCubit>().signOut,
          ),
          const Divider(),
        ],
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
