import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_topic.dart';
import '../../../domain/params/article_draft.dart';
import '../../bloc/article_editor/article_editor_cubit.dart';
import '../../bloc/article_editor/article_editor_state.dart';
import '../../bloc/articles/articles_cubit.dart';
import '../../bloc/saved_articles/saved_articles_cubit.dart';
import '../../widgets/editor/article_content_editor.dart';
import '../../widgets/editor/gallery_image_picker.dart';
import '../../widgets/editor/thumbnail_picker.dart';
import '../../widgets/editor/topic_selector.dart';
import '../../widgets/rich_content/article_document.dart';
import 'article_validation_messages.dart';

/// Publishes a new article, or edits [original] when it is given.
/// It closes returning the saved article.
class ArticleEditorScreen extends StatefulWidget {
  final ArticleEntity? original;

  const ArticleEditorScreen({super.key, this.original});

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  late final TextEditingController _titleController = TextEditingController(text: widget.original?.title);
  late final TextEditingController _descriptionController = TextEditingController(text: widget.original?.description);
  late final QuillController _contentController = QuillController(
    document: widget.original == null ? Document() : documentFromContent(widget.original!.content),
    selection: const TextSelection.collapsed(offset: 0),
  );
  late Set<ArticleTopic> _topics = {...?widget.original?.topics};
  Uint8List? _thumbnail;

  bool get _isEditing => widget.original != null;

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
      listener: _onStateChanged,
      builder:
          (context, state) => Scaffold(
            appBar: AppBar(
              title: Text(_isEditing ? 'Editar artículo' : 'Nuevo artículo'),
              actions: [_buildSubmitButton(state)],
            ),
            body: Column(
              children: [
                Expanded(child: _buildForm(state.validationErrors)),
                SafeArea(
                  top: false,
                  child: ArticleContentToolbar(
                    controller: _contentController,
                    onInsertImage: _insertContentImage,
                    isUploadingImage: state.isUploadingImage,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSubmitButton(ArticleEditorState state) {
    if (state.isSubmitting) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return TextButton(
      onPressed: state.isUploadingImage ? null : _submit,
      child: Text(_isEditing ? 'GUARDAR' : 'PUBLICAR', style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildForm(Set<ArticleValidationError> errors) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ThumbnailPicker(
          pickedImage: _thumbnail,
          currentImageURL: widget.original?.thumbnailURL,
          onTap: _pickThumbnail,
          errorText: messageForField(errors, thumbnailErrors),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _titleController,
          maxLength: ArticleLimits.titleMaxLength,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          decoration: InputDecoration(labelText: 'Título', errorText: messageForField(errors, titleErrors)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          maxLength: ArticleLimits.descriptionMaxLength,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Descripción',
            helperText: 'Resumen que se muestra en la lista de noticias.',
            errorText: messageForField(errors, descriptionErrors),
          ),
        ),
        const SizedBox(height: 24),
        TopicSelector(
          selectedTopics: _topics,
          maxTopics: ArticleLimits.maxTopics,
          onChanged: (topics) => setState(() => _topics = topics),
          errorText: messageForField(errors, topicErrors),
        ),
        const SizedBox(height: 24),
        ArticleContentEditor(controller: _contentController, errorText: messageForField(errors, contentErrors)),
      ],
    );
  }

  Future<void> _pickThumbnail() async {
    final image = await pickImageFromGallery();
    if (image != null) setState(() => _thumbnail = image);
  }

  Future<void> _insertContentImage() async {
    final image = await pickImageFromGallery();
    if (image == null || !mounted) return;
    final imageURL = await context.read<ArticleEditorCubit>().uploadContentImage(image);
    if (imageURL != null) _contentController.insertImage(imageURL);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<ArticleEditorCubit>().submit(
      articleId: widget.original?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      content: contentFromDocument(_contentController.document),
      topics: _topics,
      thumbnail: _thumbnail,
    );
  }

  void _onStateChanged(BuildContext context, ArticleEditorState state) {
    switch (state.status) {
      case ArticleEditorStatus.success:
        _onSaved(context, state.savedArticle!);
      case ArticleEditorStatus.failure:
        _showMessage(
          context,
          state.validationErrors.isEmpty
              ? 'No se pudo guardar el artículo. Inténtalo de nuevo.'
              : 'Revisa los campos marcados.',
        );
      case ArticleEditorStatus.imageUploadFailure:
        _showMessage(context, 'No se pudo subir la imagen. Inténtalo de nuevo.');
      case ArticleEditorStatus.editing || ArticleEditorStatus.submitting:
        break;
    }
  }

  void _onSaved(BuildContext context, ArticleEntity article) {
    context.read<ArticlesCubit>().load();
    context.read<SavedArticlesCubit>().load();
    _showMessage(context, _isEditing ? 'Artículo actualizado.' : 'Artículo publicado.');
    Navigator.of(context).pop(article);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
