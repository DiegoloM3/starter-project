import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:tortutip/features/articles/presentation/bloc/create_article/create_article_state.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tortutip/features/auth/presentation/bloc/auth_state.dart';
import 'package:tortutip/features/articles/presentation/screens/preview_article_screen.dart';
import 'package:tortutip/features/articles/presentation/widgets/cover_upload_widget.dart';
import 'package:tortutip/features/articles/presentation/widgets/rich_text_toolbar.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/l10n/app_localizations.dart';
import 'package:tortutip/shared/widgets/tortutip_button.dart';
import 'package:tortutip/shared/widgets/tortutip_chip.dart';

class CreateArticleScreen extends StatefulWidget {
  final ArticleEntity? article;

  const CreateArticleScreen({super.key, this.article});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  late final CreateArticleCubit _cubit;
  late final QuillController _quillController;
  late final TextEditingController _titleController;
  final _imagePicker = ImagePicker();
  String _userId = '';
  String _authorName = '';
  String _authorAvatarUrl = '';

  bool _isUploadingVertical = false;
  bool _isUploadingHorizontal = false;
  Object? _coverVerticalSource;
  Object? _coverHorizontalSource;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<CreateArticleCubit>();
    _quillController = QuillController.basic();
    _titleController = TextEditingController();

    _quillController.addListener(_onBodyChanged);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userId = authState.user.id;
      _authorName = authState.user.name;
      _authorAvatarUrl = authState.user.avatarUrl;
    }

    _cubit.loadCategories();

    if (widget.article != null) {
      final article = widget.article!;
      _titleController.text = article.title;

      // Pre-populate the Quill editor with the article's body text
      if (article.body.isNotEmpty) {
        final doc = Document()..insert(0, article.body);
        _quillController.document = doc;
      }

      _cubit.initForEdit(article);
    }
  }

  void _onBodyChanged() {
    final json = jsonEncode(_quillController.document.toDelta().toJson());
    _cubit.updateBody(json);
  }

  @override
  void dispose() {
    _quillController.removeListener(_onBodyChanged);
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  bool _hasContent() {
    return _titleController.text.trim().isNotEmpty ||
        _coverVerticalSource != null ||
        _coverHorizontalSource != null ||
        _quillController.document.length > 1;
  }

  Future<void> _onClose() async {
    if (!_hasContent()) {
      context.pop();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(l10n.createArticleDiscardTitle, style: AppTypography.h3),
        content: Text(
          l10n.createArticleDiscardContent,
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.createArticleKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.createArticleDiscard,
              style: AppTypography.label.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.pop();
    }
  }

  Future<void> _pickImage(bool isVertical) async {
    if (!mounted) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: AppSpacing.dragHandleWidth,
              height: AppSpacing.xs,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Builder(
              builder: (ctx2) {
                final l10n2 = AppLocalizations.of(ctx2);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined,
                          color: AppColors.textPrimary),
                      title: Text(l10n2.createArticleCameraOption, style: AppTypography.body),
                      onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined,
                          color: AppColors.textPrimary),
                      title: Text(l10n2.createArticleLibraryOption, style: AppTypography.body),
                      onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    // Refresh userId in case it wasn't ready in initState
    if (_userId.isEmpty) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) _userId = authState.user.id;
    }

    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).createArticleNotAuthError)),
      );
      return;
    }

    final picked =
        await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (picked == null || !mounted) return;

    final imageFile = File(picked.path);

    setState(() {
      if (isVertical) {
        _isUploadingVertical = true;
        _coverVerticalSource = imageFile;
      } else {
        _isUploadingHorizontal = true;
        _coverHorizontalSource = imageFile;
      }
    });

    await _cubit.uploadCoverImage(imageFile, isVertical, _userId);

    if (mounted) {
      setState(() {
        _isUploadingVertical = false;
        _isUploadingHorizontal = false;
      });
    }
  }

  void _onCoverUrlsUpdated(String? vertical, String? horizontal) {
    var changed = false;
    if (vertical != null && _coverVerticalSource != vertical) changed = true;
    if (horizontal != null && _coverHorizontalSource != horizontal) changed = true;
    if (!changed) return;
    setState(() {
      if (vertical != null) _coverVerticalSource = vertical;
      if (horizontal != null) _coverHorizontalSource = horizontal;
    });
  }

  void _onPreview() {
    final bodyJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    final verticalUrl =
        _coverVerticalSource is String ? _coverVerticalSource as String : null;
    final horizontalUrl = _coverHorizontalSource is String
        ? _coverHorizontalSource as String
        : null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewArticleScreen(
          title: _titleController.text,
          categoryId: '',
          bodyJson: bodyJson,
          coverVerticalUrl: verticalUrl,
          coverHorizontalUrl: horizontalUrl,
        ),
      ),
    );
  }

  void _onPublish() {
    _cubit.publishFromForm(
      _userId,
      authorName: _authorName,
      authorAvatarUrl: _authorAvatarUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _CreateArticleView(
        quillController: _quillController,
        titleController: _titleController,
        isUploadingVertical: _isUploadingVertical,
        isUploadingHorizontal: _isUploadingHorizontal,
        coverVerticalSource: _coverVerticalSource,
        coverHorizontalSource: _coverHorizontalSource,
        onClose: _onClose,
        onPickImage: _pickImage,
        onPreview: _onPreview,
        onPublish: _onPublish,
        onTitleChanged: (t) => _cubit.updateTitle(t),
        onCoverUrlsUpdated: _onCoverUrlsUpdated,
        isEditing: widget.article != null,
      ),
    );
  }
}

