import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/user_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_state.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/widgets/thumbnail_picker.dart';

class UploadArticleScreen extends StatefulWidget {
  final UserArticleEntity? existing;
  const UploadArticleScreen({super.key, this.existing});

  @override
  State<UploadArticleScreen> createState() => _UploadArticleScreenState();
}

class _UploadArticleScreenState extends State<UploadArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final quill.QuillController _contentController;
  PickedThumbnail? _newThumbnail;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _contentController = _buildContentController(e?.content);
  }

  quill.QuillController _buildContentController(String? existing) {
    if (existing == null || existing.isEmpty) {
      return quill.QuillController.basic();
    }
    try {
      final json = jsonDecode(existing);
      if (json is List) {
        return quill.QuillController(
          document: quill.Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    } catch (_) {
      // fall through to plain-text treatment
    }
    final doc = quill.Document()..insert(0, existing);
    return quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _serializeContent() =>
      jsonEncode(_contentController.document.toDelta().toJson());

  bool _contentIsEmpty() =>
      _contentController.document.toPlainText().trim().isEmpty;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_contentIsEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content is required.')),
      );
      return;
    }
    final cubit = context.read<UploadArticleCubit>();
    final content = _serializeContent();
    if (_isEditing) {
      cubit.update(
        articleId: widget.existing!.id!,
        title: _title.text,
        description: _description.text,
        content: content,
        newThumbnailBytes: _newThumbnail?.bytes,
        newThumbnailFileName: _newThumbnail?.fileName,
      );
    } else {
      if (_newThumbnail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick a thumbnail image.')),
        );
        return;
      }
      cubit.submit(
        title: _title.text,
        description: _description.text,
        content: content,
        thumbnailBytes: _newThumbnail!.bytes,
        thumbnailFileName: _newThumbnail!.fileName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadArticleCubit, UploadArticleState>(
      listener: (context, state) {
        if (state is UploadArticleSuccess) {
          Navigator.of(context).pop(true);
        }
        if (state is UploadArticleFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final busy = state is UploadArticleSubmitting;
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit article' : 'New article'),
            iconTheme: const IconThemeData(color: Colors.black),
            titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
          ),
          body: AbsorbPointer(
            absorbing: busy,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ThumbnailPicker(
                      initialImageUrl: widget.existing?.thumbnailUrl,
                      onChanged: (picked) =>
                          setState(() => _newThumbnail = picked),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _title,
                      maxLength: 120,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _description,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _ContentEditor(controller: _contentController),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Save changes' : 'Publish'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContentEditor extends StatelessWidget {
  final quill.QuillController controller;
  const _ContentEditor({required this.controller});

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          child: quill.QuillSimpleToolbar(
            controller: controller,
            config: const quill.QuillSimpleToolbarConfig(
              multiRowsDisplay: false,
              showFontFamily: false,
              showFontSize: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showCodeBlock: false,
              showInlineCode: false,
              showIndent: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              showAlignmentButtons: false,
              showDirection: false,
              showDividers: true,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 240),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: border),
              right: BorderSide(color: border),
              bottom: BorderSide(color: border),
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: quill.QuillEditor.basic(
            controller: controller,
            config: const quill.QuillEditorConfig(
              placeholder: 'Write your article…',
              expands: false,
            ),
          ),
        ),
      ],
    );
  }
}
