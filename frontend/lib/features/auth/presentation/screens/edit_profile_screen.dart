import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/edit_profile/edit_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/session/session_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/media/user_avatar.dart';

/// Change the display name and the photo shown on articles.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read once: the cubit keeps its own copy, so a session refresh after
    // saving never rebuilds the form mid-flight.
    final user = context.read<SessionCubit>().state.user;
    if (user == null) return const SizedBox.shrink();
    return BlocProvider(
      create: (_) => sl<EditProfileCubit>(param1: user),
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late final TextEditingController _name =
      TextEditingController(text: context.read<EditProfileCubit>().state.displayName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<EditProfileCubit>();
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) => previous.status != current.status || previous.failure != current.failure,
      listener: (context, state) {
        if (state.status == EditProfileStatus.success) {
          showAppSnackBar(context, 'Profile updated');
          Navigator.of(context).pop();
        } else if (state.failure case final failure?) {
          showAppSnackBar(context, FailureMessageFormatter.of(failure));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: LabeledIconButton.back(
                    onPressed: state.isSubmitting ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.xxl),
                  child: Text('EDIT PROFILE', style: AppTypography.tabTitle.copyWith(color: palette.ink)),
                ),
                Center(
                  child: Column(
                    children: [
                      state.photo != null
                          ? Container(
                              decoration: BoxDecoration(border: Border.all(color: palette.ink, width: AppRules.strong)),
                              padding: const EdgeInsets.all(2),
                              child: Image.file(File(state.photo!.path), width: 104, height: 104, fit: BoxFit.cover),
                            )
                          : UserAvatar(
                              name: state.original.preferredName,
                              photoUrl: state.original.photoUrl,
                              size: 112,
                              isCurrentUser: true,
                              ringed: true,
                            ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: state.isSubmitting ? null : cubit.pickPhoto,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(state.original.hasPhoto || state.photo != null ? 'Change photo' : 'Add a photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                LabeledTextField(
                  label: 'Display name',
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  errorText: state.displayNameError?.message,
                  onChanged: cubit.displayNameChanged,
                  onSubmitted: (_) => cubit.submit(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your name appears on every article you publish.',
                  style: AppTypography.caption.copyWith(color: palette.inkSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: state.isSubmitting ? 'Saving…' : 'Save changes',
                  isLoading: state.isSubmitting,
                  onPressed: state.hasChanges ? cubit.submit : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
