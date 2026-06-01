import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_event.dart';
import 'package:tortutip/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:tortutip/features/profile/presentation/bloc/edit_profile_state.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';
import 'package:tortutip/shared/widgets/tortutip_input.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String? _currentAvatarUrl;
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio);
    _currentAvatarUrl =
        widget.user.avatarUrl.isNotEmpty ? widget.user.avatarUrl : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onTapAvatar() async {
    final picker = ImagePicker();
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.editProfileCamera),
              onTap: () async {
                Navigator.of(ctx).pop();
                final file = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (file != null && mounted) {
                  context.read<EditProfileCubit>().uploadAvatar(
                        File(file.path),
                        widget.user.id,
                      );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.editProfileGallery),
              onTap: () async {
                Navigator.of(ctx).pop();
                final file = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (file != null && mounted) {
                  context.read<EditProfileCubit>().uploadAvatar(
                        File(file.path),
                        widget.user.id,
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onSignOut(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editProfileSignOutTitle),
        content: Text(l10n.editProfileSignOutContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.editProfileCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const SignOutEvent());
            },
            child: Text(l10n.editProfileSignOutConfirm),
          ),
        ],
      ),
    );
  }

  void _onDeleteAccount(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editProfileDeleteAccountTitle),
        content: const Text(
          '¿Estás seguro? Esta acción es irreversible y eliminará todos tus datos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.editProfileCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<EditProfileCubit>().deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.editProfileDeleteAccountConfirm),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _nameError = true);
      return;
    }
    setState(() => _nameError = false);
    context.read<EditProfileCubit>().saveProfile(
          currentUser: widget.user,
          name: name,
          bio: _bioController.text.trim(),
          avatarUrl: _currentAvatarUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileImageUploaded) {
          setState(() => _currentAvatarUrl = state.avatarUrl);
        } else if (state is EditProfileAccountDeleted) {
          context.read<AuthBloc>().add(const SignOutEvent());
        } else if (state is EditProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.dragHandleWidth,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.editProfileTitle, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xl),
            _AvatarPicker(
              avatarUrl: _currentAvatarUrl,
              name: widget.user.name,
              onTap: _onTapAvatar,
            ),
            const SizedBox(height: AppSpacing.xl),
            TortuTextField(
              hint: l10n.editProfileNameHint,
              controller: _nameController,
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
            ),
            if (_nameError)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.lg),
                child: Text(
                  'El nombre debe tener al menos 2 caracteres',
                  style: AppTypography.caption.copyWith(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            TortuTextField(
              hint: l10n.editProfileBioHint,
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.xxl),
            BlocBuilder<EditProfileCubit, EditProfileState>(
              builder: (context, state) {
                final isLoading = state is EditProfileLoading ||
                    state is EditProfileImageUploading;
                return Column(
                  children: [
                    TortuPrimaryButton(
                      label: l10n.editProfileSaveChanges,
                      onTap: isLoading ? null : _onSave,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TortuSecondaryButton(
                      label: l10n.editProfileCancel,
                      onTap: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: isLoading ? null : () => _onSignOut(context),
                      child: Text(
                        l10n.editProfileSignOutConfirm,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => _onDeleteAccount(context),
                      child: Text(
                        l10n.editProfileDeleteAccountTitle,
                        style: AppTypography.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.avatarUrl,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.surface,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    initials,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.white,
                size: AppSpacing.iconSizeMd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
