import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/profile_cubit.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_cubit.dart';
import 'package:news_app_clean_architecture/shared/auth/presentation/bloc/session_state.dart';

Future<void> showEditProfileDialog(BuildContext context) async {
  final profile = context.read<ProfileCubit>();
  final session = context.read<SessionCubit>();
  final sessionState = session.state;
  final initial = sessionState is SessionAuthenticated
      ? (sessionState.user.displayName ?? '')
      : '';
  final controller = TextEditingController(text: initial);
  final formKey = GlobalKey<FormState>();

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Edit profile'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name cannot be empty';
              if (v.trim().length > 80) return 'Max 80 characters';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  if (saved == true) {
    await profile.updateDisplayName(controller.text.trim());
  }
  controller.dispose();
}
