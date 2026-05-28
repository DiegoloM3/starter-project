import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/reading_time_badge.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

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
              SnackBar(
                backgroundColor: const Color(0xFFCE93D8),
                content: Text(message),
              ),
            );
            Navigator.pop(context);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red[400],
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
            backgroundColor: Colors.white,
            appBar: _buildAppBar(context, state),
            body: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            _buildTitleField(context, titleController),
                            const SizedBox(height: 16),
                            _buildDescriptionField(
                                context, descriptionController),
                            const SizedBox(height: 16),
                            _buildAttachImageButton(
                                context, state.selectedImagePath),
                            if (state.selectedImagePath != null) ...[
                              const SizedBox(height: 12),
                              _buildImagePreview(
                                  context, state.selectedImagePath!),
                            ],
                            const SizedBox(height: 16),
                            _buildContentField(context, contentController),
                            const SizedBox(height: 12),
                            _buildMetadataRow(state),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActions(context, formKey, state),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, CreateArticleState state) {
    return AppBar(
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child:
            const Icon(Icons.chevron_left, color: Colors.black, size: 30),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        draft != null
            ? AppLocalizations.of(context)!.editDraft
            : AppLocalizations.of(context)!.newArticle,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (state.isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFCE93D8),
                ),
              ),
            ),
          )
        else if (state.lastSavedAt != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.saved,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.save_outlined, color: Colors.black87),
          onPressed: () =>
              context.read<CreateArticleBloc>().add(const SaveDraft()),
          tooltip: AppLocalizations.of(context)!.saveDraftTooltip,
        ),
      ],
    );
  }

  Widget _buildTitleField(
      BuildContext context, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      minLines: 2,
      style: const TextStyle(fontSize: 18),
      onChanged: (value) =>
          context.read<CreateArticleBloc>().add(TitleChanged(value)),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.writeTitleHint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 18),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCE93D8)),
        ),
      ),
      validator: (value) {
        final l10n = AppLocalizations.of(context)!;
        if (value == null || value.trim().isEmpty) return l10n.titleRequired;
        if (value.trim().length > 200) return l10n.titleMaxLength;
        return null;
      },
    );
  }

  Widget _buildDescriptionField(
      BuildContext context, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      minLines: 2,
      style: const TextStyle(fontSize: 15),
      onChanged: (value) =>
          context.read<CreateArticleBloc>().add(DescriptionChanged(value)),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.briefDescriptionHint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCE93D8)),
        ),
      ),
      validator: (value) {
        final l10n = AppLocalizations.of(context)!;
        if (value == null || value.trim().isEmpty) return l10n.descriptionRequired;
        if (value.trim().length > 500) return l10n.descriptionMaxLength;
        return null;
      },
    );
  }

  Widget _buildAttachImageButton(
      BuildContext context, String? selectedImagePath) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _pickImage(context),
        icon: const Icon(Icons.camera_alt_outlined,
            color: Colors.black87, size: 20),
        label: Text(
          AppLocalizations.of(context)!.attachImage,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE1BEE7),
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, String imagePath) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(imagePath),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => context
                .read<CreateArticleBloc>()
                .add(const ThumbnailRemoved()),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentField(
      BuildContext context, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 10,
      minLines: 6,
      style: const TextStyle(fontSize: 15),
      onChanged: (value) =>
          context.read<CreateArticleBloc>().add(ContentChanged(value)),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.addArticleHint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCE93D8)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.contentRequired;
        }
        return null;
      },
    );
  }

  Widget _buildMetadataRow(CreateArticleState state) {
    return Row(
      children: [
        ReadingTimeBadge(minutes: state.readingTimeMinutes),
        const Spacer(),
        if (state.lastSavedAt != null)
          Text(
            _formatLastSaved(state.lastSavedAt!),
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    GlobalKey<FormState> formKey,
    CreateArticleState state,
  ) {
    final isLoading = state.isSaving || state.isPublishing;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () =>
                      context.read<CreateArticleBloc>().add(const SaveDraft()),
              icon: const Icon(Icons.drafts_outlined, size: 20),
              label: Text(AppLocalizations.of(context)!.saveDraft),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _onPreviewAndPublish(context, formKey),
              icon: state.isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.visibility, color: Colors.white, size: 20),
              label: Text(
                AppLocalizations.of(context)!.preview,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCE93D8),
                disabledBackgroundColor: const Color(0xFFE1BEE7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ],
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
