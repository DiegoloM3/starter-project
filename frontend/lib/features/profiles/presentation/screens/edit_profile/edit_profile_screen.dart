import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/users/domain/entities/user.dart';
import '../../../../../shared/users/presentation/widgets/user_avatar.dart';
import '../../../../articles/presentation/widgets/editor/gallery_image_picker.dart';
import '../../../domain/params/update_profile_params.dart';
import '../../bloc/edit_profile/edit_profile_cubit.dart';
import '../../bloc/edit_profile/edit_profile_state.dart';
import 'profile_validation_messages.dart';

/// Edits the photo, name and bio of the signed in user. It closes once the profile is saved.
class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstNameController = TextEditingController(text: widget.user.firstName);
  late final TextEditingController _lastNameController = TextEditingController(text: widget.user.lastName);
  late final TextEditingController _bioController = TextEditingController(text: widget.user.bio);
  Uint8List? _newPhoto;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listener: _onStateChanged,
      builder:
          (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Editar perfil'), actions: [_buildSaveButton(state)]),
            body: _buildForm(state.validationErrors),
          ),
    );
  }

  Widget _buildSaveButton(EditProfileState state) {
    if (state.isSaving) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return TextButton(onPressed: _save, child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.w700)));
  }

  Widget _buildForm(Set<ProfileValidationError> errors) {
    final photoError = messageForField(errors, photoErrors);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(child: _buildPhoto()),
        TextButton(onPressed: _pickPhoto, child: const Text('Cambiar foto')),
        if (photoError != null)
          Text(photoError, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 16),
        _buildTextField(
          _firstNameController,
          'Nombre',
          ProfileLimits.nameMaxLength,
          messageForField(errors, firstNameErrors),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _lastNameController,
          'Apellido',
          ProfileLimits.nameMaxLength,
          messageForField(errors, lastNameErrors),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          maxLength: ProfileLimits.bioMaxLength,
          maxLines: null,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Biografía',
            alignLabelWithHint: true,
            errorText: messageForField(errors, bioErrors),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto() {
    if (_newPhoto == null) return UserAvatar(user: widget.user, radius: 48);
    return CircleAvatar(radius: 48, backgroundImage: MemoryImage(_newPhoto!));
  }

  Widget _buildTextField(TextEditingController controller, String label, int maxLength, String? errorText) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label, errorText: errorText, counterText: ''),
    );
  }

  Future<void> _pickPhoto() async {
    final photo = await pickImageFromGallery();
    if (photo != null) setState(() => _newPhoto = photo);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<EditProfileCubit>().save(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      bio: _bioController.text,
      newPhoto: _newPhoto,
    );
  }

  void _onStateChanged(BuildContext context, EditProfileState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state.status == EditProfileStatus.success) {
      messenger.showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
      Navigator.of(context).pop(true);
    } else if (state.status == EditProfileStatus.failure) {
      final message =
          state.validationErrors.isEmpty
              ? 'No se pudo guardar el perfil. Inténtalo de nuevo.'
              : 'Revisa los campos marcados.';
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
