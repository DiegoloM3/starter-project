import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_shadows.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/news_form/news_form_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/user_profile/user_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/helpers/article_section_helper.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/helpers/error_type_l10n.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/dialogs/edit_profile_dialog.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/form/form_section_selector.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/form/photo_gallery_picker.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/inputs/input_text_area.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/inputs/input_text_field.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/app_icon_button.dart';

class NewsFormView extends StatefulWidget {
  final bool hasDraft;

  const NewsFormView({super.key, this.hasDraft = false});

  @override
  State<NewsFormView> createState() => _NewsFormViewState();
}

class _NewsFormViewState extends State<NewsFormView> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final state = context.read<NewsFormBloc>().state;
    _titleController = TextEditingController(text: state.title);
    _bodyController = TextEditingController(text: state.body);

    if (widget.hasDraft) {
      _syncControllersFromBloc();
    }
  }

  void _syncControllersFromBloc() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<NewsFormBloc>().state;
      _titleController.text = state.title;
      _bodyController.text = state.body;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewsFormBloc, NewsFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStateChanged,
      builder: (context, state) {
        return PopScope(
          canPop: !state.hasUnsavedChanges,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _showDiscardDialog();
          },
          child: Scaffold(
            backgroundColor: context.colors.bgPage,
            body: SafeArea(
              child: Column(
                children: [
                  _Header(
                    isEditing: state.isEditing,
                    onBack: _handleBack,
                  ),
                  _FormArea(
                    titleController: _titleController,
                    bodyController: _bodyController,
                    onPickImage: () => _pickImage(context),
                  ),
                  _ActionBar(
                    state: state,
                    onSubmit: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, NewsFormState state) {
    if (state.status == FormStatus.success) {
      Navigator.pop(context, true);
    }
    if (state.status == FormStatus.savedAsDraft) {
      Navigator.pop(context);
    }
    if (state.status == FormStatus.failure) {
      _showFailureDialog(context, state);
    }
  }

  void _showFailureDialog(BuildContext context, NewsFormState state) {
    final l10n = AppLocalizations.of(context)!;
    final errorMessage = state.errorType?.toMessage(context) ?? l10n.genericError;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.publishErrorTitle),
        content: Text(errorMessage),
        actions: [
          if (!state.isEditing)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NewsFormBloc>().add(const NewsFormSavedAsDraft());
              },
              child: Text(l10n.saveAsDraftAction),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.retryAction),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final cubit = sl<UserProfileCubit>();
    if (cubit.state.displayName == null) {
      _showNameRequiredDialog(cubit);
    } else {
      context.read<NewsFormBloc>().add(const NewsFormSubmitted());
    }
  }

  void _showNameRequiredDialog(UserProfileCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        currentName: cubit.state.name ?? '',
        currentEmail: cubit.state.email ?? '',
        onSave: (name, email) {
          cubit.updateProfile(name: name, email: email);
          final displayName = cubit.state.displayName;
          if (displayName != null && mounted) {
            context.read<NewsFormBloc>().add(NewsFormAuthorChanged(displayName));
            context.read<NewsFormBloc>().add(const NewsFormSubmitted());
          }
        },
      ),
    );
  }

  void _handleBack() {
    final state = context.read<NewsFormBloc>().state;
    if (state.hasUnsavedChanges) {
      _showDiscardDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showDiscardDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(
              l10n.discardAction,
              style: const TextStyle(color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<NewsFormBloc>();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: Text(l10n.imageSourceCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: Text(l10n.imageSourceGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && mounted) {
      bloc.add(NewsFormImageAdded(File(pickedFile.path)));
    }
  }
}

class _Header extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onBack;

  const _Header({required this.isEditing, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = isEditing ? l10n.editNewsTitle : l10n.newNewsTitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing8,
        AppDimensions.spacing24,
        AppDimensions.spacing16,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.chevron_left,
            onPressed: onBack,
          ),
          const SizedBox(width: AppDimensions.spacing14),
          Text(
            title,
            style: AppTypography.sectionTitle.copyWith(
              color: context.colors.textPrimary,
              letterSpacing: AppDimensions.letterSpacingTight,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormArea extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final VoidCallback onPickImage;

  const _FormArea({
    required this.titleController,
    required this.bodyController,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: BlocBuilder<NewsFormBloc, NewsFormState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacing24,
              AppDimensions.spacing8,
              AppDimensions.spacing24,
              AppDimensions.spacing24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputTextField(
                  label: l10n.formTitleLabel,
                  hint: l10n.formTitleHint,
                  controller: titleController,
                  onChanged: (value) {
                    context
                        .read<NewsFormBloc>()
                        .add(NewsFormTitleChanged(value));
                  },
                ),
                const SizedBox(height: AppDimensions.spacing20),
                FormSectionSelector<NewsSection>(
                  label: l10n.formSectionLabel,
                  items: NewsSection.values
                      .where((s) => s != NewsSection.all)
                      .toList(),
                  selectedItem: state.selectedSection,
                  onChanged: (section) {
                    context
                        .read<NewsFormBloc>()
                        .add(NewsFormSectionChanged(section));
                  },
                  labelBuilder: (section) => section.label(l10n),
                ),
                const SizedBox(height: AppDimensions.spacing20),
                PhotoGalleryPicker(
                  label: l10n.formImagesLabel,
                  images: state.images,
                  canAddMore: state.canAddMoreImages,
                  onAddPhotoTapped: onPickImage,
                  onImageRemoved: (index) {
                    context
                        .read<NewsFormBloc>()
                        .add(NewsFormImageRemoved(index));
                  },
                  hintText: state.isEditing
                      ? l10n.formImageHintEdit(
                          state.images.length, state.maxImages)
                      : l10n.formImageHintCreate(state.maxImages),
                ),
                const SizedBox(height: AppDimensions.spacing20),
                InputTextArea(
                  label: l10n.formBodyLabel,
                  hint: l10n.formBodyHint,
                  controller: bodyController,
                  onChanged: (value) {
                    context
                        .read<NewsFormBloc>()
                        .add(NewsFormBodyChanged(value));
                  },
                  maxLines: 10,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final NewsFormState state;
  final VoidCallback onSubmit;

  const _ActionBar({required this.state, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacing24,
        AppDimensions.spacing16,
        AppDimensions.spacing24,
        AppDimensions.spacing32,
      ),
      child: Row(
        children: [
          if (state.isEditing) ...[
            _DeleteButton(
              onPressed: () => _showDeleteDialog(context, l10n),
            ),
            const SizedBox(width: AppDimensions.spacing12),
          ],
          Expanded(
            child: _SubmitButton(state: state, onSubmit: onSubmit),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteNewsTitle),
        content: Text(l10n.deleteNewsBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NewsFormBloc>().add(const NewsFormDeleted());
            },
            child: Text(
              l10n.deleteAction,
              style: const TextStyle(color: AppColors.coral),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final NewsFormState state;
  final VoidCallback onSubmit;

  const _SubmitButton({required this.state, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    if (state.status == FormStatus.submitting) {
      return Container(
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.accentGreen,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: AppShadows.ctaGreen,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final label =
        state.isEditing ? l10n.saveChangesButton : l10n.publishButton;
    final icon = state.isEditing ? LucideIcons.save : LucideIcons.send;

    return IgnorePointer(
      ignoring: !state.canSubmit,
      child: Opacity(
        opacity: state.canSubmit
            ? AppDimensions.opacityEnabled
            : AppDimensions.opacityDisabled,
        child: GestureDetector(
          onTap: onSubmit,
          child: Container(
            height: AppDimensions.buttonHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing24,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              boxShadow: AppShadows.ctaGreen,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: AppDimensions.iconDefault, color: AppColors.white),
                const SizedBox(width: AppDimensions.spacing10),
                Text(
                  label,
                  style: AppTypography.buttonLarge.copyWith(
                    color: AppColors.white,
                    letterSpacing: AppDimensions.letterSpacingWide,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppDimensions.buttonHeight,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: const Center(
          child: Icon(
            LucideIcons.trash2,
            size: AppDimensions.iconLg,
            color: AppColors.coral,
          ),
        ),
      ),
    );
  }
}
