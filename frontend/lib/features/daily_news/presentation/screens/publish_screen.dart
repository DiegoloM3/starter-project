import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/app_router.dart';
import 'package:news_app_clean_architecture/config/theme/app_palette.dart';
import 'package:news_app_clean_architecture/config/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/editor_assistant/editor_assistant_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/feed/feed_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/publish/publish_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/category_chips.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/editor_suggestions_sheet.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/photo_field.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/publish/publish_success_view.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/destructive_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/labeled_icon_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/primary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/buttons/secondary_button.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/feedback/app_snack_bar.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/fields/labeled_text_field.dart';

/// Write a new article or edit one of your own. On success the feed and
/// My Articles are updated and a full-screen confirmation takes over.
class PublishScreen extends StatelessWidget {
  final ArticleEntity? article;

  const PublishScreen({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PublishCubit>(param1: article)..restoreDraft()),
        BlocProvider(create: (_) => sl<EditorAssistantCubit>()),
      ],
      child: const PublishView(),
    );
  }
}

class PublishView extends StatefulWidget {
  const PublishView({super.key});

  @override
  State<PublishView> createState() => _PublishViewState();
}

class _PublishViewState extends State<PublishView> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _content;

  @override
  void initState() {
    super.initState();
    final state = context.read<PublishCubit>().state;
    _title = TextEditingController(text: state.title);
    _description = TextEditingController(text: state.description);
    _content = TextEditingController(text: state.content);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _content.dispose();
    super.dispose();
  }

  /// Opens the editor's sheet and asks; "Use this" writes into the form.
  Future<void> _askEditor(BuildContext context) async {
    final publish = context.read<PublishCubit>();
    final assistant = context.read<EditorAssistantCubit>();
    assistant.ask(publish.state.draft);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: assistant,
        child: BlocBuilder<EditorAssistantCubit, EditorAssistantState>(
          builder: (sheetContext, state) => EditorSuggestionsSheet(
            suggestions: state.suggestions,
            isLoading: state.isLoading,
            errorMessage: state.failure == null ? null : FailureMessageFormatter.of(state.failure!),
            onUseHeadline: (headline) {
              _title.text = headline;
              publish.titleChanged(headline);
              Navigator.of(sheetContext).pop();
            },
            onUseSummary: (summary) {
              _description.text = summary;
              publish.descriptionChanged(summary);
              Navigator.of(sheetContext).pop();
            },
          ),
        ),
      ),
    );
    assistant.dismiss();
  }

  /// The cubit rewrote the fields itself (draft restored or cleared): the
  /// controllers follow. Setting `text` does not fire `onChanged`, so this
  /// never loops back into the cubit.
  void _syncControllers(PublishState state) {
    _title.text = state.title;
    _description.text = state.description;
    _content.text = state.content;
  }

  void _onSuccess(BuildContext context, PublishState state) {
    final article = state.result!;
    context.read<MyArticlesCubit>().upsert(article);
    context.read<FeedCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cubit = context.read<PublishCubit>();
    return BlocConsumer<PublishCubit, PublishState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.failure != current.failure ||
          previous.draftNotice != current.draftNotice,
      listener: (context, state) {
        if (state.status == PublishStatus.success) _onSuccess(context, state);
        if (state.failure case final failure?) {
          showAppSnackBar(context, FailureMessageFormatter.of(failure));
        }
        if (state.draftNotice case final notice?) {
          _syncControllers(state);
          showAppSnackBar(
            context,
            notice == DraftNotice.restored ? 'Your draft is back where you left it.' : 'Draft cleared.',
          );
        }
      },
      builder: (context, state) {
        if (state.status == PublishStatus.success) {
          final article = state.result!;
          return PublishSuccessView(
            article: article,
            wasEdit: state.isEditing,
            onRead: () {
              context.goHome();
              context.pushReader(article);
            },
            onBackHome: context.goHome,
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.screenMargin, AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: palette.outlineStrong, width: AppRules.strong)),
                  ),
                  child: Row(
                    children: [
                      LabeledIconButton.cancel(
                        onPressed: state.isSubmitting ? null : () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        (state.isEditing ? 'Edit article' : 'New article').toUpperCase(),
                        style: AppTypography.sectionOverline.copyWith(color: palette.ink, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.lg, AppSpacing.screenMargin, AppSpacing.xxl),
                    children: [
                      LabeledTextField(
                        label: 'Title',
                        required: true,
                        controller: _title,
                        maxLength: ArticleLimits.titleMaxLength,
                        textStyle: AppTypography.cardTitle.copyWith(color: palette.ink, fontSize: 20),
                        textCapitalization: TextCapitalization.sentences,
                        errorText: state.titleError?.message,
                        onChanged: cubit.titleChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PhotoField(
                        localPath: state.pickedImage?.path,
                        remoteUrl: state.existingImageUrl,
                        isUploading: state.isSubmitting && state.pickedImage != null,
                        onPick: cubit.pickPhoto,
                        onRemove: cubit.removePhoto,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LabeledTextField(
                        label: 'Short description',
                        optional: true,
                        controller: _description,
                        maxLength: ArticleLimits.descriptionMaxLength,
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        errorText: state.descriptionError?.message,
                        onChanged: cubit.descriptionChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LabeledTextField(
                        label: 'Article text',
                        required: true,
                        controller: _content,
                        maxLength: ArticleLimits.contentMaxLength,
                        minLines: 8,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        errorText: state.contentError?.message,
                        onChanged: cubit.contentChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SecondaryButton(
                        label: 'Ask the editor',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: state.canAskEditor && !state.isSubmitting ? () => _askEditor(context) : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CategoryChips(selected: state.category, onChanged: cubit.categoryChanged),
                      // Last on purpose: wiping the draft should take a scroll
                      // to reach, never a stray tap near the header.
                      if (state.hasDraftContent) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        DestructiveButton(
                          label: 'Clear draft',
                          icon: Icons.delete_sweep_rounded,
                          onPressed: state.isSubmitting ? null : cubit.clearDraft,
                        ),
                      ],
                    ],
                  ),
                ),
                _Footer(state: state, onSubmit: cubit.submit),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  final PublishState state;
  final VoidCallback onSubmit;

  const _Footer({required this.state, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final label = state.isSubmitting
        ? 'Publishing…'
        : state.isEditing
            ? 'Save changes'
            : 'Publish Article';
    final hint = state.isSubmitting ? 'Keep the app open until this finishes.' : state.missingHint;
    return Material(
      color: palette.background,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenMargin, AppSpacing.md, AppSpacing.screenMargin, AppSpacing.md),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: palette.ink, width: AppRules.strong))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              label: label,
              isLoading: state.isSubmitting,
              onPressed: state.canSubmit ? onSubmit : null,
            ),
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: AppTypography.captionSmall.copyWith(color: palette.inkSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