class _CreateArticleView extends StatelessWidget {
  final QuillController quillController;
  final TextEditingController titleController;
  final bool isUploadingVertical;
  final bool isUploadingHorizontal;
  final Object? coverVerticalSource;
  final Object? coverHorizontalSource;
  final VoidCallback onClose;
  final Future<void> Function(bool isVertical) onPickImage;
  final VoidCallback onPreview;
  final VoidCallback onPublish;
  final ValueChanged<String> onTitleChanged;
  final void Function(String? vertical, String? horizontal) onCoverUrlsUpdated;
  final bool isEditing;

  const _CreateArticleView({
    required this.quillController,
    required this.titleController,
    required this.isUploadingVertical,
    required this.isUploadingHorizontal,
    required this.coverVerticalSource,
    required this.coverHorizontalSource,
    required this.onClose,
    required this.onPickImage,
    required this.onPreview,
    required this.onPublish,
    required this.onTitleChanged,
    required this.onCoverUrlsUpdated,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<CreateArticleCubit, CreateArticleState>(
      listener: (ctx, state) {
        if (state is CreateArticlePublished) {
          context.pop();
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              content: Text(
                AppLocalizations.of(ctx).createArticlePublishedSuccess,
                style: AppTypography.body.copyWith(color: AppColors.textOnDark),
              ),
            ),
          );
        } else if (state is CreateArticleError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(
                state.message,
                style: AppTypography.body.copyWith(color: AppColors.textOnDark),
              ),
            ),
          );
        } else if (state is CreateArticleFormUpdated) {
          onCoverUrlsUpdated(
            state.coverVerticalUrl,
            state.coverHorizontalUrl,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CoverUploadWidget(
                      coverVerticalSource: coverVerticalSource,
                      coverHorizontalSource: coverHorizontalSource,
                      isUploadingVertical: isUploadingVertical,
                      isUploadingHorizontal: isUploadingHorizontal,
                      onTapVertical: () => onPickImage(true),
                      onTapHorizontal: () => onPickImage(false),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      child: TextField(
                        controller: titleController,
                        style: AppTypography.h1
                            .copyWith(color: AppColors.textPrimary),
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: l10n.createArticleTitleHint,
                          hintStyle: AppTypography.h1
                              .copyWith(color: AppColors.textTertiary),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: onTitleChanged,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CategorySelector(),
                    const SizedBox(height: AppSpacing.sm),
                    RichTextToolbar(controller: quillController),
                    QuillEditor.basic(
                      controller: quillController,
                      config: QuillEditorConfig(
                        placeholder: l10n.createArticleBodyHint,
                        minHeight: 200,
                        scrollable: false,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.lg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _BottomBar(
              onPreview: onPreview,
              onPublish: onPublish,
              isEditing: isEditing,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelector extends StatefulWidget {
  @override
  State<_CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<_CategorySelector> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateArticleCubit, CreateArticleState>(
      builder: (ctx, state) {
        final l10n = AppLocalizations.of(ctx);
        final categories = state is CreateArticleFormUpdated
            ? state.categories
            : <CategoryEntity>[];
        if (categories.isEmpty) return const SizedBox.shrink();

        // Sync selection with cubit state (handles pre-loaded edit mode)
        if (state is CreateArticleFormUpdated && _selectedId == null && state.categoryId.isNotEmpty) {
          _selectedId = state.categoryId;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Text(
                l10n.createArticleChooseCategory,
                style:
                    AppTypography.label.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: categories.map((cat) {
                  return _SelectableCategoryChip(
                    category: cat,
                    isSelected: _selectedId == cat.id,
                    onTap: () {
                      setState(() => _selectedId = cat.id);
                      context.read<CreateArticleCubit>().selectCategory(cat.id);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectableCategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = chipColorForCategoryName(category.name);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.$1
              : colors.$1.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          category.name.toUpperCase(),
          style: AppTypography.labelSm.copyWith(color: colors.$2),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onPublish;
  final bool isEditing;

  const _BottomBar({
    required this.onPreview,
    required this.onPublish,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateArticleCubit, CreateArticleState>(
      builder: (ctx, state) {
        final l10n = AppLocalizations.of(ctx);
        final isPublishing = state is CreateArticlePublishing;
        final canPublish = !isPublishing &&
            state is CreateArticleFormUpdated &&
            state.isValid;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TortuSecondaryButton(
                    label: l10n.createArticlePreview,
                    onTap: isPublishing ? null : onPreview,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TortuPrimaryButton(
                    label: isEditing ? l10n.createArticleUpdate : l10n.createArticlePublish,
                    onTap: canPublish ? onPublish : null,
                    isLoading: isPublishing,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
