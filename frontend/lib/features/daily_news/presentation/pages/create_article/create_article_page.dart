import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../../../injection_container.dart';

class CreateArticlePage extends HookWidget {
  final ArticleEntity? draft;

  const CreateArticlePage({Key? key, this.draft}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController(text: draft?.title ?? '');
    final descriptionController =
        useTextEditingController(text: draft?.description ?? '');
    final contentController =
        useTextEditingController(text: draft?.content ?? '');
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return BlocProvider<CreateArticleBloc>(
      create: (_) {
        final bloc = sl<CreateArticleBloc>();
        if (draft != null) {
          bloc.add(LoadExistingDraft(draft!));
        }
        return bloc;
      },
      child: BlocConsumer<CreateArticleBloc, CreateArticleState>(
        listener: (context, state) {
          if (state.isPublished) {
            final l10n = AppLocalizations.of(context)!;
            final message = draft != null
                ? l10n.articleUpdatedSuccessfully
                : l10n.articlePublishedSuccessfully;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
            Navigator.pop(context);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error?.message ??
                    AppLocalizations.of(context)!.anErrorOccurred),
              ),
            );
          }
        },
        listenWhen: (prev, curr) =>
            prev.isPublished != curr.isPublished ||
            prev.error != curr.error,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            appBar: _buildAppBar(context, state),
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Cover image
                          _buildCoverImage(context, state.selectedImagePath),
                          // Fields
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title field
                                _buildTitleField(context, titleController),
                                // Description field
                                _buildDescriptionField(
                                    context, descriptionController),
                                // Content field
                                _buildContentField(
                                    context, contentController, state),
                              ],
                            ),
                          ),
                          // Stats bar
                          _buildStatsBar(state),
                        ],
                      ),
                    ),
                  ),
                  // Bottom action bar
                  _buildBottomBar(context, formKey, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CreateArticleState state) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: AppColors.t1, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            draft != null ? l10n.editArticle : l10n.newArticle,
            style: AppTypography.serif(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.t1,
            ),
          ),
          _buildSaveStatus(state, l10n),
        ],
      ),
      actions: [
        // Preview button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: OutlinedButton.icon(
            onPressed: () {
              final bloc = context.read<CreateArticleBloc>();
              Navigator.pushNamed(
                context,
                '/ArticlePreview',
                arguments: bloc.state,
              );
            },
            icon: Icon(Icons.visibility_outlined,
                size: 14, color: AppColors.t2),
            label: Text(
              l10n.preview,
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.t2,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildSaveStatus(CreateArticleState state, AppLocalizations l10n) {
    if (state.isSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 9,
            height: 9,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.t2,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Saving…',
            style: AppTypography.sans(fontSize: 10, color: AppColors.t2),
          ),
        ],
      );
    }
    if (state.lastSavedAt != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 11, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            '${l10n.saved} ${_formatLastSaved(state.lastSavedAt!)}',
            style: AppTypography.sans(fontSize: 10, color: AppColors.t3),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCoverImage(BuildContext context, String? selectedImagePath) {
    if (selectedImagePath != null) {
      return Stack(
        children: [
          Image.file(
            File(selectedImagePath),
            width: double.infinity,
            height: 190,
            fit: BoxFit.cover,
          ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => context
                  .read<CreateArticleBloc>()
                  .add(const ThumbnailRemoved()),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0x73000000),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close, color: Colors.white, size: 15),
              ),
            ),
          ),
          // "Cover image" label
          Positioned(
            bottom: 12,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x73000000),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                'COVER IMAGE',
                style: AppTypography.sans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Empty state — dashed border
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: double.infinity,
        height: 86,
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(
              color: AppColors.red.withValues(alpha: 0.3),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.red, size: 22),
            const SizedBox(height: 7),
            Text(
              'Add cover image',
              style: AppTypography.sans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(
      BuildContext context, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: null,
        minLines: 2,
        style: AppTypography.serif(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.t1,
          height: 1.25,
          letterSpacing: -0.3,
        ),
        onChanged: (value) =>
            context.read<CreateArticleBloc>().add(TitleChanged(value)),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.writeTitleHint,
          hintStyle: AppTypography.serif(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.t3,
            height: 1.25,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        validator: (value) {
          final l10n = AppLocalizations.of(context)!;
          if (value == null || value.trim().isEmpty) return l10n.titleRequired;
          if (value.trim().length > 200) return l10n.titleMaxLength;
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField(
      BuildContext context, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPTION',
            style: AppTypography.sans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.t3,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: null,
            minLines: 2,
            style: AppTypography.sans(
              fontSize: 14.5,
              color: AppColors.t1,
              height: 1.6,
            ),
            onChanged: (value) => context
                .read<CreateArticleBloc>()
                .add(DescriptionChanged(value)),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.briefDescriptionHint,
              hintStyle: AppTypography.sans(
                fontSize: 14.5,
                color: AppColors.t3,
                height: 1.6,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              final l10n = AppLocalizations.of(context)!;
              if (value == null || value.trim().isEmpty) {
                return l10n.descriptionRequired;
              }
              if (value.trim().length > 500) return l10n.descriptionMaxLength;
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentField(BuildContext context,
      TextEditingController controller, CreateArticleState state) {
    return Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with reading time pill
          Row(
            children: [
              Text(
                'CONTENT',
                style: AppTypography.sans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.t3,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              if (state.readingTimeMinutes > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule,
                          size: 11, color: AppColors.t2),
                      const SizedBox(width: 4),
                      Text(
                        '${state.readingTimeMinutes} min read',
                        style: AppTypography.sans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.t2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            maxLines: null,
            minLines: 8,
            style: AppTypography.serif(
              fontSize: 15.5,
              fontWeight: FontWeight.w400,
              color: AppColors.t1,
              height: 1.82,
            ),
            onChanged: (value) =>
                context.read<CreateArticleBloc>().add(ContentChanged(value)),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.addArticleHint,
              hintStyle: AppTypography.serif(
                fontSize: 15.5,
                fontWeight: FontWeight.w400,
                color: AppColors.t3,
                height: 1.82,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(bottom: 14),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.contentRequired;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(CreateArticleState state) {
    final wordCount = state.content.trim().isEmpty
        ? 0
        : state.content.trim().split(RegExp(r'\s+')).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            '$wordCount word${wordCount != 1 ? 's' : ''}',
            style: AppTypography.sans(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.t3,
            ),
          ),
          Text(' · ',
              style: AppTypography.sans(fontSize: 10, color: AppColors.t3)),
          const Icon(Icons.schedule, size: 12, color: AppColors.t3),
          const SizedBox(width: 4),
          Text(
            '${state.readingTimeMinutes} min read',
            style: AppTypography.sans(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.t3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    GlobalKey<FormState> formKey,
    CreateArticleState state,
  ) {
    final isLoading = state.isSaving || state.isPublishing;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Publish — primary CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _onPreviewAndPublish(context, formKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  disabledBackgroundColor: const Color(0xFF991818),
                  foregroundColor: Colors.white,
                  disabledForegroundColor:
                      Colors.white.withValues(alpha: 0.88),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: state.isPublishing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Publishing…',
                            style: AppTypography.sans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '→  ${l10n.publishArticle}',
                        style: AppTypography.sans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Save as draft
            TextButton(
              onPressed: isLoading
                  ? null
                  : () =>
                      context.read<CreateArticleBloc>().add(const SaveDraft()),
              child: Text(
                l10n.saveDraft,
                style: AppTypography.sans(
                  fontSize: 13,
                  color: AppColors.t2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPreviewAndPublish(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final state = context.read<CreateArticleBloc>().state;
    final result = await Navigator.pushNamed(
      context,
      '/ArticlePreview',
      arguments: state,
    );

    if (result == true && context.mounted) {
      context.read<CreateArticleBloc>().add(const PublishArticle());
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked != null) {
      context.read<CreateArticleBloc>().add(ThumbnailSelected(picked.path));
    }
  }

  String _formatLastSaved(DateTime lastSaved) {
    final diff = DateTime.now().difference(lastSaved);
    if (diff.inSeconds < 10) return '✓';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h';
  }
}
