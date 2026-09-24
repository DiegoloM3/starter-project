import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/design_tokens.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/alert_banner.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/article_markdown.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/widgets/guided_tour.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/relative_time.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../domain/entities/journalist_article.dart';
import '../../bloc/article_editor/article_editor_cubit.dart';
import '../../bloc/article_editor/article_editor_state.dart';
import '../../widgets/article_failure_text.dart';
import '../../widgets/cover_image_field.dart';
import '../../widgets/markdown_demo.dart';
import '../../widgets/markdown_toolbar.dart';

/// Where an article is written.
///
/// The fields carry no boxes or borders: this screen is a page to write on,
/// and a form that looks like a form gets in the way of that. The only thing
/// competing for attention is the article itself.
class ArticleEditorScreen extends StatefulWidget {
  const ArticleEditorScreen({super.key});

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  final _coverKey = GlobalKey();
  final _titleKey = GlobalKey();
  final _toolbarKey = GlobalKey();
  final _previewKey = GlobalKey();
  final _publishKey = GlobalKey();

  /// Whether the body is being previewed instead of edited.
  ///
  /// Markdown is only friendly to somebody who can see what it turns into.
  /// Without this the toolbar writes characters whose meaning a
  /// non-technical writer has no way to learn.
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    _fillControllersWith(context.read<ArticleEditorCubit>().state);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticleEditorCubit, ArticleEditorState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStateChanged,
      builder: (context, state) {
        return PopScope(
          // Leaving is blocked only while something would be lost; the rest
          // of the time back behaves exactly as anybody expects.
          canPop: !state.hasUnsavedChanges,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              _confirmLeaving(context, state);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: AppSpacing.sm,
              toolbarHeight: 72,
              leading: const _BackButton(),
              title: Text(
                state.isEditingStoredArticle
                    ? AppLocalizations.of(context).editArticle
                    : AppLocalizations.of(context).newArticle,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 28,
                    ),
              ),
              actions: [
                IconButton(
                  onPressed: _startTour,
                  icon: const Icon(Icons.help_outline),
                  tooltip: AppLocalizations.of(context).howToWrite,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
            body: state.status == ArticleEditorStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : _buildForm(context, state),
            bottomNavigationBar: _EditorActions(
              state: state,
              publishKey: _publishKey,
            ),
          ),
        );
      },
    );
  }

  /// Asks before throwing away work.
  ///
  /// Autosave keeps a titled draft safe, but not an article written before it
  /// was named and not a published one — saving that silently would change
  /// what readers already have. Both are exactly when somebody can walk away
  /// from work they meant to keep, so this is the one place the app stops
  /// them to ask.
  Future<void> _confirmLeaving(
    BuildContext context,
    ArticleEditorState state,
  ) async {
    final navigator = Navigator.of(context);

    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).unsavedTitle),
        content: Text(AppLocalizations.of(context).unsavedMessage),
        // Two actions, weighted. Going back to the article is filled and
        // Discard is plain text in red: the safe way out should be the
        // easier target, and the one that destroys work should take a
        // deliberate look. Saving is not offered here — the Save changes
        // button is a tap away on the screen this returns to, and a third
        // action turned a question into a menu.
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _LeaveChoice.discard),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(AppLocalizations.of(context).discard),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _LeaveChoice.keepWriting),
            child: Text(AppLocalizations.of(context).keepWriting),
          ),
        ],
      ),
    );

    if (choice == _LeaveChoice.discard) {
      navigator.pop();
    }
  }

  /// The editor, read top to bottom: a cover, a headline, a standfirst and
  /// the body. Each part is named rather than spelled out here, so this reads
  /// as the shape of the form instead of as 90 lines of decoration.
  Widget _buildForm(BuildContext context, ArticleEditorState state) {
    final cubit = context.read<ArticleEditorCubit>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.huge,
      ),
      children: [
        // Above the article, not under it. Every failure reads the same way
        // and stays until it is dealt with: it used to be two messages at
        // once — a banner for a validation error and a snack bar for
        // everything else — and the banner sat at the bottom of a long
        // scrolling form where the journalist never saw it.
        if (state.error != null) ...[
          AlertBanner(
            ArticleFailureText.messageFor(
              AppLocalizations.of(context),
              state.error,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        CoverImageField(
          key: _coverKey,
          imageUrl: state.article.thumbnailUrl,
          isUploading: state.status == ArticleEditorStatus.uploadingThumbnail,
          onPick: cubit.pickCover,
          onRemove: cubit.removeThumbnail,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _TitleField(
          fieldKey: _titleKey,
          controller: _titleController,
          onChanged: cubit.titleChanged,
        ),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        _DescriptionField(
          controller: _descriptionController,
          onChanged: cubit.descriptionChanged,
        ),
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        _BodyHeader(
          previewKey: _previewKey,
          previewing: _previewing,
          onTogglePreview: () => setState(() => _previewing = !_previewing),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_previewing)
          _BodyPreview(content: state.article.content)
        else
          _BodyField(
            toolbarKey: _toolbarKey,
            controller: _contentController,
            onChanged: cubit.contentChanged,
          ),
      ],
    );
  }

  void _onStateChanged(BuildContext context, ArticleEditorState state) {
    if (state.status == ArticleEditorStatus.editing) {
      _fillControllersWith(state);
      return;
    }
    // Publishing makes something public, which is worth stopping to
    // acknowledge. Saving a draft is routine, so it just closes the editor.
    if (state.status == ArticleEditorStatus.published) {
      Navigator.pushReplacementNamed(
        context,
        '/ArticlePublished',
        arguments: state.article,
      );
      return;
    }
    if (state.status == ArticleEditorStatus.saved) {
      Navigator.pop(context);
      return;
    }
  }

  /// The five things somebody needs to know to publish an article.
  ///
  /// Written as a short walk rather than a page of instructions: the guide
  /// points at the real controls on the real screen, so what is learned is
  /// where things are, not what a manual said about them.
  void _startTour() {
    // Formatting cannot be explained while the preview is up, because the
    // toolbar it talks about is not on screen.
    if (_previewing) {
      setState(() => _previewing = false);
    }

    final l10n = AppLocalizations.of(context);

    GuidedTour.show(context, [
      GuidedTourStep(
        targetKey: _coverKey,
        title: l10n.tourCoverTitle,
        body: l10n.tourCoverBody,
      ),
      GuidedTourStep(
        targetKey: _titleKey,
        title: l10n.tourTitleTitle,
        body: l10n.tourTitleBody,
      ),
      GuidedTourStep(
        targetKey: _toolbarKey,
        title: l10n.tourFormatTitle,
        body: l10n.tourFormatBody,
        demo: const MarkdownDemo(
          samples: [
            '## A heading',
            'Some **bold** words',
            'And *italic* ones',
            '- A point worth making',
            '> Something somebody said',
          ],
        ),
      ),
      GuidedTourStep(
        targetKey: _previewKey,
        title: l10n.tourPreviewTitle,
        body: l10n.tourPreviewBody,
      ),
      GuidedTourStep(
        targetKey: _publishKey,
        title: l10n.tourPublishTitle,
        body: l10n.tourPublishBody,
      ),
    ]);
  }

  /// Keeps the text fields in sync with an article loaded asynchronously.
  void _fillControllersWith(ArticleEditorState state) {
    if (_titleController.text != state.article.title) {
      _titleController.text = state.article.title;
    }
    if (_descriptionController.text != state.article.description) {
      _descriptionController.text = state.article.description;
    }
    if (_contentController.text != state.article.content) {
      _contentController.text = state.article.content;
    }
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        shape: CircleBorder(
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          // maybePop, so this asks the same question the system back button
          // does instead of quietly bypassing it.
          onTap: () => Navigator.maybePop(context),
          child: const SizedBox(
            height: 44,
            width: 44,
            child: Icon(Icons.arrow_back, size: 20),
          ),
        ),
      ),
    );
  }
}

