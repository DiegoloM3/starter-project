import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/author_avatar.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import 'package:news_app_clean_architecture/features/auth/presentation/bloc/profile/profile_bloc.dart';

/// Screen for editing display name, avatar, and profile data.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const LoadProfile()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  String? _userId;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      // Same cap as article thumbnails: avatars render at ≤48px radius.
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  void _onSave() {
    if (_userId == null) return;
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
          SaveProfile(
            userId: _userId!,
            displayName: _nameController.text,
            avatarFile: _pickedImage,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: _onStateChanged,
      builder: (context, state) {
        if (state is ProfileDone && !_initialized) {
          _initialized = true;
          _userId = state.userId;
          _nameController.text = state.displayName;
        }
        return Scaffold(
          appBar: _buildAppBar(state),
          body: _buildBody(state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileState state) {
    return AppBar(
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: const Icon(Ionicons.chevronBack, color: Colors.black),
      ),
      title: const Text('Edit Profile',
          style: TextStyle(color: Colors.black)),
      actions: [
        if (state is ProfileSaving)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CupertinoActivityIndicator(),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _userId == null ? null : _onSave,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state is ProfileLoading || state is ProfileSaving) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (state is ProfileError && !_initialized) {
      return Center(child: Text(state.message));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAvatarPicker(state),
            const SizedBox(height: 24),
            _buildNameField(state),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(ProfileState state) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          _pickedImage != null
              ? CircleAvatar(
                  radius: 48,
                  backgroundImage: FileImage(_pickedImage!),
                )
              : AuthorAvatar(
                  authorId: _userId,
                  radius: 48,
                  cubitFactory: () => sl<AuthorAvatarCubit>(),
                ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Ionicons.cameraOutline,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(ProfileState state) {
    final email =
        state is ProfileDone ? state.email : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              email,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
        ),
      ],
    );
  }

  void _onStateChanged(BuildContext context, ProfileState state) {
    if (state is ProfileSaved) {
      // Refresh the global auth state so the sidebar and indicators pick
      // up the new name and photo without requiring a re-login.
      context.read<AuthBloc>().add(const CheckAuthStatus());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.black,
          content: Text('Profile updated successfully!'),
        ),
      );
      Navigator.pop(context);
    }
    if (state is ProfileError && _initialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(state.message),
        ),
      );
    }
  }
}
