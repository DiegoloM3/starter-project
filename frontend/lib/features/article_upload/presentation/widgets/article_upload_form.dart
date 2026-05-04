import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/upload/upload_article_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/auto_save_indicator.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/category_chips.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/tags_field.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/widgets/thumbnail_picker.dart';
import 'package:news_app_clean_architecture/l10n/generated/app_localizations.dart';

class ArticleUploadForm extends StatefulWidget {
  final UploadArticleState state;

  const ArticleUploadForm({super.key, required this.state});

  @override
  State<ArticleUploadForm> createState() => _ArticleUploadFormState();
}

class _ArticleUploadFormState extends State<ArticleUploadForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.state.title);
    _descriptionController =
        TextEditingController(text: widget.state.description);
    _contentController = TextEditingController(text: widget.state.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _syncControllers(UploadArticleState s) {
    if (_titleController.text != s.title) {
      _titleController.text = s.title;
    }
    if (_descriptionController.text != s.description) {
      _descriptionController.text = s.description;
    }
    if (_contentController.text != s.content) {
      _contentController.text = s.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UploadArticleBloc>();
    return BlocListener<UploadArticleBloc, UploadArticleState>(
      listenWhen: (prev, curr) =>
          prev.draftId != curr.draftId ||
          prev.editingArticleId != curr.editingArticleId,
      listener: (context, state) => _syncControllers(state),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThumbnailPicker(
              localImagePath: widget.state.localImagePath,
              compressedBytes: widget.state.compressedBytes,
              existingRemoteUrl: widget.state.existingThumbnailUrl,
              isPicking: widget.state.isPickingImage,
              onPickFromGallery: () =>
                  bloc.add(const PickThumbnailEvent(ImageSource.gallery)),
              onPickFromCamera: () =>
                  bloc.add(const PickThumbnailEvent(ImageSource.camera)),
              onClear: widget.state.compressedBytes != null
                  ? () => bloc.add(const ResetEvent())
                  : null,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('upload_title_field'),
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Article title',
                helperText: '5–200 characters',
              ),
              onChanged: (v) => bloc.add(TitleChangedEvent(v)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief summary',
                helperText: '20–500 characters',
              ),
              maxLines: 3,
              onChanged: (v) => bloc.add(DescriptionChangedEvent(v)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Article body',
                helperText: 'min 50 characters',
              ),
              maxLines: 8,
              onChanged: (v) => bloc.add(ContentChangedEvent(v)),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).fieldCategory,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            CategoryChips(
              selected: widget.state.category,
              onSelected: (c) => bloc.add(CategoryChangedEvent(c)),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).fieldTags,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TagsField(
              tags: widget.state.tags,
              onChanged: (tags) => bloc.add(TagsChangedEvent(tags)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(
                'lang-${widget.state.draftId}-${widget.state.editingArticleId}',
              ),
              initialValue: widget.state.language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: [
                DropdownMenuItem(
                    value: 'en',
                    child: Text(AppLocalizations.of(context).languageEnglish)),
                DropdownMenuItem(
                    value: 'es',
                    child: Text(AppLocalizations.of(context).languageSpanish)),
              ],
              onChanged: (v) {
                if (v != null) bloc.add(LanguageChangedEvent(v));
              },
            ),
            const SizedBox(height: 16),
            AutoSaveIndicator(lastSavedAt: widget.state.lastSavedAt),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