/// The two ways out of the editor, and a quiet word about the autosave.
class _EditorActions extends StatelessWidget {
  final ArticleEditorState state;
  final Key publishKey;

  const _EditorActions({required this.state, required this.publishKey});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ArticleEditorCubit>();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AutosaveNote(state: state),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: state.canPublish
                      ? OutlinedButton(
                          onPressed: state.isBusy ? null : cubit.save,
                          child: Text(AppLocalizations.of(context).saveChanges),
                        )
                      // On a published article saving *is* the main action,
                      // so it takes the filled button the second one left.
                      : FilledButton(
                          key: publishKey,
                          onPressed: state.isBusy ? null : cubit.save,
                          child: Text(AppLocalizations.of(context).saveChanges),
                        ),
                ),
                if (state.canPublish) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      key: publishKey,
                      onPressed: state.isBusy ? null : cubit.publish,
                      child: Text(AppLocalizations.of(context).publish),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Draft saved · 2 min ago".
///
/// Ambient on purpose: it never takes focus, never covers the keyboard and
/// never navigates. The person is mid-sentence, and an autosave that
/// interrupts is worse than no autosave.
class _AutosaveNote extends StatelessWidget {
  final ArticleEditorState state;

  const _AutosaveNote({required this.state});

  @override
  Widget build(BuildContext context) {
    final savedAt = state.article.updatedAt;

    // An article being saved for the very first time has no stored copy and
    // no timestamp yet, and used to show nothing at all: both buttons went
    // dead and the screen looked frozen rather than busy.
    if (state.isSaving) {
      return SizedBox(
        height: 16,
        child: Text(
          AppLocalizations.of(context).saving,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      );
    }

    if (!state.article.isStored || savedAt == null) {
      return const SizedBox(height: 16);
    }

    return SizedBox(
      height: 16,
      child: Text(
        AppLocalizations.of(context).draftSavedAt(
          RelativeTime.format(AppLocalizations.of(context), savedAt)
              .toLowerCase(),
        ),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

/// The line between writing the body and seeing what it will look like.
class _BodyHeader extends StatelessWidget {
  final Key previewKey;
  final bool previewing;
  final VoidCallback onTogglePreview;

  const _BodyHeader({
    required this.previewKey,
    required this.previewing,
    required this.onTogglePreview,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context).articleSection,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Spacer(),
        TextButton.icon(
          key: previewKey,
          onPressed: onTogglePreview,
          icon: Icon(
            previewing ? Icons.edit_outlined : Icons.visibility_outlined,
            size: 18,
          ),
          label: Text(
            previewing
                ? AppLocalizations.of(context).keepWriting
                : AppLocalizations.of(context).preview,
          ),
        ),
      ],
    );
  }
}

class _BodyPreview extends StatelessWidget {
  final String content;

  const _BodyPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Text(
          AppLocalizations.of(context).nothingToPreview,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ArticleMarkdown(content);
  }
}

/// What somebody chose when told their work was not saved.
enum _LeaveChoice { discard, keepWriting }

/// The headline, typed straight into the page at display size rather than
/// into a labelled box: the editor should look like the article.
class _TitleField extends StatelessWidget {
  final Key fieldKey;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _TitleField({
    required this.fieldKey,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: 26,
        );

    return TextField(
      key: fieldKey,
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      style: style,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).titleHint,
        hintStyle: style?.copyWith(
          color: Theme.of(context).textTheme.labelSmall?.color,
        ),
        border: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

/// The standfirst, with its length limit shown while the journalist writes
/// rather than sprung on them when they try to publish.
class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DescriptionField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      maxLength: JournalistArticleEntity.descriptionMaxLength,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).descriptionHint,
        border: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
        counterStyle: theme.textTheme.labelSmall,
      ),
    );
  }
}

/// The body: the Markdown toolbar and the text it acts on, which belong
/// together because the toolbar edits this controller.
class _BodyField extends StatelessWidget {
  final Key toolbarKey;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _BodyField({
    required this.toolbarKey,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MarkdownToolbar(
          key: toolbarKey,
          controller: controller,
          onChanged: onChanged,
        ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: null,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).contentHint,
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
