import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../injection_container.dart';
import '../../../../../l10n/l10n.dart';
import '../../../domain/entities/article_draft.dart';
import '../../bloc/publish_article/publish_article_cubit.dart';
import '../../bloc/publish_article/publish_article_state.dart';
import '../../widgets/add_thumbnail.dart';
import '../../widgets/article_draft_error_messages.dart';
import '../../widgets/limited_text_field.dart';
import '../../widgets/markdown_editor.dart';
import '../../widgets/publish_article_button.dart';

/// Screen where a journalist writes and publishes an article. The draft is saved on the device
/// while writing and resumed the next time. Pops with `true` once the article has been published.
class PublishArticleView extends StatelessWidget {
  const PublishArticleView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PublishArticleCubit>()..resumeDraft(),
      child: const PublishArticleForm(),
    );
  }
}

enum _LeaveChoice { keepWriting, discardDraft, saveDraft }

class _FormControllers {
  final TextEditingController title;
  final TextEditingController author;
  final TextEditingController content;

  const _FormControllers({required this.title, required this.author, required this.content});

  void showDraft(ArticleDraftEntity draft) {
    title.text = draft.title;
    author.text = draft.author;
    content.text = draft.content;
  }
}

/// What every form field needs from the current state.
class _FormBinding {
  final PublishArticleCubit cubit;
  final ArticleDraftEntity draft;
  final AppLocalizations texts;
  final ArticleDraftErrorMessages errors;
  final bool isEditable;

  const _FormBinding({
    required this.cubit,
    required this.draft,
    required this.texts,
    required this.errors,
    required this.isEditable,
  });
}

/// The publish form. Expects a [PublishArticleCubit] above it.
class PublishArticleForm extends HookWidget {
  const PublishArticleForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = _FormControllers(
      title: useTextEditingController(),
      author: useTextEditingController(),
      content: useTextEditingController(),
    );
    return BlocConsumer<PublishArticleCubit, PublishArticleState>(
      listener: (context, state) {
        if (state is PublishArticleDraftLoaded) controllers.showDraft(state.draft);
        _onStateChanged(context, state);
      },
      builder: (context, state) => PopScope(
        canPop: _canLeaveWithoutConfirmation(state),
        onPopInvokedWithResult: (didPop, _) => _onLeaveBlocked(context, didPop),
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildForm(state, controllers),
          bottomNavigationBar: PublishArticleButton(
            isPublishing: state is PublishArticlePublishing,
            onPressed: () => _onPublishPressed(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        tooltip: context.l10n.back,
        icon: const Icon(Ionicons.chevron_back),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(context.l10n.publishArticle),
    );
  }

  Widget _buildForm(PublishArticleState state, _FormControllers controllers) {
    return Builder(builder: (context) {
      final binding = _FormBinding(
        cubit: context.read<PublishArticleCubit>(),
        draft: state.draft,
        texts: context.l10n,
        errors: ArticleDraftErrorMessages(state.visibleErrors, context.l10n),
        isEditable: state is! PublishArticlePublishing,
      );
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _padded(_buildTitleField(binding, controllers.title)),
          const SizedBox(height: 12),
          _padded(_buildAuthorField(binding, controllers.author)),
          const SizedBox(height: 20),
          _buildThumbnail(binding, state),
          const SizedBox(height: 20),
          _padded(_buildContentEditor(binding, controllers.content)),
        ],
      );
    });
  }

  Widget _buildTitleField(_FormBinding binding, TextEditingController controller) {
    return LimitedTextField(
      controller: controller,
      label: binding.texts.titleLabel,
      hintText: binding.texts.titleHint,
      maxLength: ArticleDraftEntity.titleMaxLength,
      maxLines: null,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      errorText: binding.errors.title,
      enabled: binding.isEditable,
      onChanged: binding.cubit.changeTitle,
    );
  }

  Widget _buildAuthorField(_FormBinding binding, TextEditingController controller) {
    return LimitedTextField(
      controller: controller,
      label: binding.texts.authorLabel,
      hintText: binding.texts.authorHint,
      maxLength: ArticleDraftEntity.authorMaxLength,
      errorText: binding.errors.author,
      enabled: binding.isEditable,
      onChanged: binding.cubit.changeAuthor,
    );
  }

  Widget _buildThumbnail(_FormBinding binding, PublishArticleState state) {
    return AddThumbnail(
      imagePath: state.draft.thumbnail?.localPath,
      errorText: binding.errors.thumbnail,
      onPickImage: binding.isEditable ? binding.cubit.pickThumbnail : null,
    );
  }

  Widget _buildContentEditor(_FormBinding binding, TextEditingController controller) {
    return MarkdownEditor(
      controller: controller,
      maxLength: ArticleDraftEntity.contentMaxLength,
      errorText: binding.errors.content,
      helperText: _writingStatsOf(binding),
      enabled: binding.isEditable,
      onChanged: binding.cubit.changeContent,
    );
  }

  /// "312 words · 2 min read" once the journalist starts writing.
  String? _writingStatsOf(_FormBinding binding) {
    final draft = binding.draft;
    if (draft.wordCount == 0) return null;
    return binding.texts.writingStats(draft.wordCount, draft.readingTimeInMinutes);
  }

  Widget _padded(Widget child) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
  }

  bool _canLeaveWithoutConfirmation(PublishArticleState state) {
    return state is! PublishArticlePublishing && !state.hasStartedWriting;
  }

  void _onPublishPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<PublishArticleCubit>().publish();
  }

  void _offerStartingOver(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text(context.l10n.draftRestored),
      action: SnackBarAction(label: context.l10n.startOver, onPressed: context.read<PublishArticleCubit>().startOver),
    ));
  }

  void _onStateChanged(BuildContext context, PublishArticleState state) {
    if (state is PublishArticleSuccess) {
      Navigator.pop(context, true);
    } else if (state is PublishArticleFailure) {
      _showFailure(context, state.reason);
    } else if (state is PublishArticleDraftLoaded && state.isRestored) {
      _offerStartingOver(context);
    }
  }

  void _showFailure(BuildContext context, PublishArticleFailureReason reason) {
    final isPublishFailure = reason == PublishArticleFailureReason.publishFailed;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        // Long enough to read the message and decide to retry.
        duration: const Duration(seconds: 10),
        content: Text(isPublishFailure ? context.l10n.publishFailed : context.l10n.galleryUnavailable),
        action: isPublishFailure
            ? SnackBarAction(label: context.l10n.retry, onPressed: context.read<PublishArticleCubit>().publish)
            : null,
      ));
  }

  Future<void> _onLeaveBlocked(BuildContext context, bool didPop) async {
    final cubit = context.read<PublishArticleCubit>();
    if (didPop || cubit.state is PublishArticlePublishing) return;
    final choice = await _askWhatToDoWithDraft(context);
    if (choice == _LeaveChoice.keepWriting) return;
    if (choice == _LeaveChoice.discardDraft) await cubit.discardDraft();
    // When saving, the cubit stores the latest changes as it closes.
    if (context.mounted) Navigator.pop(context);
  }

  Future<_LeaveChoice> _askWhatToDoWithDraft(BuildContext context) async {
    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.saveDraftQuestion),
        content: Text(context.l10n.saveDraftExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _LeaveChoice.keepWriting),
            child: Text(context.l10n.keepWriting),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _LeaveChoice.discardDraft),
            child: Text(context.l10n.discard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, _LeaveChoice.saveDraft),
            child: Text(context.l10n.saveDraft),
          ),
        ],
      ),
    );
    return choice ?? _LeaveChoice.keepWriting;
  }
}
