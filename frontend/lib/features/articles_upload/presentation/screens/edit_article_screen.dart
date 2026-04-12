import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/entities/article_upload.dart';
import 'package:news_app_clean_architecture/features/articles_upload/domain/params/update_article_params.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/create_article_state.dart';
import 'package:news_app_clean_architecture/features/articles_upload/presentation/bloc/create_article/edit_article_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class EditArticleScreen extends StatelessWidget {
  final ArticleUploadEntity article;
  const EditArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditArticleCubit>(
      create: (_) => sl<EditArticleCubit>(),
      child: _EditArticleView(article: article),
    );
  }
}

class _EditArticleView extends StatefulWidget {
  final ArticleUploadEntity article;
  const _EditArticleView({required this.article});

  @override
  State<_EditArticleView> createState() => _EditArticleViewState();
}

class _EditArticleViewState extends State<_EditArticleView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _sourceCtrl;

  File? _newThumbnail;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.article.title);
    _descriptionCtrl = TextEditingController(text: widget.article.description);
    _contentCtrl = TextEditingController(text: widget.article.content);
    _authorCtrl = TextEditingController(text: widget.article.author);
    _sourceCtrl = TextEditingController(text: widget.article.sourceName ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _contentCtrl.dispose();
    _authorCtrl.dispose();
    _sourceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _newThumbnail = File(picked.path));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final params = UpdateArticleParams(
      id: widget.article.id!,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      sourceName:
          _sourceCtrl.text.trim().isEmpty ? null : _sourceCtrl.text.trim(),
      publishedAt: widget.article.publishedAt,
      newThumbnailFile: _newThumbnail,
    );

    context.read<EditArticleCubit>().submit(params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Article')),
      body: BlocConsumer<EditArticleCubit, CreateArticleState>(
        listener: (context, state) {
          if (state is CreateArticleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Article updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is CreateArticleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: ${state.reason}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CreateArticleSubmitting;
          return AbsorbPointer(
            absorbing: isSubmitting,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ThumbnailPreview(
                      existingUrl: widget.article.thumbnailURL,
                      newFile: _newThumbnail,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: 16),
                    _field(_titleCtrl, 'Title', 120, required: true),
                    _field(_descriptionCtrl, 'Description', 300,
                        maxLines: 2, required: true),
                    _field(_contentCtrl, 'Content', 20000,
                        maxLines: 8, required: true),
                    _field(_authorCtrl, 'Author', 80, required: true),
                    _field(_sourceCtrl, 'Source (optional)', 60),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submit,
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(isSubmitting ? 'Saving…' : 'Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    int maxLength, {
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  final String existingUrl;
  final File? newFile;
  final VoidCallback onTap;

  const _ThumbnailPreview({
    required this.existingUrl,
    required this.newFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (newFile != null)
              Image.file(newFile!, fit: BoxFit.cover)
            else if (existingUrl.startsWith('http'))
              Image.network(existingUrl, fit: BoxFit.cover)
            else
              const Icon(Icons.image, size: 48),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tap to change',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
