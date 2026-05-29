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
    final cs = Theme.of(context).colorScheme;
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
      // Listener only: navigation/snackbars on terminal states. The Scaffold
      // structure is built once; the parts that change use granular
      // BlocBuilders so a keystroke only rebuilds the affected widget.
      child: BlocListener<CreateArticleBloc, CreateArticleState>(
        listenWhen: (prev, curr) =>
            prev.isPublished != curr.isPublished || prev.error != curr.error,
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
        // Builder gives a context BELOW the BlocProvider so the AppBar action
        // and the field onChanged callbacks can context.read<CreateArticleBloc>().
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: cs.surface,
            appBar: _buildAppBar(context),
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
                          BlocBuilder<CreateArticleBloc, CreateArticleState>(
                            buildWhen: (p, c) =>
                                p.selectedImagePath != c.selectedImagePath,
                            builder: (context, state) => _buildCoverImage(
                                context, state.selectedImagePath),
                          ),
                          // Fields
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title field
                                _buildTitleField(context, titleController),
                                // Description field
                                _buildDescriptionField(
                                    context, descriptionController),
                                // Content field
                                _buildContentField(context, contentController),
                              ],
                            ),
                          ),
                          // Stats bar
                          BlocBuilder<CreateArticleBloc, CreateArticleState>(
                            buildWhen: (p, c) =>
                                p.content != c.content ||
                                p.readingTimeMinutes != c.readingTimeMinutes,
                            builder: (context, state) =>
                                _buildStatsBar(context, state),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom action bar
                  BlocBuilder<CreateArticleBloc, CreateArticleState>(
                    buildWhen: (p, c) =>
                        p.isSaving != c.isSaving ||
                        p.isPublishing != c.isPublishing,
                    builder: (context, state) =>
                        _buildBottomBar(context, formKey, state),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: cs.onSurface, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            draft != null ? l10n.editArticle : l10n.newArticle,
            style: tt.bodyLarge?.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          // Self-contained: only the save indicator rebuilds (never the whole
          // AppBar), and it lives in a fixed-height slot so the title Column
          // never changes size or inserts/removes a node.
          BlocBuilder<CreateArticleBloc, CreateArticleState>(
            buildWhen: (p, c) =>
                p.isSaving != c.isSaving || p.lastSavedAt != c.lastSavedAt,
            builder: (context, state) => _buildSaveStatus(context, state, l10n),
          ),
        ],
      ),
      actions: [
        // Preview button
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
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
                size: 14, color: cs.onSurfaceVariant),
            label: Text(
              l10n.preview,
              style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            style: OutlinedButton.styleFrom(
              // Override the global OutlinedButtonTheme's full-width
              // minimumSize (Size(double.infinity, 52)). In the AppBar actions
              // slot — measured with unbounded width during overlay/route
              // layout — an infinite minWidth leaves the button un-laid-out and
              // trips '!semantics.parentDataDirty' every frame. Size it to its
              // content instead, as an AppBar action should.
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: BorderSide(color: cs.outline, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: cs.outline),
      ),
    );
  }

  Widget _buildSaveStatus(
      BuildContext context, CreateArticleState state, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sem = context.semantic;
    final Widget content;
    if (state.isSaving) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 9,
            height: 9,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            l10n.savingDraft,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: cs.onSurfaceVariant,
              letterSpacing: 0,
            ),
          ),
        ],
      );
    } else if (state.lastSavedAt != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 11, color: sem.success),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${l10n.saved} ${_formatLastSaved(state.lastSavedAt!)}',
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: cs.outlineVariant,
              letterSpacing: 0,
            ),
          ),
        ],
      );
    } else {
      content = const SizedBox.shrink();
    }
    // Fixed-height, always-present slot keeps the AppBar title Column a constant
    // size and node structure, so updating the save indicator never relayouts
    // the title box (which would desync semantics parentData in Flutter 3.44).
    return SizedBox(height: 16, child: content);
  }

  Widget _buildCoverImage(BuildContext context, String? selectedImagePath) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
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
            top: AppSpacing.md,
            right: AppSpacing.md,
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
                child: const Icon(Icons.close, color: Colors.white, size: 15),
              ),
            ),
          ),
          // "Cover image" label
          Positioned(
            bottom: AppSpacing.md,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x73000000),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                l10n.coverImage,
                style: tt.labelSmall?.copyWith(
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
              color: cs.primary.withValues(alpha: 0.3),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: cs.primary, size: 22),
            const SizedBox(height: 7),
            Text(
              l10n.addCoverImage,
              style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: null,
        minLines: 2,
        style: tt.headlineMedium?.copyWith(
          height: 1.25,
        ),
        onChanged: (value) =>
            context.read<CreateArticleBloc>().add(TitleChanged(value)),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.writeTitleHint,
          hintStyle: tt.headlineMedium?.copyWith(
            color: cs.outlineVariant,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.descriptionLabel,
            style: tt.labelSmall?.copyWith(
              color: cs.outlineVariant,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: null,
            minLines: 2,
            style: tt.bodyMedium?.copyWith(
              height: 1.6,
            ),
            onChanged: (value) => context
                .read<CreateArticleBloc>()
                .add(DescriptionChanged(value)),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.briefDescriptionHint,
              hintStyle: tt.bodyMedium?.copyWith(
                color: cs.outlineVariant,
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

  Widget _buildContentField(
      BuildContext context, TextEditingController controller) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with reading time pill
          Row(
            children: [
              Text(
                l10n.contentLabel,
                style: tt.labelSmall?.copyWith(
                  color: cs.outlineVariant,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              // Live reading-time pill — only this rebuilds as you type.
              BlocBuilder<CreateArticleBloc, CreateArticleState>(
                buildWhen: (p, c) =>
                    p.readingTimeMinutes != c.readingTimeMinutes,
                builder: (context, state) {
                  if (state.readingTimeMinutes <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule,
                            size: 11, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.readingTime(state.readingTimeMinutes),
                          style: tt.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            maxLines: null,
            minLines: 8,
            style: tt.bodyLarge?.copyWith(
              height: 1.82,
            ),
            onChanged: (value) =>
                context.read<CreateArticleBloc>().add(ContentChanged(value)),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.addArticleHint,
              hintStyle: tt.bodyLarge?.copyWith(
                color: cs.outlineVariant,
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

  Widget _buildStatsBar(BuildContext context, CreateArticleState state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final wordCount = state.content.trim().isEmpty
        ? 0
        : state.content.trim().split(RegExp(r'\s+')).length;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: Row(
        children: [
          Text(
            l10n.wordCount(wordCount),
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: cs.outlineVariant,
              letterSpacing: 0,
            ),
          ),
          Text(' · ',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w400,
                color: cs.outlineVariant,
                letterSpacing: 0,
              )),
          Icon(Icons.schedule, size: 12, color: cs.outlineVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(
            l10n.readingTime(state.readingTimeMinutes),
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: cs.outlineVariant,
              letterSpacing: 0,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLoading = state.isSaving || state.isPublishing;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, 10, AppSpacing.gutter, 14),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
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
                  backgroundColor: cs.primary,
                  disabledBackgroundColor: const Color(0xFF991818),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.88),
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
                            l10n.publishing,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '→  ${l10n.publishArticle}',
                        style: tt.titleMedium?.copyWith(
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
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: cs.onSurfaceVariant,
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
    if (picked != null && context.mounted) {
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
