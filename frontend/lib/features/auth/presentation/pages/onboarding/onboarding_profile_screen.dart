import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/widgets/app_button.dart';
import 'package:news_app_clean_architecture/core/widgets/app_card.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text_field.dart';
import 'package:news_app_clean_architecture/core/widgets/avatar_picker.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/onboarding_layout.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  static const _bioMaxLength = 160;

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _imageFile;
  bool _submitted = false;
  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not open image picker.')),
        );
    }
  }

  void _onContinue() {
    setState(() => _attemptedSubmit = true);

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final bio = _bioController.text.trim();
    final cappedBio =
        bio.length > _bioMaxLength ? bio.substring(0, _bioMaxLength) : bio;

    setState(() => _submitted = true);

    context.read<AuthCubit>().updateUserProfile(
          authState.user.copyWith(
            displayName: name,
            bio: cappedBio,
            photoURL: _imageFile?.path,
            onboardingStep: 3,
            onboardingCompleted: true,
          ),
        );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (!_submitted) return;

    if (state is AuthAuthenticated) {
      _submitted = false;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } else if (state is AuthError) {
      _submitted = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _handleAuthState,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = _submitted && state is AuthLoading;

          return OnboardingLayout(
            currentStep: 3,
            bottomButton: ListenableBuilder(
              listenable: _nameController,
              builder: (context, _) {
                final hasName = _nameController.text.trim().isNotEmpty;
                return AppButton(
                  label: 'Start exploring →',
                  isLoading: isLoading,
                  onPressed: hasName && !isLoading ? _onContinue : null,
                );
              },
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Your journalistic signature',
                  variant: AppTextVariant.displayLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                const AppText(
                  'This information will appear on your articles. Only your name is required.',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: AppSpacing.xl),

                // ── Avatar picker ──
                AvatarPicker(
                  imageFile: _imageFile,
                  onTap: _pickImage,
                  size: 80.r,
                ),
                SizedBox(height: AppSpacing.xs),
                const Center(
                  child: AppText(
                    'Upload profile photo',
                    variant: AppTextVariant.labelLarge,
                    color: AppColors.accent,
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // ── Full Name field ──
                Row(
                  children: [
                    const AppText(
                        'Full Name', variant: AppTextVariant.titleMedium),
                    SizedBox(width: AppSpacing.xs),
                    const AppText(
                      '*',
                      variant: AppTextVariant.titleMedium,
                      color: AppColors.accent,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: _nameController,
                  hint: 'The name that will appear on your articles',
                  errorText: _attemptedSubmit &&
                          _nameController.text.trim().isEmpty
                      ? 'Name is required'
                      : null,
                  onChanged: (_) {
                    if (_attemptedSubmit) setState(() {});
                  },
                ),

                SizedBox(height: AppSpacing.lg),

                // ── Bio field ──
                Row(
                  children: [
                    const AppText(
                        'Short bio', variant: AppTextVariant.titleMedium),
                    SizedBox(width: AppSpacing.xs),
                    const AppText(
                      'optional',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: _bioController,
                  hint: 'Tell us about your journalistic approach...',
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_bioController.text.length}/$_bioMaxLength',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // ── Trust banner ──
                AppCard(
                  variant: AppCardVariant.dark,
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                            children: const [
                              TextSpan(
                                  text: 'In Pulse News we believe in '),
                              TextSpan(
                                text: 'total accountability',
                                style:
                                    TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text:
                                    '. Your real name builds trust with your readers.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
